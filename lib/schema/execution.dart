import 'package:json_annotation/json_annotation.dart';

part 'execution.g.dart';

/// Represents a single executable command configuration.
@JsonSerializable(createToJson: false)
class Execution {
  const Execution({
    this.description,
    required this.program,
    this.args = const [],
    this.workingDir,
    this.environment = const {},
    this.variable = const [],
    this.stdout,
    this.stderr,
  });

  /// Creates an Execution from a JSON object.
  factory Execution.fromJson(Map<String, dynamic> json) =>
      _$ExecutionFromJson(json);

  /// A description of what the execution does.
  final String? description;

  /// The entrypoint of the execution.
  final String program;

  /// A list of arguments for the execution.
  final List<String> args;

  /// The working directory from which to run the execution.
  @JsonKey(name: 'working_dir')
  final String? workingDir;

  /// A map of environment variables for the execution.
  final Map<String, String> environment;

  /// A list of variables for the execution.
  final List<String> variable;

  /// The path to a file to which standard output is redirected.
  final String? stdout;

  /// The path to a file to which standard error is redirected.
  final String? stderr;
}