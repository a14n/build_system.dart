import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:build_system/build_system.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _waitDuration = const Duration(milliseconds: 300);

main() {
  String projectPath;

  setUp(() async {
    projectPath = await createTmpProject();
  });

  test('start with full build', () async {
    await new File(p.join(projectPath, 'file.txt'))..create();
    await withBuildSystem(projectPath, () async {
      sleep(_waitDuration);
      expect(await new File(p.join(projectPath, 'log.txt')).readAsString(),
          equals('--machine --full'));
    }, startWithFullBuild: true);
  });

  test('create file', () async {
    await withBuildSystem(projectPath, () async {
      await new File(p.join(projectPath, 'file.txt')).create();
      sleep(_waitDuration);
      expect(await new File(p.join(projectPath, 'log.txt')).readAsString(),
          equals('--machine --changed file.txt'));
    });
  });

  test('modify file', () async {
    final file = await new File(p.join(projectPath, 'file.txt'))..create();
    await withBuildSystem(projectPath, () async {
      await file.writeAsString('something');
      sleep(_waitDuration);
      expect(await new File(p.join(projectPath, 'log.txt')).readAsString(),
          equals('--machine --changed file.txt'));
    });
  });

  test('delete file', () async {
    final file = await new File(p.join(projectPath, 'file.txt'))..create();
    await withBuildSystem(projectPath, () async {
      await file.delete();
      sleep(_waitDuration);
      expect(await new File(p.join(projectPath, 'log.txt')).readAsString(),
          equals('--machine --removed file.txt'));
    });
  });

  tearDown(() async {
    await new Directory(projectPath).delete(recursive: true);
  });
}

_start(String paramsAsJson) {
  final params = JSON.decode(paramsAsJson);
  final projectPath = params[0];
  final startWithFullBuild = params[1];
  watch(projectPath, startWithFullBuild: startWithFullBuild);
}

withBuildSystem(String projectPath, job(), {bool startWithFullBuild}) async {
  final isolate = await Isolate.spawn(
      _start, JSON.encode([projectPath, startWithFullBuild]));

  // waiting for the file watcher (quite long on travis)
  sleep(const Duration(milliseconds: 300));
  try {
    await job();
  } finally {
    isolate.kill();
  }
}

Future<String> createTmpProject() async {
  final dir = await Directory.systemTemp.createTemp();
  final dirPath = dir.path;

  final buildFile = new File(p.join(dirPath, 'build.dart'));
  await buildFile.create(recursive: true);
  await buildFile.writeAsString('''
import 'dart:io';

main(List<String> args) {
  if (args.contains('log.txt')) return;
  new File('log.txt')
      ..createSync()
      ..writeAsStringSync(args.join(' '), mode: FileMode.APPEND);
}
''');
  return dirPath;
}
