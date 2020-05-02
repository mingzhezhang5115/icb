import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'dart:io';


class RemoteImageState {
  final String remoteImageUrl;
  final List remoteImageTags;
  final String remoteImageThumbnailUrl;
  final String remoteImageUUID;
  final bool remoteImageTagConfirmed;


  RemoteImageState({
    @required this.remoteImageTags,
    @required this.remoteImageThumbnailUrl,
    @required this.remoteImageUrl,
    @required this.remoteImageUUID,
    @required this.remoteImageTagConfirmed,

  });

  factory RemoteImageState.initial() {
    return RemoteImageState(remoteImageThumbnailUrl: '',remoteImageTags: [],remoteImageUrl: '',remoteImageUUID: '', remoteImageTagConfirmed: false);
    //print("Init remote image state");
  }

  RemoteImageState copyWith({
    String remoteImageUrl,
    List<String> remoteImageTags,
    String remoteImageThumbnailUrl,
    String remoteImageUUID,
    bool remoteImageTagConfirmed,

  }) {
    return RemoteImageState(
      remoteImageUrl: remoteImageUrl ?? this.remoteImageUrl,
      remoteImageTags: remoteImageTags ?? this.remoteImageTags,
      remoteImageThumbnailUrl: remoteImageThumbnailUrl ?? this.remoteImageThumbnailUrl,
      remoteImageUUID: remoteImageUUID ?? this.remoteImageUUID,
      remoteImageTagConfirmed: remoteImageTagConfirmed ?? this.remoteImageTagConfirmed,

    );
  }
}

class RemoteImageDetailState {
  final String remoteImageUrl;
  final Map remoteImageTags;
  final String remoteImageThumbnailUrl;
  final String remoteImageUUID;
  final File remoteImageCache;
  final bool remoteImageTagConfirmed;
  final TextEditingController textEditingController = TextEditingController();
  //final Function updateImageTags = () {store.dispatch};

  RemoteImageDetailState({
    @required this.remoteImageTags,
    @required this.remoteImageThumbnailUrl,
    @required this.remoteImageUrl,
    @required this.remoteImageUUID,
    @required this.remoteImageCache,
    @required this.remoteImageTagConfirmed,
  });

  factory RemoteImageDetailState.initial() {
    return RemoteImageDetailState(remoteImageThumbnailUrl: '',remoteImageTags: {},remoteImageUrl: '',remoteImageUUID: '',remoteImageCache: File("assets/cat.jpg"), remoteImageTagConfirmed: false);
    //print("Init remote image state");
  }
  RemoteImageDetailState copyWith({
    String remoteImageUrl,
    Map remoteImageTags,
    String remoteImageThumbnailUrl,
    String remoteImageUUID,
    File remoteImageCache,
    bool remoteImageTagConfirmed
  }) {
    return RemoteImageDetailState(
      remoteImageUrl: remoteImageUrl ?? this.remoteImageUrl,
      remoteImageTags: remoteImageTags ?? this.remoteImageTags,
      remoteImageThumbnailUrl: remoteImageThumbnailUrl ?? this.remoteImageThumbnailUrl,
      remoteImageUUID: remoteImageUUID ?? this.remoteImageUUID,
      remoteImageCache: remoteImageCache ?? this.remoteImageCache,
      remoteImageTagConfirmed: remoteImageTagConfirmed ?? this.remoteImageTagConfirmed,
    );
  }
}