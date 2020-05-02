// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_image_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalImageDetail _$LocalImageDetailFromJson(Map<String, dynamic> json) {
  return LocalImageDetail(
    imageUri: json['imageUri'] as String,
    imageData: (json['imageData'] as List).map((e) => e as int).toList(),
  );
}

Map<String, dynamic> _$LocalImageDetailToJson(LocalImageDetail instance) =>
    <String, dynamic>{
      'imageUri': instance.imageUri,
      'imageData': instance.imageData,
    };
