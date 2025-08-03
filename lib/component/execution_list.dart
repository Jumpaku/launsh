import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:launsh/component/execution_entry.dart';
import 'package:launsh/schema/config.dart';

class ExecutionList extends StatefulWidget {
  final String? configFilePath;
  final LogCallback onLog;

  const ExecutionList({
    super.key,
    required this.configFilePath,
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
    _loadConfig(widget.configFilePath);
  }

  @override
  void initState() {
    super.initState();
    _loadConfig(widget.configFilePath);
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
    if (_config == null) {
      if (widget.configFilePath == null) {
        return const Center(child: Text('Please select a config file.'));
      } else {
        return const Center(child: Text('Loading or failed to load config...'));
      }
    }
    return ListView(
      padding: const EdgeInsets.all(8),
      children: _config!.executions.entries.map((entry) {
        final name = entry.key;
        final execution = entry.value;
        return ExecutionEntry(
          // Using a key is good practice for lists of stateful widgets
          key: ValueKey(name),
          configDir: path.dirname(widget.configFilePath!),
          name: name,
          execution: execution,
          onLog: widget.onLog,
        );
      }).toList(),
    );
  }
}
