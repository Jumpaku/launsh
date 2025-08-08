import 'package:json_annotation/json_annotation.dart';
import 'package:launsh/schema/entrypoint.dart';
import 'package:path/path.dart' as path;

part 'config.g.dart';

/// Represents the root configuration object from launsh.json.
@JsonSerializable(createToJson: false)
class Config {
  const Config({
    this.entrypoints = const {},
  });

  /// Creates a Config from a JSON object.
  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

  /// A map of all defined entrypoints, where the key is the execution name.
  final Map<String, Entrypoint> entrypoints;

  /// Validates configuration.
  void validate() {
    for (final entry in entrypoints.entries) {
      final name = entry.key;
      final entrypoint = entry.value;
      if (entrypoint.stderr != null && path.isAbsolute(entrypoint.stderr!)) {
        throw Exception("'stderr' in the entrypoint '$name' must be a relative path");
      }
      if (entrypoint.stdout != null && path.isAbsolute(entrypoint.stdout!)) {
        throw Exception("'stdout' in the entrypoint '$name' must be a relative path");
      }
    }
  }
}