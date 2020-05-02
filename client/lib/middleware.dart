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
import 'package:flutter_app/local_image_detail.dart';
import 'package:flutter_app/local_images_state.dart';
import 'package:flutter_app/local_image_state.dart';
import 'package:flutter_app/nav_key.dart';
import 'package:flutter_app/reducers.dart';
import 'package:flutter_app/bottom_nav_bar.dart';
import 'package:flutter_app/remote_images_state.dart';
import 'package:flutter_app/remote_image_state.dart';
import 'package:flutter_app/http_handlers.dart';
import 'package:flutter_app/local_images_info.dart';
import 'package:flutter_app/remote_sum_screen.dart';
import 'package:flutter_app/middleware.dart';
import 'package:flutter_app/remote_tags_state.dart';
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
import 'package:flutter_share/flutter_share.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const platform = const MethodChannel('app.channel.shared.data');

/*    case FetchRemoteImagesCountAction:
      {
        try {
          var remoteImagesCount = await fetchPost();

          remoteImagesCount.toString();
          developer.log('Get remote count' + remoteImagesCount.toString(),
              name: 'Add new sync directory');
          var remoteImagesState = RemoteImagesState(
              remoteImagesTotalCount: int.parse(remoteImagesCount),
              head: 0,
              remoteImages: [],
              next: 1);
          store.dispatch(
              new FetchRemoteImagesCountSucceededAction(remoteImagesState));
        } catch (e) {
          store.dispatch(new FetchRemoteImagesCountFailedAction());
        }
      }
      break;*/

fetchListMiddleware(
    Store<MyAppState> store, action, NextDispatcher next) async {
  switch (action.runtimeType) {
    case GetLocalImagesCountAction:
      {
        developer.log('GetLocalmagesCountAction', name: 'middleware');
        var imagesInfo =
            await platform.invokeMethod("getImagesCount", <String, dynamic>{
          'start': store.state.localImagesState.next,
          'count': 15,
        });
        //print("*********************************");
        //print(imagesInfo);
        //print("*********************************");
        var imagesInfoJson = json.decode(imagesInfo);
        var localImagesInfo = LocalImageInfo.fromJson(imagesInfoJson);
        //print(localImagesInfo.localThumbnail);
        var imagesCount = localImagesInfo.imageCount;
        print('GetLocalmagesCountAction:' + imagesCount.toString());
        developer.log('GetLocalmagesCountAction:' + imagesCount.toString(),
            name: 'middleware');
        List<LocalImageState> localImageStateList = [];
        localImagesInfo.localImages.forEach((k, v) {
          localImageStateList
              .add(LocalImageState(localImageUri: k, localImageThumbnail: v));
        });
        var localImagesState = LocalImagesState(
            localImagesTotalCount: imagesCount,
            head: 0,
            localImages: localImageStateList,
            next: localImagesInfo.localImages.length,
            isFetching: false);
        store
            .dispatch(new GetLocalImagesCountSucceededAction(localImagesState));
      }
      break;
    case GetLocalImagesListAction:
      {
        developer.log('GetLocalImagesListAction', name: 'middleware');
        var imagesInfo;
        developer.log('GetLocalImagesListAction', name: 'Local images length' + store.state.localImagesState.localImages.length.toString());
        if (store.state.localImagesState.localImages.length != 0 && store.state.localImagesState.localImages[action.index] ==null){
          imagesInfo = await platform.invokeMethod("getImagesCount", <String, dynamic>{
            'start': action.index,
            'count': 15,
          });
        } else {
          imagesInfo =
          await platform.invokeMethod("getImagesCount", <String, dynamic>{
            'start': action.index,
            'count': 15,
          });
        }
        //print("*********************************");
        //print(imagesInfo);
        //print("*********************************");
        var imagesInfoJson = json.decode(imagesInfo);
        var localImagesInfo = LocalImageInfo.fromJson(imagesInfoJson);
        //print(localImagesInfo.localThumbnail);
        var imagesCount = localImagesInfo.imageCount;
        print('GetLocalmagesCountAction:' + imagesCount.toString());
        developer.log('GetLocalmagesCountAction:' + imagesCount.toString(),
            name: 'middleware');
        List<LocalImageState> localImageStateList;
        if (store.state.localImagesState.localImages.length == 0){
          localImageStateList = new List<LocalImageState>(imagesCount);
        }
        else {
          if(imagesCount != store.state.localImagesState.localImages.length){
            localImageStateList = new List<LocalImageState>(imagesCount);
          } else {
            localImageStateList = store.state.localImagesState.localImages.sublist(0,action.index) + new List<LocalImageState>(localImagesInfo.localImages.length) +
                store.state.localImagesState.localImages.sublist(action.index+localImagesInfo.localImages.length,store.state.localImagesState.localImages.length);
               // List.from(store.state.localImagesState.localImages);
          }
        }
        var j = 0;
        localImagesInfo.localImages.forEach((k, v) {
          localImageStateList[action.index + j] = LocalImageState(localImageUri: k, localImageThumbnail: v);
          j += 1;
        });
        var localImagesState = LocalImagesState(
            localImagesTotalCount: imagesCount,
            head: 0,
            localImages: localImageStateList,
            next: localImageStateList.length,
            isFetching: false);
        store
            .dispatch(new GetLocalImagesListSucceededAction(localImagesState));
      }
      break;
    case UploadImageAction:
      {
        developer.log('uploadImageAction', name: 'middleware');
        var imagesInfo =
        await platform.invokeMethod("uploadImage", <String, dynamic>{
          'uri': action.imageUri,
        });
        store.dispatch(new UploadImageSucceededAction());
      }
      break;
    case ConfirmImageTagAction:
      {
        developer.log('ConfirmImageTagAction', name: 'middleware');
        print("ConfirmImageTagAction middleware");
        //var testServerAddr = action.testServerAddr;
        var confirmTagOk = await confirmImageTag(
            store.state.remoteImageDetail.remoteImageUUID, testServerAddr: store.state.settingsState.testServerAddr);
        store.dispatch(new ConfirmImageTagSucceededAction());
      }
      break;
    case UploadAllLocalImagesAction:
      {
        developer.log('UploadAllLocalImagesAction', name: 'middleware');
        await platform.invokeMethod("uploadLocalAll");
        store.dispatch(new UploadAllLocalImagesSucceededAction());
      }
      break;

    case FetchSyncingDirsAction:
      {
        developer.log('FetchSyncingDirsAction mid', name: 'middleware');
        print('FetchSyncingDirsAction mid');
      }
      break;
    case FetchRemoteImagesSummaryAction:
      {
        print("Fetching remote imagte summary from" + action.testServerAddr);
        //var testServerAddr = action.testServerAddr;
        var remoteImagesSummary = await fetchList(
            store.state.remoteImagesState.next.toString(), "15", testServerAddr: action.testServerAddr);
        print(remoteImagesSummary.body);
        var remoteImagesSummaryJson = json.decode(remoteImagesSummary.body);
        var remoteImages = List<RemoteImageState>.from(
            store.state.remoteImagesState.remoteImages);
        //print("New image list before add");
        //remoteImages.forEach((i) => {print(i.remoteImageUUID)});
        //print("New image list before add end");

        remoteImagesSummaryJson['images'].forEach((i) =>
            //print(i['image_uuid']);

            remoteImages.add(RemoteImageState(
                remoteImageThumbnailUrl: i['url'],
                remoteImageUrl: i['url'],
                remoteImageUUID: i['image_uuid'],
                remoteImageTags: [])));
        var remoteImageCount =
            int.parse(remoteImagesSummary.headers["x-total-count"]);
        var remoteImagesState = RemoteImagesState(
          remoteImagesTotalCount: remoteImageCount,
          remoteImages: remoteImages,
          head: 0,
          next: min(remoteImageCount, remoteImages.length),
          isFetching: false,
        );
        //store.state.copyWith(remoteImagesState: remoteImagesState);
       // print("New image list");
       // remoteImagesState.remoteImages
        //    .forEach((i) => {print(i.remoteImageUUID)});
        //print("New image list end");
        store.dispatch(
            new FetchRemoteImagesSummarySucceededAction(remoteImagesState));
      }
      break;
    case FetchRemoteImagesListAction:
      {
        //store.dispatch(new ToFetchRemoteImagesListAction());
        developer.log('FetchRemoteImagesListAction mid', name: 'middleware');
        print('FetchSyncingDirsAction mid');
        print("testServerAddr in state" + store.state.settingsState.testServerAddr.toString());
        print("action testserver addr" + action.testServerAddr);
        var remoteImagesSummary;
        if(action.testServerAddr != ""){
          remoteImagesSummary = await fetchList(
              action.index.toString(), "15",testServerAddr: action.testServerAddr);
        } else if (store.state.remoteImagesState.isFetching) {
          remoteImagesSummary = await fetchList(
              action.index.toString(), "15",
              testServerAddr: store.state.settingsState.testServerAddr);
        }
        if (remoteImagesSummary !=null){
          print(remoteImagesSummary.body);
          var remoteImagesSummaryJson = json.decode(remoteImagesSummary.body);
          var remoteImages;
          var remoteImageCount =
          int.parse(remoteImagesSummary.headers["x-total-count"]);
          if (remoteImageCount != store.state.remoteImagesState.remoteImages.length){
            remoteImages = List<RemoteImageState>(remoteImageCount);
          } else {
            remoteImages = store.state.remoteImagesState.remoteImages.sublist(0,action.index) + List<RemoteImageState>(remoteImagesSummaryJson['images'].length) + store.state.remoteImagesState.remoteImages.sublist(action.index + remoteImagesSummaryJson['images'].length, store.state.remoteImagesState.remoteImages.length);
          }
          var j = 0;
          for (var i in remoteImagesSummaryJson['images']) {
            remoteImages[action.index + j] = RemoteImageState(
                remoteImageThumbnailUrl: i['url'],
                remoteImageUrl: i['url'],
                remoteImageUUID: i['image_uuid'],
                remoteImageTags: []);
            j += 1;
          }

          var remoteImagesState = RemoteImagesState(
            remoteImagesTotalCount: remoteImageCount,
            remoteImages: remoteImages,
            head: 0,
            next: min(remoteImageCount, remoteImages.length),
            isFetching: false,
          );
          store.dispatch(
              new FetchRemoteImagesListSucceededAction(remoteImagesState));
        }
      }
      break;
    case RefreshRemoteImagesListAction:
      {
        developer.log('RefreshRemoteImagesListAction mid', name: 'middleware');
        print('RefreshRemoteImagesListAction mid');

        var remoteImagesSummary = await fetchList("0", "15",testServerAddr: store.state.settingsState.testServerAddr);
        print(remoteImagesSummary.body);
        var remoteImagesSummaryJson = json.decode(remoteImagesSummary.body);
        List<RemoteImageState> remoteImages = [];

        remoteImagesSummaryJson['images'].forEach((i) =>
            //print(i['image_uuid']);
            remoteImages.add(RemoteImageState(
                remoteImageThumbnailUrl: i['url'],
                remoteImageUrl: i['url'],
                remoteImageUUID: i['image_uuid'],
                remoteImageTags: [])));
        var remoteImageCount =
            int.parse(remoteImagesSummary.headers["x-total-count"]);
        var remoteImagesState = RemoteImagesState(
          remoteImagesTotalCount: remoteImageCount,
          remoteImages: remoteImages,
          head: 0,
          next: min(remoteImageCount, remoteImages.length),
          isFetching: false,
        );
        //store.state.copyWith(remoteImagesState: remoteImagesState);
        print("New image list");
        remoteImagesState.remoteImages
            .forEach((i) => {print(i.remoteImageUUID)});
        print("New image list end");
        store.dispatch(
            new RefreshRemoteImagesListSucceededAction(remoteImagesState));
      }
      break;
    case RefreshLocalImagesListAction:
      {
        developer.log('RefreshLocalImagesListAction mid', name: 'middleware');
        print('RefreshLocalImagesListAction mid');
        var imagesInfo =
        await platform.invokeMethod("getImagesCount", <String, dynamic>{
          'start': 0,
          'count': 15,
        });
        print("*********************************");
        print(imagesInfo);
        print("*********************************");
        var imagesInfoJson = json.decode(imagesInfo);
        var localImagesInfo = LocalImageInfo.fromJson(imagesInfoJson);
        //print(localImagesInfo.localThumbnail);
        var imagesCount = localImagesInfo.imageCount;
        print('GetLocalmagesCountAction:' + imagesCount.toString());
        developer.log('GetLocalmagesCountAction:' + imagesCount.toString(),
            name: 'middleware');
        List<LocalImageState> localImageStateList = [];
        localImagesInfo.localImages.forEach((k, v) {
          localImageStateList
              .add(LocalImageState(localImageUri: k, localImageThumbnail: v));
        });
        var localImagesState = LocalImagesState(
            localImagesTotalCount: imagesCount,
            head: 0,
            localImages: localImageStateList,
            next: localImageStateList.length,
            isFetching: false);
        store
            .dispatch(new RefreshLocalImagesListSucceededAction(localImagesState));

      }
      break;
    case FetchRemoteImageDetailAction:
      {
        var remoteImageDetail = await fetchDetail(action.imageUUID,testServerAddr: store.state.settingsState.testServerAddr);
        var remoteImagesDetailJson = json.decode(remoteImageDetail.body);
        var remoteImageTags = {};
        for (var tag_name in remoteImagesDetailJson['image_tags']) {
          remoteImageTags[tag_name] = false;
        }
        ;
        store.dispatch(
            new FetchRemoteImageDetailSucceededAction(RemoteImageDetailState(
          remoteImageUUID: remoteImagesDetailJson['image_uuid'],
          remoteImageUrl: remoteImagesDetailJson['image_url'],
          remoteImageThumbnailUrl: remoteImagesDetailJson['image_thumbnail_url'],
          remoteImageTags: remoteImageTags,
              remoteImageTagConfirmed: remoteImagesDetailJson['tag_confirmed'],
        )));
      }
      break;
    case FetchRemoteTagsAction:
      {
        var remoteTags = await fetchTags(testServerAddr: store.state.settingsState.testServerAddr);
        var remoteTagsJson = json.decode(remoteTags.body);
        Map<String,int> remoteImageTags = {};
        remoteTagsJson['tags'].forEach(
          (k,v){
            print(k);
            print(v);
            remoteImageTags[k] = v;
        });
        var remoteTagsState = RemoteTagsState(tags:remoteImageTags);
        print(remoteTagsState.tags.keys.toList().toString());
        store.dispatch(
            new FetchRemoteTagsSucceededAction(remoteTagsState));
      }
      break;
    case goToIamgeListByTagScreenAction:{
      store.dispatch(FetchRemoteImagesListByTagAction(0,action.tag));
    }
    break;
    case FetchRemoteImagesListByTagAction:
      {
        var remoteImageListByTag;
        if(action.tag == store.state.remoteImagesByTagState.currentTag) {
          print("Fech images by tag middleware start from ${action.index}");
              remoteImageListByTag = await fetchImagesByTag(action.tag,
              action.index.toString().trim(), "15",testServerAddr: store.state.settingsState.testServerAddr);
        }
        else{
              remoteImageListByTag = await fetchImagesByTag(action.tag,
              action.index.toString(), "15",testServerAddr: store.state.settingsState.testServerAddr);
        }
        var remoteImageListJson = json.decode(remoteImageListByTag.body);
        //var remoteImages = List<RemoteImageState>.from(
        //    store.state.remoteImagesState.remoteImages);
        var remoteImageCount =
        remoteImageListJson["count"];
        var remoteImages;
        if(action.tag == store.state.remoteImagesByTagState.currentTag) {
          if(remoteImageCount == store.state.remoteImagesByTagState.remoteImages.length) {
            remoteImages =
                store.state.remoteImagesByTagState.remoteImages.sublist(
                    0, action.index) + List<RemoteImageState>(
                    remoteImageListJson['images'].length) +
                    store.state.remoteImagesByTagState.remoteImages.sublist(
                        action.index + remoteImageListJson['images'].length,
                        store.state.remoteImagesByTagState.remoteImages.length);
          }
        }else{
          remoteImages = List<RemoteImageState>(remoteImageCount);
        }
        var j = 0;
        for (var i in remoteImageListJson['images']){
            remoteImages[action.index + j] = RemoteImageState(
                remoteImageThumbnailUrl: i['url'],
                remoteImageUrl: i['url'],
                remoteImageUUID: i['image_uuid'],
                remoteImageTags: []);
            j += 1;
        }

        var remoteImagesState = RemoteImagesState(
          remoteImagesTotalCount: remoteImageCount,
          remoteImages: remoteImages,
          head: 0,
          next: min(remoteImageCount, remoteImages.length),
          isFetching: false,
          currentTag: action.tag,
        );
        store.dispatch(
            new FetchRemoteImagesListByTagSucceededAction(remoteImagesState));
      }
      break;
    case GetLocalImageDetailAction:
      {
        developer.log('GetLocalDetailAction', name: 'middleware');
        print(action.imageUri);
        var imagesInfo =
        await platform.invokeMethod("getImageDetail", <String, dynamic>{
          'uri': action.imageUri,
        });
        print("*********************************");
        print(imagesInfo);
        print("*********************************");
        var imagesInfoJson = json.decode(imagesInfo);
        //imagesInfoJson[""]
        var localImageDetail = LocalImageDetail.fromJson(imagesInfoJson);
        //print(localImagesInfo.localThumbnail);
        // var imagesCount = localImagesInfo.imageCount;
        print("Local Image Data");
        print(localImageDetail.imageData);
        var localImageDetailState = LocalImageDetailState(localImageUri: localImageDetail.imageUri,localImageData: localImageDetail.imageData);
        store.dispatch(
            new GoLocalDetailAction(localImageDetailState
            ));
      }
      break;
    case FetchRemoteImageDetailSucceededAction:
      {}
      break;
    case UpdateImageTagsAction:
      {
        print("UpdateImageTagsAction middleware");
        var tags = List<String>.from(
            store.state.remoteImageDetail.remoteImageTags.keys);
        print("UpdateImageTagsAction from tags middleware");
        tags.add(
            store.state.remoteImageDetail.textEditingController.value.text);
        print("UpdateImageTagsAction add new tag middleware");
        //store.dispatch(new UpdateImageTagsAction());
        //print(tags.)
        var resp = await updateImageTags(
            store.state.remoteImageDetail.remoteImageUUID, tags);
        print(resp.body);
        store.dispatch(new UpdateImageTagsSucceededAction(tags));
      }
      break;
    case DeleteImageTagAction:
      {
        print("DeleteImageTagsAction middleware");

        //store.dispatch(new UpdateImageTagsAction());
        //print(tags.)
        var resp = await deleteImageTag(
            store.state.remoteImageDetail.remoteImageUUID, action.tagName,testServerAddr: store.state.settingsState.testServerAddr);
        print(resp.body);
        store.dispatch(new DeleteImageTagSucceededAction(action.tagName));
      }
      break;
    case AddImageTagAction:
      {
        print("AddImageTagsAction middleware");
        //store.dispatch(new UpdateImageTagsAction());
        //print(tags.)
        var resp = await addImageTag(
            store.state.remoteImageDetail.remoteImageUUID, action.tagName, testServerAddr: store.state.settingsState.testServerAddr);
        print(resp.body);
        store.dispatch(new AddImageTagSucceededAction(action.tagName));
      }
      break;
    case LoadSettingsAction:
      {
        print("LoadSettingsAction middleware");
        //store.dispatch(new UpdateImageTagsAction());
        //print(tags.)
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String testServerAddr = prefs.getString('testServerAddr') ?? "";
        var syncingDirs = prefs.getStringList("syncingDirs") ?? [];
        var settingsState = SettingsState(
            testServerAddr: testServerAddr, syncingDirs: syncingDirs);
        store.dispatch(new LoadSettingsSucceededAction(settingsState));
        store.dispatch(new FetchRemoteImagesListAction(0, testServerAddr: testServerAddr));
        //store.dispatch(new GetLocalImagesCountAction());
      }
      break;
    case UpdateTestServerAddrAction:
      {
        print("UpdateTestServerAddrAction middleware");
        //store.dispatch(new UpdateImageTagsAction());
        //print(tags.)
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var isOK = prefs.setString('testServerAddr', action.testServerAddr);
        var settingsState = store.state.settingsState
            .copyWith(testServerAddr: action.testServerAddr);
        store.dispatch(new LoadSettingsSucceededAction(settingsState));
      }
      break;
    case RefreshHomeAction:
      {
        store.dispatch(new GetLocalImagesListAction(0));
        store.dispatch(new ToFetchRemoteImagesListAction());
        store.dispatch(new FetchRemoteImagesListAction(0));
        store.dispatch(new RefreshHomeSucceededAction());
      }
      break;
    case ShowZoomableImageAction:
      {
        print("ShowZoomableImageAction in redux");
        File cachedImage = await getCachedImageFile(
            store.state.remoteImageDetail.remoteImageUrl);
        print(cachedImage);
        store.dispatch(new ShowZoomableImageSucceededAction(cachedImage));
        //Keys.navKey.currentState.pushNamed('/settings');
        //return state.copyWith(settingsState: action.settingsState);
        //Keys.navKey.currentState.pushNamed("/remote_image_zoomable");
      }
      break;
    case ShareFileAction:
      {
        print("ShareFileAction in redux");
        await FlutterShare.shareFile(
          title: 'Example share',
          text: 'Example share text',
          filePath: action.cachePath,
        );
        //Keys.navKey.currentState.pushNamed('/settings');
        //return state.copyWith(settingsState: action.settingsState);
        //Keys.navKey.currentState.pushNamed("/remote_image_zoomable");
      }
      break;
    case EmptyTestDatabaseAction:
      {
        print("EmptyTestDatabaseAction in mid");
        var databasesPath = await getDatabasesPath();
        String path = join(databasesPath, 'ICBReader.db');

// Delete the database
        await deleteDatabase(path);
        //Keys.navKey.currentState.pushNamed('/settings');
        //return state.copyWith(settingsState: action.settingsState);
        //Keys.navKey.currentState.pushNamed("/remote_image_zoomable");
      }
      break;
    default:
      {
        print("Ignore action in middleware");
      }
      break;
  }
/*  if(action is FetchSyncingDirsAction) {


*/ /*    var sharedData = await platform.invokeMethod("addDirectory");
    var myDirs = List<String>.from(sharedData);
    if (sharedData != null) {
      developer.log(sharedData.toString(), name: "Add new sync directory");

      store.dispatch(new FetchSyncingDirsSucceededAction(myDirs));
    } else if (sharedData == null) {
      developer.log('Failed', name: 'Add new sync directory');
      store.dispatch(new FetchSyncingDirsSucceededAction(["4", "5", "6"]));
    }*/ /*

  }
  else if(action is FetchRemoteImagesCountAction){
    var remoteImagesCount = await fetchPost();
    remoteImagesCount.toString();
    developer.log('Get remote count' + remoteImagesCount.toString(), name: 'Add new sync directory');
    store.dispatch(new FetchRemoteImagesCountSucceededAction(int.parse(remoteImagesCount)));
  }*/
  next(action);
}
