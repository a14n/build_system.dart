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

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:watcher/watcher.dart';

/// Watch every file changes under [projectPath] and call `build.dart` with the
/// same arguments the removed dart Editor did.
watch(String projectPath) async {
  if (!await new File(p.join(projectPath, 'build.dart')).exists()) {
    throw 'There is no build.dart file in $projectPath';
  }

  print('Watching $projectPath');

  await for (WatchEvent e in new Watcher(projectPath).events) {
    final args = ['build.dart', '--machine'];
    switch (e.type) {
      case ChangeType.ADD:
      case ChangeType.MODIFY:
        args.add('--changed');
        break;
      case ChangeType.REMOVE:
        args.add('--removed');
        break;
    }
    args.add(p.relative(e.path, from: projectPath));

    print('---\n${args.join(' ')}');
    final sw = new Stopwatch()..start();
    final pr = await Process.run('dart', args, workingDirectory: projectPath);
    stdout.write(pr.stdout);
    stderr.write(pr.stderr);
    print('build.dart finished [${sw.elapsedMilliseconds} ms]\n');
  }
}
