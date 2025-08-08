// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<String, dynamic> json) => Config(
  entrypoints:
      (json['entrypoints'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, Entrypoint.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
);
