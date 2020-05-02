// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_images_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalImageInfo _$LocalImageInfoFromJson(Map<String, dynamic> json) {
  return LocalImageInfo(
    imageCount: json['imageCount'] as int,
    localImages: (json['localImages'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k, (e as List).map((e) => e as int).toList()),
    ),
  );
}

Map<String, dynamic> _$LocalImageInfoToJson(LocalImageInfo instance) =>
    <String, dynamic>{
      'imageCount': instance.imageCount,
      'localImages': instance.localImages,
    };
