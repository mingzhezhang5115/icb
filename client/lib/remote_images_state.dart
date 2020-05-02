import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:flutter_app/remote_image_state.dart';
class RemoteImagesState {
  final int remoteImagesTotalCount;
  final List<RemoteImageState> remoteImages;
  final int head;
  final int next;
  final int page;
  final bool isFetching;
  final String currentTag;
  final PageController pageController = PageController();

  RemoteImagesState({
    @required this.remoteImagesTotalCount,
    @required this.head,
    @required this.remoteImages,
    @required this.next,
    @required this.page,
    @required this.isFetching,
    @required this.currentTag,
    //@required this.pageController
  });

  factory RemoteImagesState.initial(){
    return RemoteImagesState(remoteImagesTotalCount:0,head:0, remoteImages:[],next:0, page: 0, isFetching: false, currentTag: "");
    //print("Init remote image state");
  }

  RemoteImagesState copyWith({
    int remoteImagesTotalCount,
    List<RemoteImageState> remoteImages,
    int head,
    int next,
    int page,
    bool isFetching,
    String currentTag,
  }) {
    return RemoteImagesState(
      remoteImagesTotalCount: remoteImagesTotalCount ?? this.remoteImagesTotalCount,
      remoteImages: remoteImages ?? this.remoteImages,
      head: head ?? this.head,
      next: next ?? this.next,
      page: page ?? this.page,
      isFetching: isFetching ?? this.isFetching,
      currentTag: currentTag ?? this.currentTag,
      //pageController: this.pageController,
    );
  }
}