import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:build_system/build_system.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

main() {
  String projectPath;

  setUp(() async {
    projectPath = await createTmpProject();
  });

  test('create file', () async {
    await withBuildSystem(projectPath, expectAsync(() async {
      await new File(p.join(projectPath, 'file.txt')).create();
      sleep(const Duration(milliseconds: 100));
      expect(await new File(p.join(projectPath, 'log.txt')).readAsString(),
          equals('--machine --changed file.txt'));
    }));
  });

  test('modify file', () async {
    final file = await new File(p.join(projectPath, 'file.txt'))..create();
    await withBuildSystem(projectPath, expectAsync(() async {
      await file.writeAsString('something');
      sleep(const Duration(milliseconds: 100));
      expect(await new File(p.join(projectPath, 'log.txt')).readAsString(),
          equals('--machine --changed file.txt'));
    }));
  });

  test('delete file', () async {
    final file = await new File(p.join(projectPath, 'file.txt'))..create();
    await withBuildSystem(projectPath, expectAsync(() async {
      await file.delete();
      sleep(const Duration(milliseconds: 100));
      expect(await new File(p.join(projectPath, 'log.txt')).readAsString(),
          equals('--machine --removed file.txt'));
    }));
  });

  tearDown(() async {
    await new Directory(projectPath).delete(recursive: true);
  });
}

withBuildSystem(String projectPath, job()) async {
  final isolate = await Isolate.spawn(watch, projectPath);
  sleep(const Duration(milliseconds: 100));
  try {
    await job();
  } finally {
    isolate.kill();
  }
}

int id = 0;

Future<String> createTmpProject() async {
  final dirPath = p.join(Directory.current.path, 'test', 'tmp-${id++}');
  await new Directory(dirPath).create(recursive: true);

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
