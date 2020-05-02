import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'dart:io';


class LocalImageState {
  final String localImageUri;
  final List<int> localImageThumbnail;
  final bool isLoading;


  LocalImageState({
    @required this.localImageUri,
    @required this.localImageThumbnail,
    @required this.isLoading,
  });

  factory LocalImageState.initial() {
    return LocalImageState(localImageUri: '',localImageThumbnail: [], isLoading: false);
    //print("Init remote image state");
  }

  LocalImageState copyWith({
    String localImageUri,
    List<int> localImageThumbnail,
    bool isLoading,
  }) {
    return LocalImageState(
      localImageUri: localImageUri ?? this.localImageUri,
      localImageThumbnail: localImageThumbnail ?? this.localImageThumbnail,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LocalImageDetailState {
  final String localImageUri;
  final List<int> localImageData;
  final bool isLoading;


  LocalImageDetailState({
    @required this.localImageUri,
    @required this.localImageData,
    @required this.isLoading,
  });

  factory LocalImageDetailState.initial() {
    return LocalImageDetailState(localImageUri: '',localImageData: [], isLoading: false);
    //print("Init remote image state");
  }

  LocalImageDetailState copyWith({
    String localImageUri,
    List<int> localImageThumbnail,
  }) {
    return LocalImageDetailState(
      localImageUri: localImageUri ?? this.localImageUri,
      localImageData: localImageData ?? this.localImageData,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}