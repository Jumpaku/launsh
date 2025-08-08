import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:launsh/component/entrypoint.dart';
import 'package:launsh/schema/config.dart';
import 'package:path/path.dart' as path;

class EntrypointList extends StatefulWidget {
  final String? workingDir;
  final LogCallback onLog;

  const EntrypointList({
    super.key,
    required this.workingDir,
    required this.onLog,
  });

  @override
  State<EntrypointList> createState() => _EntrypointListState();
}

class _EntrypointListState extends State<EntrypointList> {
  Config? _config;

  @override
  void didUpdateWidget(covariant EntrypointList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.workingDir != null) {
      _loadConfig(path.join(widget.workingDir!, 'launsh.json'));
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.workingDir != null) {
      _loadConfig(path.join(widget.workingDir!, 'launsh.json'));
    }
  }

  Future<void> _loadConfig(String? path) async {
    if (path == null) {
      setState(() {
        _config = null;
      });
      return;
    }
    try {
      final file = File(path);
      final jsonStr = await file.readAsString();
      final jsonMap = json.decode(jsonStr) as Map<String, dynamic>;
      final config = Config.fromJson(jsonMap);
      config.validate();

      setState(() {
        _config = config;
      });
    } catch (e) {
      widget.onLog('Error loading config: $e');
      setState(() {
        _config = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Entrypoints',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (widget.workingDir != null && _config != null)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: _config!.entrypoints.entries.map((entry) {
                final name = entry.key;
                final execution = entry.value;
                return EntrypointElement(
                  // Using a key is good practice for lists of stateful widgets
                  key: ValueKey(name),
                  workingDir: widget.workingDir!,
                  name: name,
                  entrypoint: execution,
                  onLog: widget.onLog,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
