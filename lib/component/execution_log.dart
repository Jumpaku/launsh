// lib/component/execution_log.dart

import 'package:flutter/material.dart';
import 'package:launsh/component/execution_log_controller.dart';

class ExecutionLog extends StatelessWidget {
  final ExecutionLogController controller;

  const ExecutionLog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Execution Log',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4.0),
                  color: Colors.grey.shade100,
                ),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Text(controller.log),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
