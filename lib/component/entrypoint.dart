import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:launsh/component/run_dialog.dart';
import 'package:launsh/schema/entrypoint.dart';
import 'package:path/path.dart' as path;

// Callback type for logging messages.
typedef LogCallback = void Function(String message);

class EntrypointElement extends StatefulWidget {
  final String workingDir;
  final String name;
  final Entrypoint entrypoint;
  final LogCallback onLog; // Callback to send logs to the parent.

  const EntrypointElement({
    super.key,
    required this.workingDir,
    required this.name,
    required this.entrypoint,
    required this.onLog,
  });

  @override
  State<EntrypointElement> createState() => _EntrypointElementState();
}

class _EntrypointElementState extends State<EntrypointElement> {
  late final Map<String, TextEditingController> _parameterControllers;

  @override
  void initState() {
    super.initState();
    _parameterControllers = {
      for (final v in widget.entrypoint.parameter) v: TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final controller in _parameterControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String get _command {
    return '${widget.entrypoint.program} ${widget.entrypoint.args.join(' ')}';
  }

  Future<void> _confirmAndRunExecution(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => RunDialog(
        command: _command,
        parameterNames: widget.entrypoint.parameter,
        parameterControllers: _parameterControllers,
      ),
    );
    if (confirmed == true) {
      await _runExecution();
    }
  }

  Future<void> _runExecution() async {
    widget.onLog('Running command: $_command');
    final execution = widget.entrypoint;
    final workingDir = widget.workingDir;
    final stdout = execution.stdout == null
        ? null
        : File(path.join(workingDir, execution.stdout!));
    final stderr = execution.stderr == null
        ? null
        : File(path.join(workingDir, execution.stderr!));

    try {
      final parameters = {
        for (final e in _parameterControllers.entries) e.key: e.value.text,
      };
      stdout?.createSync(recursive: true);
      stderr?.createSync(recursive: true);

      final process = await Process.start(
        execution.program,
        execution.args,
        workingDirectory: workingDir,
        environment: {}..addEntries(execution.environment.entries)..addEntries(parameters.entries),
        runInShell: true,
      );

      process.stdout.transform(utf8.decoder).listen((data) {
        if (data.trim().isNotEmpty) widget.onLog('STDOUT: ${data.trim()}');
        stdout?.writeAsStringSync(data, mode: FileMode.writeOnlyAppend);
      });

      process.stderr.transform(utf8.decoder).listen((data) {
        if (data.trim().isNotEmpty) widget.onLog('STDERR: ${data.trim()}');
        stderr?.writeAsStringSync(data, mode: FileMode.writeOnlyAppend);
      });

      final exitCode = await process.exitCode;
      widget.onLog('Process exited with code $exitCode');
    } catch (e) {
      widget.onLog('Failed to run command: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Tooltip(
                  message: widget.entrypoint.description ?? '',
                  child: Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Run'),
                  onPressed: () => _confirmAndRunExecution(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _command,
              style: TextStyle(
                fontFamily: 'monospace',
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
