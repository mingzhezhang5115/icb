import 'package:json_annotation/json_annotation.dart';


part 'local_images_info.g.dart';

@JsonSerializable(nullable: false)
class LocalImageInfo {
  final int imageCount;
  final Map<String,List<int>> localImages;

  LocalImageInfo({
    this.imageCount,
    this.localImages,
  });

  factory LocalImageInfo.fromJson(Map<String, dynamic> json) =>
      _$LocalImageInfoFromJson(json);

  Map<String, dynamic> toJson() => _$LocalImageInfoToJson(this);

}

