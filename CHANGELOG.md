# Change log
All notable changes to this project will be documented in this file. This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased][unreleased]
### Added
- Ability to pass the `sudo` parameter to the `Vagrant` provider. This runs the script with `sudo`.

### Fixed
- The `gonzo` binary would run in whatever directory the user was in at the time, regardless of what arguments were passed to the binary. Now we `Dir.chdir` to the project directory while executing `gonzo`.
- Path being passed to `Gonzo.config` was hardcoded as `.` in `bin/gonzo`.

## [0.1.0] - 09-04-2015
Intial Release

[0.1.0]: https://github.com/danzilio/gonzo/tree/0.1.0
