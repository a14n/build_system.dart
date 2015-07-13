# Build system

[![Build Status](https://travis-ci.org/a14n/build_system.dart.svg?branch=master)](https://travis-ci.org/a14n/build_system.dart)

This package allows to simulate the behaviour of the Dart Editor with `build.dart`.
You can read [Build.dart and the Dart Editor Build System](http://www.dartlang.org/tools/editor/build.html) to understand available interactions with Dart Editor.

> Build.dart is a simple build script convention that lets you add behavior to the Dart Editor build system. If the root of a Dart Editor project has a script named build.dart, that script is invoked during a build with information about the changed files. You can use build.dart to post-process changed files, generate other files, or drive other aspects of the build system.

## Usage

First activate the package with `pub global activate build_system`. Now you just need to launch `pub global run build_system` and the `build.dart` file will be called at every file creation/modification/deletion.

## License ##
Apache 2.0
