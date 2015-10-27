# Build system

[![Build Status](https://travis-ci.org/a14n/build_system.dart.svg?branch=master)](https://travis-ci.org/a14n/build_system.dart)

This package allows to trigger a `build.dart` script every time a file is added,
changed or removed in the working tree where _Build system_ is launched.

The `build.dart` script will be called with information about the changed files.

You can use build.dart to post-process changed files, generate other files or
drive other aspects of the build system.

## Flags

_Build system_ invokes `build.dart` with any of the following command-line
flags:

- `--changed=<filename>`: Specifies a file that changed and should be rebuilt.
One instance of the `--changed` flag is passed in for every changed (created or
  modified) file.
- `--removed=<filename>`: Specifies a file that was removed and might affect the
build. One instance of the `--removed` flag is passed in for every deleted file.
- `--full`: Requests a full build;  no incremental information is available.

## Usage

First activate the package with `pub global activate build_system`. Now you just
need to launch `pub global run build_system` and the `build.dart` file will be
called at every file creation/modification/deletion.

NB: By default a _full build_ (with `--full` argument) will be executed at
startup. You can skip this behaviour with a `--no-full` argument.

## History

This package was initially done to get a similar behaviour of the retired Dart
Editor with its build.dart.

## License ##
Apache 2.0
