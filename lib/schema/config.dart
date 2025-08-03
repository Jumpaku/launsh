import 'package:json_annotation/json_annotation.dart';
import 'package:launsh/schema/execution.dart';
import 'package:path/path.dart' as path;

part 'config.g.dart';

/// Represents the root configuration object from launsh.json.
@JsonSerializable(createToJson: false)
class Config {
  const Config({
    this.executions = const {},
  });

  /// Creates a Config from a JSON object.
  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

  /// A map of all defined executions, where the key is the execution name.
  final Map<String, Execution> executions;

  /// Validates configuration.
  void validate() {
    for (final entry in executions.entries) {
      final name = entry.key;
      final execution = entry.value;
      if (execution.stderr != null && path.isAbsolute(execution.stderr!)) {
        throw Exception("'stderr' in the execution '$name' must be a relative path");
      }
      if (execution.stdout != null && path.isAbsolute(execution.stdout!)) {
        throw Exception("'stdout' in the execution '$name' must be a relative path");
      }
    }
  }
}