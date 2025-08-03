import 'package:flutter/material.dart';

class RunDialog extends StatelessWidget {
  final String command;
  final List<String> variableNames;
  final Map<String, TextEditingController> variableControllers;

  const RunDialog({
    super.key,
    required this.command,
    required this.variableNames,
    required this.variableControllers,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Execution'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Run the following command?'),
              const SizedBox(height: 8),
              Text(command, style: const TextStyle(fontFamily: 'monospace')),
              if (variableNames.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Set variables:'),
                ...variableNames.map((v) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: TextField(
                    controller: variableControllers[v],
                    decoration: InputDecoration(labelText: v),
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Run'),
        ),
      ],
    );
  }
}

