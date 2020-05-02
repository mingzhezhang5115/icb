
import 'package:flutter_app/local_image_state.dart';
import 'package:flutter_app/local_images_state.dart';
import 'package:flutter_app/remote_image_state.dart';
import 'package:flutter_app/remote_images_state.dart';
import 'package:flutter_app/settings_state.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';

//import 'dart:ffi';
//import 'dart:js';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/local_detail_page.dart';
import 'package:flutter_app/actions.dart';
import 'package:flutter_app/app_state.dart';
import 'package:flutter_app/nav_key.dart';
import 'package:flutter_app/reducers.dart';
import 'package:flutter_app/bottom_nav_bar.dart';
import 'package:flutter_app/remote_images_state.dart';
import 'package:flutter_app/remote_tags_state.dart';
import 'package:flutter_app/http_handlers.dart';
import 'package:flutter_app/local_images_info.dart';
import 'package:flutter_app/remote_sum_screen.dart';
import 'package:flutter_app/middleware.dart';
import 'package:flutter_app/settings.dart';
import 'package:flutter_app/settings_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:extended_image/extended_image.dart';

class FetchSyncingDirsAction {
}

class PressNavigationBarAction {
  final int bottomBarIndex;

  PressNavigationBarAction(this.bottomBarIndex);
}

class FetchSyncingDirsSucceededAction {
  final List<String> syncingDirs;

  FetchSyncingDirsSucceededAction(this.syncingDirs);
}

class FetchRemoteImagesCountAction {
}

class ToFetchRemoteImagesListAction {

}

class FetchRemoteImagesListAction {
    final int index;
    final String testServerAddr;
    FetchRemoteImagesListAction(this.index, {this.testServerAddr: ""});
}
class FetchRemoteImagesListSucceededAction {
  final RemoteImagesState remoteImagesState;
  FetchRemoteImagesListSucceededAction(this.remoteImagesState);
}

class FetchRemoteImagesListByTagAction{
  final String tag;
  final int index;
  FetchRemoteImagesListByTagAction(this.index,this.tag);
}
class FetchRemoteImagesListByTagSucceededAction {
  final RemoteImagesState remoteImagesState;
  FetchRemoteImagesListByTagSucceededAction(this.remoteImagesState);
}

class RefreshRemoteImagesListAction {

}
class RefreshRemoteImagesListSucceededAction {
  final RemoteImagesState remoteImagesState;
  RefreshRemoteImagesListSucceededAction(this.remoteImagesState);
}

class FetchRemoteImagesCountSucceededAction {
  final RemoteImagesState remoteImagesState;
  FetchRemoteImagesCountSucceededAction(this.remoteImagesState);
}

class FetchRemoteImagesSummaryAction {
  final String testServerAddr;
  FetchRemoteImagesSummaryAction(this.testServerAddr);
}

class FetchRemoteImagesSummarySucceededAction {
  final RemoteImagesState remoteImagesState;
  FetchRemoteImagesSummarySucceededAction(this.remoteImagesState);
}

class FetchRemoteImagesCountFailedAction {
  FetchRemoteImagesCountFailedAction();
}

class FetchRemoteImageDetailAction{
  final String imageUUID;
  FetchRemoteImageDetailAction(this.imageUUID);
}

class FetchRemoteTagsAction{

}

class FetchRemoteTagsSucceededAction{
    final RemoteTagsState remoteTagsState;
    FetchRemoteTagsSucceededAction(this.remoteTagsState);
}

class FetchRemoteImageDetailSucceededAction{
  final RemoteImageDetailState remoteImageState;
  FetchRemoteImageDetailSucceededAction(this.remoteImageState);
}

class GetLocalImagesCountAction {
}
class GetLocalImagesCountFailedAction {
}
class GetLocalImagesCountSucceededAction {
  final LocalImagesState localImagesState;
  GetLocalImagesCountSucceededAction(this.localImagesState);
}

class GoLocalDetailAction {
  final LocalImageDetailState localImageDetailState;
  GoLocalDetailAction(this.localImageDetailState);
}

class UpdateImageTagsAction {
}
class UpdateImageTagsSucceededAction {
  final List<String> tags;
  UpdateImageTagsSucceededAction(this.tags);
}
class GoToRemoteListScreenAction {
}

class DeleteImageTagAction{
  final String tagName;
  DeleteImageTagAction(this.tagName);

}

class DeleteImageTagSucceededAction{
  final String tagName;
  DeleteImageTagSucceededAction(this.tagName);
}

class AddImageTagAction{
  final String tagName;
  AddImageTagAction(this.tagName);

}

class AddImageTagSucceededAction{
  final String tagName;
  AddImageTagSucceededAction(this.tagName);
}

class SelectImageTagAction{
  final String tag_name;
  SelectImageTagAction(this.tag_name);

}

class GoHomeAction{

}

class GoSettingsAction{

}

class LoadSettingsAction{

}

class LoadSettingsSucceededAction{
    final SettingsState settingsState;
    LoadSettingsSucceededAction(this.settingsState);
}

class UpdateTestServerAddrAction{
  final String testServerAddr;
  UpdateTestServerAddrAction(this.testServerAddr);
}

class UpdateTestServerAddrSucceededAction{
  final SettingsState settingsState;
  UpdateTestServerAddrSucceededAction(this.settingsState);
}

class RefreshHomeAction{

}

class RefreshHomeSucceededAction{
  //final SettingsState settingsState;
  //UpdateTestServerAddrSucceededAction(this.settingsState);
}

class ShowZoomableImageAction{

}

class ShowZoomableImageSucceededAction{
  final File cachedImage;
  ShowZoomableImageSucceededAction(this.cachedImage);

}

class ShareFileAction{
  final String cachePath;
  ShareFileAction(this.cachePath);

}
class GetLocalImagesDetailAction{
  final String imageUri;
  GetLocalImagesDetailAction(this.imageUri);
}

class GetLocalImagesListAction{
  final int index;
  GetLocalImagesListAction(this.index);
}

class GetLocalImagesListSucceededAction{
  final LocalImagesState localImagesState;
  GetLocalImagesListSucceededAction(this.localImagesState);
}
class GoToLocalListScreenAction{

}
class ToGetLocalImagesListAction{


}

class RefreshLocalImagesListAction{

}

class RefreshLocalImagesListSucceededAction{
  final LocalImagesState localImagesState;
  RefreshLocalImagesListSucceededAction(this.localImagesState);
}

class GetLocalImageDetailAction{
  final String imageUri;
  GetLocalImageDetailAction(this.imageUri);
}
class GetLocalImageDetailSucceededAction{
  final LocalImageDetailState localImageDetailState;
  GetLocalImageDetailSucceededAction(this.localImageDetailState);
}

class ToFetchRemoteImagesListByTagAction{

}

class UploadImageAction{
  final String imageUri;
  UploadImageAction(this.imageUri);
}

class UploadImageSucceededAction{}

class UploadAllLocalImagesAction{

}

class UploadAllLocalImagesSucceededAction{

}

class goToIamgeListByTagScreenAction{
  final String tag;
  goToIamgeListByTagScreenAction(this.tag);
}
class OnPageChangedAction{

}

class EmptyTestDatabaseAction{

}

class ConfirmImageTagAction{

}

class ConfirmImageTagSucceededAction{

}