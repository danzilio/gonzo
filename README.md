[![Build Status](https://travis-ci.org/danzilio/gonzo.svg?branch=master)](https://travis-ci.org/danzilio/gonzo) [![Gem Version](https://badge.fury.io/rb/gonzo.svg)](http://badge.fury.io/rb/gonzo)

![Gonzo](http://a.dilcdn.com/bl/wp-content/uploads/sites/2/2013/11/gonzo-and-camilla-the-chicken2.jpg)

Gonzo was inspired by [Beaker](https://github.com/puppetlabs/beaker), but is meant to be a little stupider. I set out to write Gonzo because I just wanted a way to spin up a VM or group of VMs programmatically and run ServerSpec tests on them. I wasn't interested in using the Beaker helpers or matchers. I just wanted something simple and agnostic. This is the hack that ensued.

## Installation

Install the Gem with the `gem` command:

```
gem install gonzo
```

Or add it to your `Gemfile`:

```ruby
source 'https://rubygems.org'

gem 'gonzo'
```

## Usage

At the root of your project, you'll need to create a `.gonzo.yml` file. This is where you'll configure VMs for Gonzo. You'll need to configure a supported provider. As of right now, the only supported providers are `vagrant` and `docker`. The top-level key will be the name of the provider. Here's an example `.gonzo.yml` that contains a single VM:

```yaml
---
  vagrant:
    box: 'puppetlabs/centos-7.0-64-puppet'
    env:
      PUPPET_VERSION: '4.1.0'
    commands:
      - 'sudo yum -y install git ruby-devel libxml2-devel'
      - 'sudo gem install bundler'
      - 'rm Gemfile.lock'
      - 'bundle install --path vendor'
      - 'bundle exec rake spec'
```

You can configure multiple boxes to run serially by giving them a name:

```yaml
---
  vagrant:
    spec_tests:
      box: 'puppetlabs/centos-7.0-64-puppet'
      env:
        PUPPET_VERSION: '4.1.0'
      commands:
        - 'sudo yum -y install git ruby-devel libxml2-devel'
        - 'sudo gem install bundler'
        - 'bundle install --path vendor'
        - 'bundle exec rake spec'
    acceptance_tests:
      box: 'puppetlabs/centos-7.0-64-puppet'
      env:
        PUPPET_VERSION: '4.1.0'
      commands:
        - 'sudo yum -y install git ruby-devel libxml2-devel'
        - 'sudo gem install bundler'
        - 'bundle install --path vendor'
        - 'bundle exec rake spec_prep'
        - 'bundle exec puppet apply examples/init.pp --modulepath spec/fixtures/modules'
        - 'bundle exec rake acceptance'
```

Once you've configured a `.gonzo.yml` file, you'll need to include the Rake tasks in your `Rakefile` by adding this line:

```ruby
require 'gonzo/rake_tasks'
```

This will make the `gonzo` rake task available to you. You can run Gonzo by running `bundle exec rake gonzo`. This will start all of the VMs serially. If one VM fails, by default Gonzo will continue on to the next VM in the list. You can configure this in `.gonzo.yml` by setting `stop_on_failure` to `true` in the `gonzo` section of `.gonzo.yml`. For example:

```yaml
---
  gonzo:
    stop_on_failure: true
```

Gonzo will aggregate the exit statuses from all VMs and exit 1 if any of them failed, or 0 if they all succeeded.

### Commands

Commands will be run sequentially inside the directory where your `.gonzo.yml` file is. The `vagrant` provider copies the directory to `/tmp/gonzo` instead of running in `/gonzo` to avoid changing the project in flight. If you want to retrieve test results or generated binaries, simply add a command to copy them into `/gonzo` at the end of your run:

```yaml
---
  vagrant:
    box: 'puppetlabs/centos-7.0-64-puppet'
    env:
      PUPPET_VERSION: '4.1.0'
    commands:
      - 'puppet module install puppetlabs-strings'
      - 'puppet strings'
      - 'cp -r doc /gonzo'
```

### Environment Variables

The `env` key allows you to pass environment variables to your commands. The key must be the variable name, and the value the value you wish to assign to that variable.

## Providers

Gonzo has the ability to support multiple providers. Each provider defines the options available in `.gonzo.yml`. The working directory will be available in the VM/container at `/gonzo` but will build in `/tmp/gonzo` as to not make destructive changes to the project.

All providers implement the `env` and `commands` parameters.

- `env`: Hash of string key/value pairs, optional. The `env` parameter takes a hash of variable names and values that should be available to the commands defined in the `commands` parameter.
- `commands`: Array of strings, required. The `commands` parameter takes an array of commands to be executed inside the VM/container.

When defining multiple execution environments with multiple providers, they will execute serially:

```yaml
---
  docker:
    image: 'centos:centos7'
    env:
      PUPPET_VERSION: '3.8.0'
    commands:
      - 'yum -y install rubygem-bundler'
      - 'bundle install --path vendor'
      - 'bundle exec rake spec'
  vagrant:
    box: 'puppetlabs/centos-7.0-64-puppet'
    env:
      PUPPET_VERSION: '4.1.0'
    commands:
      - 'puppet module install puppetlabs-strings'
      - 'puppet strings'
      - 'cp -r doc /gonzo'
```

The example above will run the `docker` provider first, followed by the `vagrant` provider.

### Docker

The Docker provider requires the `image` parameter to be defined in `.gonzo.yml`. This tells `docker` what image to run the commands in. If the image is not available, `docker` will try and download it.

#### Available Parameters:

- `image`: String, required. The image that `docker` should use to run the commands defined in the `commands` section.
- `user`: String, optional. The user under which the commands defined in the `command` array should be run. This user must exist in the container for the command to succeed.

### Vagrant

The Vagrant provider requires the `box` paramater to be defined in `.gonzo.yml`.

#### Available Parameters:

- `box`: String, required. The Vagrant box that should be used.
- `box_url`: String, optional. The URL for the Vagrant box specified in the `box` parameter. If the `box` is not available on the system, this tells Vagrant where to download the box from.
- `sudo`: Boolean, optional. If this is set to `true` the commands specified in the `commands` section will be run as `root` instead of `vagrant`. Defaults to `false`.
