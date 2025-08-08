import 'package:json_annotation/json_annotation.dart';

part 'entrypoint.g.dart';

/// Represents a single executable command configuration.
@JsonSerializable(createToJson: false)
class Entrypoint {
  const Entrypoint({
    this.description,
    required this.program,
    this.args = const [],
    this.environment = const {},
    this.parameter = const [],
    this.stdout,
    this.stderr,
  });

  /// Creates an Entrypoint from a JSON object.
  factory Entrypoint.fromJson(Map<String, dynamic> json) =>
      _$EntrypointFromJson(json);

  /// A description of what the Entrypoint does.
  final String? description;

  /// The Entrypoint of the execution.
  final String program;

  /// A list of arguments for the entrypoint.
  final List<String> args;

  /// A map of environment variables for the entrypoint.
  final Map<String, String> environment;

  /// A list of parameters for the entrypoint.
  final List<String> parameter;

  /// The path to a file to which standard output is redirected.
  final String? stdout;

  /// The path to a file to which standard error is redirected.
  final String? stderr;
}