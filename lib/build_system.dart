// Copyright (c) 2015, Alexandre Ardhuin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library build_system;

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:watcher/watcher.dart';

/// Watch every file changes under [projectPath] and call `build.dart` with the
/// same arguments the removed dart Editor did.
watch(String projectPath, {bool startWithFullBuild: true}) async {
  if (!await new File(p.join(projectPath, 'build.dart')).exists()) {
    throw 'There is no build.dart file in $projectPath';
  }

  if (startWithFullBuild == true) {
    print('Full build');
    await _callBuild(projectPath, ['--full']);
  }

  print('Watching changes');

  await for (WatchEvent e in new Watcher(projectPath).events) {
    final extraArgs = <String>[];
    switch (e.type) {
      case ChangeType.ADD:
      case ChangeType.MODIFY:
        extraArgs.add('--changed');
        break;
      case ChangeType.REMOVE:
        extraArgs.add('--removed');
        break;
    }
    extraArgs.add(p.relative(e.path, from: projectPath));
    await _callBuild(projectPath, extraArgs);
  }
}

Future<Null> _callBuild(String projectPath, List<String> extraArgs) async {
  final args = <String>['build.dart', '--machine'];
  if (extraArgs != null) args.addAll(extraArgs);

  print('---\n${args.join(' ')}');
  final sw = new Stopwatch()..start();
  final pr = await Process.run('dart', args, workingDirectory: projectPath);
  stdout.write(pr.stdout);
  stderr.write(pr.stderr);
  print('build.dart finished [${sw.elapsedMilliseconds} ms]\n');
}
