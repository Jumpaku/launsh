import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:launsh/component/app_log.dart';
import 'package:launsh/component/app_log_controller.dart';
import 'package:launsh/component/entrypoint_list.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

class LaunshPage extends StatefulWidget {
  const LaunshPage({super.key});

  @override
  State<LaunshPage> createState() => _LaunshPageState();
}

class _LaunshPageState extends State<LaunshPage> {
  String? _workingDir;
  final AppLogController _logController = AppLogController();
  double _leftPanelFraction = 0.6; // 左パネルの幅割合
  static const double _minPanelFraction = 0.2;
  static const double _maxPanelFraction = 0.8;

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
          // 上部にフォルダ選択コントロール
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
                  ElevatedButton.icon(
                    icon: const Icon(Icons.description),
                    label: const Text('Open Config'),
                    onPressed: () async {
                      final configPath = path.join(_workingDir!, 'launsh.json');
                      final uri = Uri.file(configPath);
                      if (!await launchUrl(uri)) {
                        _logController.add(
                          'Could not open config file: $configPath',
                        );
                      }
                    },
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
          // 下部にExecutionListとAppLogを左右に並べる（ドラッグ可能な分割線付き）
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final leftWidth = width * _leftPanelFraction;
                final rightWidth = width * (1 - _leftPanelFraction);
                return Row(
                  children: [
                    SizedBox(
                      width: leftWidth,
                      child: EntrypointList(
                        workingDir: _workingDir,
                        onLog: _logController.add,
                      ),
                    ),
                    // ドラッグ可能な分割線
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _leftPanelFraction += details.delta.dx / width;
                          _leftPanelFraction = _leftPanelFraction.clamp(
                            _minPanelFraction,
                            _maxPanelFraction,
                          );
                        });
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeColumn,
                        child: Container(
                          width: 8,
                          height: double.infinity,
                          color: Colors.grey[300],
                          child: const Center(
                            child: VerticalDivider(
                              width: 8,
                              thickness: 2,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: rightWidth - 8, // 分割線の幅を引く
                      child: AppLog(controller: _logController),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
