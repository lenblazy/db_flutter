# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2026-01-05

### Added

- Added storage dependency to support secured sqlite

### Removed

- Removed casting `Object` to `dynamic` type

## [1.1.0] - 2025-07-23

### Added

- Added Entity class for storing db data

### Changed

- Changed return type of insert method from `bool` to `int`
- Changed return type of retrieve method from `Map` to generic that extends `Entity`

## [1.0.0] - 2025-07-14

### Added

- Set up Database service
- Added tests coverage to 100 percent
- Used QueryProvider to fetch DB data

### Changed 

- Formatted code errors

## [0.0.1] - 2025-07-14

### Added

- Added a ability to send requests

[unreleased]: https://github.com/lenblazy/db_flutter/compare/release/1.1.0...develop

[1.1.0]: https://github.com/lenblazy/db_flutter/releases/tag/v1.1.0
[1.0.0]: https://github.com/lenblazy/db_flutter/releases/tag/v1.0.0
[0.0.1]: https://github.com/lenblazy/db_flutter/releases/tag/v0.0.1