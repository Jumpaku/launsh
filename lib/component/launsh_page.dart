import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:launsh/component/execution_list.dart';
import 'package:launsh/component/app_log.dart';
import 'package:launsh/component/app_log_controller.dart';

class LaunshPage extends StatefulWidget {
  const LaunshPage({super.key});

  @override
  State<LaunshPage> createState() => _LaunshPageState();
}

class _LaunshPageState extends State<LaunshPage> {
  String? _configFilePath;
  final AppLogController _logController = AppLogController();

  Future<void> _pickAndLoadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      try {
        setState(() {
          _configFilePath = path;
          _logController.clear();
          _logController.add('Loaded configuration from: $path');
        });
      } catch (e) {
        _logController.add('Error loading or parsing config file: $e');
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
                  icon: const Icon(Icons.folder_open),
                  onPressed: _pickAndLoadFile,
                  label: const Text('Select Config File'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _configFilePath ?? 'No file selected',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_configFilePath != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Reload config file',
                    onPressed: () {
                      // Re-run the file load logic
                      if (_configFilePath != null) {
                        setState(() {
                          _logController.add('Reloaded configuration from: $_configFilePath');
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
              configFilePath: _configFilePath,
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
