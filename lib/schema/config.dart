import 'package:json_annotation/json_annotation.dart';
import 'package:launsh/schema/execution.dart';

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
}