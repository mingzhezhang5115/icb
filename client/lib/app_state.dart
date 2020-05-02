import 'package:flutter_app/local_image_state.dart';
import 'package:flutter_app/remote_image_state.dart';
import 'package:flutter_app/remote_tags_state.dart';
import 'package:meta/meta.dart';
import 'package:flutter_app/remote_images_state.dart';
import 'package:flutter_app/local_images_state.dart';
import 'package:meta/meta.dart';
import 'package:flutter_app/settings_state.dart';
class MyAppState {
  final int bottomBarIndex;
  final List<String> syncingDirs;
  final RemoteImagesState remoteImagesState;
  final RemoteImagesState remoteImagesByTagState;
  final RemoteTagsState remoteTagsState;
  final LocalImagesState localImagesState;
  final RemoteImageDetailState remoteImageDetail;
  final LocalImageDetailState localImageDetail;
  final SettingsState settingsState;

  MyAppState({
    @required this.bottomBarIndex,
    @required this.syncingDirs,
    @required this.localImagesState,
    @required this.remoteImagesState,
    @required this.remoteImagesByTagState,
    @required this.remoteTagsState,
    @required this.remoteImageDetail,
    @required this.localImageDetail,
    @required this.settingsState,
  });

  factory MyAppState.initial() {
    return MyAppState(
        bottomBarIndex: 0,
        syncingDirs: [],
        localImagesState: LocalImagesState.initial(),
        remoteImagesState: RemoteImagesState.initial(),
        remoteImagesByTagState: RemoteImagesState.initial(),
        remoteImageDetail: RemoteImageDetailState.initial(),
        remoteTagsState: RemoteTagsState.initial(),
        localImageDetail: LocalImageDetailState.initial(),
        settingsState: SettingsState.initial());
  }

  MyAppState copyWith({
    int bottomBarIndex,
    List<String> syncingDirs,
    RemoteImagesState remoteImagesState,
    RemoteImagesState remoteImagesByTagState,
    RemoteTagsState remoteTagsState,
    LocalImagesState localImagesState,
    LocalImageDetailState localImageDetail,
    RemoteImageDetailState remoteImageDetail,
    SettingsState settingsState,
  }) {
    return MyAppState(
      bottomBarIndex: bottomBarIndex ?? this.bottomBarIndex,
      syncingDirs: syncingDirs ?? this.syncingDirs,
      remoteImagesState: remoteImagesState ?? this.remoteImagesState,
      remoteImagesByTagState: remoteImagesByTagState ?? this.remoteImagesByTagState,
      remoteImageDetail: remoteImageDetail ?? this.remoteImageDetail,
      remoteTagsState: remoteTagsState?? this.remoteTagsState,
      localImagesState: localImagesState ?? this.localImagesState,
      localImageDetail: localImageDetail?? this.localImageDetail,
      settingsState: settingsState ?? this.settingsState,
    );
  }
}
