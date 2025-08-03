import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:launsh/component/execution_entry.dart';
import 'package:launsh/schema/config.dart';
import 'package:path/path.dart' as path;

class ExecutionList extends StatefulWidget {
  final String? workingDir;
  final LogCallback onLog;

  const ExecutionList({
    super.key,
    required this.workingDir,
    required this.onLog,
  });

  @override
  State<ExecutionList> createState() => _ExecutionListState();
}

class _ExecutionListState extends State<ExecutionList> {
  Config? _config;

  @override
  void didUpdateWidget(covariant ExecutionList oldWidget) {
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
    if (widget.workingDir == null) {
      return const Center(child: Text('Please select a working directory.'));
    }
    if (_config == null) {
      return const Center(child: Text('Loading or failed to load config...'));
    }
    return ListView(
      padding: const EdgeInsets.all(8),
      children: _config!.executions.entries.map((entry) {
        final name = entry.key;
        final execution = entry.value;
        return ExecutionEntry(
          // Using a key is good practice for lists of stateful widgets
          key: ValueKey(name),
          workingDir: widget.workingDir!,
          name: name,
          execution: execution,
          onLog: widget.onLog,
        );
      }).toList(),
    );
  }
}
