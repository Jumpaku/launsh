import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:launsh/component/run_dialog.dart';
import 'package:launsh/schema/execution.dart';
import 'package:path/path.dart' as path;

// Callback type for logging messages.
typedef LogCallback = void Function(String message);

class ExecutionEntry extends StatefulWidget {
  final String configDir;
  final String name;
  final Execution execution;
  final LogCallback onLog; // Callback to send logs to the parent.

  const ExecutionEntry({
    super.key,
    required this.configDir,
    required this.name,
    required this.execution,
    required this.onLog,
  });

  @override
  State<ExecutionEntry> createState() => _ExecutionEntryState();
}

class _ExecutionEntryState extends State<ExecutionEntry> {
  late final Map<String, TextEditingController> _variableControllers;

  @override
  void initState() {
    super.initState();
    _variableControllers = {
      for (final v in widget.execution.variable) v: TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final controller in _variableControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String get _interpolatedCommand {
    return '${widget.execution.program} ${widget.execution.args.join(' ')}';
  }

  Future<void> _confirmAndRunExecution(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => RunDialog(
        command: _interpolatedCommand,
        variableNames: widget.execution.variable,
        variableControllers: _variableControllers,
      ),
    );
    if (confirmed == true) {
      await _runExecution();
    }
  }

  Future<void> _runExecution() async {
    widget.onLog('Running command: $_interpolatedCommand');
    final execution = widget.execution;
    final workingDir = path.join(widget.configDir, execution.workingDir);

    try {
      final variables = {
        for (final e in _variableControllers.entries) e.key: e.value.text,
      };
      final stdout = execution.stdout == null ? null : path.join(workingDir, execution.stdout);
      final stderr = execution.stderr == null ? null : path.join(workingDir, execution.stderr);
      if (stdout != null) {
        File(stdout).createSync(recursive: true);
      }
      if (stderr != null) {
        File(stderr).createSync(recursive: true);
      }

      final process = await Process.start(
        execution.program,
        execution.args,
        workingDirectory: workingDir,
        environment: execution.environment..addEntries(variables.entries),
        runInShell: true,
      );

      process.stdout.transform(utf8.decoder).listen((data) {
        if (data.trim().isNotEmpty) widget.onLog('STDOUT: ${data.trim()}');
        if (stdout != null) {
          File(stdout).writeAsStringSync(data, mode: FileMode.writeOnlyAppend);
        }
      });

      process.stderr.transform(utf8.decoder).listen((data) {
        if (data.trim().isNotEmpty) widget.onLog('STDERR: ${data.trim()}');
        if (stderr != null) {
          File(stderr).writeAsStringSync(data, mode: FileMode.writeOnlyAppend);
        }
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
                  message: widget.execution.description ?? '',
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
              _interpolatedCommand,
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
