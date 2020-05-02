import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'dart:io';


class RemoteTagsState {
  final Map<String,int> tags;


  RemoteTagsState({
    @required this.tags,

  });

  factory RemoteTagsState.initial() {
    return RemoteTagsState(tags: {});
    //print("Init remote image state");
  }

  RemoteTagsState copyWith({
    Map<String,int> tags,


  }) {
    return RemoteTagsState(
      tags: tags ?? this.tags,
    );
  }
}