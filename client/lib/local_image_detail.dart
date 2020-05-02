import 'package:json_annotation/json_annotation.dart';

part 'local_image_detail.g.dart';

@JsonSerializable(nullable: false)
class LocalImageDetail {
  final String imageUri;
  final List<int> imageData;

  LocalImageDetail({
    this.imageUri,
    this.imageData,
  });

  factory LocalImageDetail.fromJson(Map<String, dynamic> json) =>
      _$LocalImageDetailFromJson(json);

  Map<String, dynamic> toJson() => _$LocalImageDetailToJson(this);

}