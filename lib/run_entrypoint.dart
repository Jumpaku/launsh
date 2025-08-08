import 'dart:convert';
import 'dart:io';

import 'package:launsh/schema/entrypoint.dart';
import 'package:path/path.dart' as path;

Future<int> runEntrypoint(
  String workingDir,
  Entrypoint entrypoint,
  Map<String, String> parameters, [
  void Function(String message)? onLog,
]) async {
  final stdout = entrypoint.stdout == null
      ? null
      : File(path.join(workingDir, entrypoint.stdout!));
  final stderr = entrypoint.stderr == null
      ? null
      : File(path.join(workingDir, entrypoint.stderr!));

  stdout?.createSync(recursive: true);
  stderr?.createSync(recursive: true);

  final process = await Process.start(
    entrypoint.program,
    entrypoint.args,
    workingDirectory: workingDir,
    environment: {}
      ..addEntries(entrypoint.environment.entries)
      ..addEntries(parameters.entries),
    runInShell: true,
  );

  process.stdout.transform(utf8.decoder).listen((data) {
    if (data.trim().isNotEmpty && onLog != null) {
      onLog('STDOUT: ${data.trim()}');
    }
    stdout?.writeAsStringSync(data, mode: FileMode.writeOnlyAppend);
  });

  process.stderr.transform(utf8.decoder).listen((data) {
    if (data.trim().isNotEmpty && onLog != null) {
      onLog('STDERR: ${data.trim()}');
    }
    stderr?.writeAsStringSync(data, mode: FileMode.writeOnlyAppend);
  });

  final exitCode = await process.exitCode;
  return exitCode;
}
