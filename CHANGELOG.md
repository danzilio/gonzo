# Change log
All notable changes to this project will be documented in this file. This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased][unreleased]
## [0.2.1] - 09-08-2015
No changes. The previous owner of the `gonzo` gem namespace published and subsequently yanked version `0.2.0`. The RubyGems staff has informed me that the only course of action is to publish a different version number. This version is being created specifically for that reason.

## [0.2.0] - 09-08-2015
### Added
- The ability to pass the `sudo` parameter to the `Vagrant` provider. This runs the script with `sudo`.
- The `docker` provider.

### Fixed
- The `gonzo` binary would run in whatever directory the user was in at the time, regardless of what arguments were passed to the binary. Now we `Dir.chdir` to the project directory while executing `gonzo`.
- Path being passed to `Gonzo.config` was hardcoded as `.` in `bin/gonzo`.

## [0.1.0] - 09-04-2015
Intial Release

[unreleased]: https://github.com/danzilio/gonzo/compare/0.2.0...HEAD
[0.2.1]: https://github.com/danzilio/gonzo/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/danzilio/gonzo/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/danzilio/gonzo/tree/0.1.0
