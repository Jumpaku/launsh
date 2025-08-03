// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'execution.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Execution _$ExecutionFromJson(Map<String, dynamic> json) => Execution(
  description: json['description'] as String?,
  program: json['program'] as String,
  args:
      (json['args'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  environment:
      (json['environment'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  variable:
      (json['variable'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  stdout: json['stdout'] as String?,
  stderr: json['stderr'] as String?,
);
