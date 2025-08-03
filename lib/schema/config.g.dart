// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<String, dynamic> json) => Config(
  executions:
      (json['executions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, Execution.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
);
