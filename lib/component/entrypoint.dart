import 'package:flutter/material.dart';
import 'package:launsh/component/run_dialog.dart';
import 'package:launsh/run_entrypoint.dart';
import 'package:launsh/schema/entrypoint.dart';

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
    try {
      final parameters = {
        for (final e in _parameterControllers.entries) e.key: e.value.text,
      };
      final exitCode = await runEntrypoint(
        widget.workingDir,
        widget.entrypoint,
        parameters,
        widget.onLog,
      );
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
