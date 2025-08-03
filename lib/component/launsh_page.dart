import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:launsh/component/app_log.dart';
import 'package:launsh/component/app_log_controller.dart';
import 'package:launsh/component/execution_list.dart';
import 'package:path/path.dart' as path;

class LaunshPage extends StatefulWidget {
  const LaunshPage({super.key});

  @override
  State<LaunshPage> createState() => _LaunshPageState();
}

class _LaunshPageState extends State<LaunshPage> {
  String? _workingDir;
  final AppLogController _logController = AppLogController();

  Future<void> _pickWorkingDir() async {
    final workingDir = await FilePicker.platform.getDirectoryPath();

    if (workingDir != null) {
      final configFile = File(path.join(workingDir, 'launsh.json'));
      if (!configFile.existsSync()) {
        setState(() {
          _workingDir = null;
          _logController.add(
            'Config file "launsh.json" not found in the selected directory: $workingDir',
          );
        });
      } else {
        setState(() {
          _workingDir = workingDir;
          _logController.add('Selected working directory: $workingDir');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Launsh GUI')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.folder),
                  onPressed: _pickWorkingDir,
                  label: const Text('Select Working Directory'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _workingDir ?? 'No working directory selected',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_workingDir != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Reload working directory',
                    onPressed: () {
                      if (_workingDir != null) {
                        setState(() {
                          _logController.add(
                            'Reloaded working directory: $_workingDir',
                          );
                        });
                      }
                    },
                  ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            flex: 3,
            child: ExecutionList(
              workingDir: _workingDir,
              onLog: _logController.add,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(flex: 2, child: AppLog(controller: _logController)),
        ],
      ),
    );
  }
}
