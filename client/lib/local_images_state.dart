import 'package:meta/meta.dart';
import 'package:flutter_app/local_image_state.dart';
class LocalImagesState {
  final int localImagesTotalCount;
  final List<LocalImageState> localImages;
  final int head;
  final int next;
  final bool isFetching;

  LocalImagesState({
    @required this.localImagesTotalCount,
    @required this.head,
    @required this.localImages,
    @required this.next,
    @required this.isFetching,
  });

  factory LocalImagesState.initial(){
    return LocalImagesState(localImagesTotalCount:0,head:0, localImages:[],next:0, isFetching: false);
    //print("Init remote image state");
  }

  LocalImagesState copyWith({
    int localImagesTotalCount,
    List<LocalImageState> localImages,
    int head,
    int next,
    bool isFetching,
  }) {
    return LocalImagesState(
      localImagesTotalCount: localImagesTotalCount ?? this.localImagesTotalCount,
      localImages: localImages ?? this.localImages,
      head: head ?? this.head,
      next: next ?? this.next,
      isFetching: isFetching ?? this.isFetching,
    );
  }
}