import 'package:flutter_app/actions.dart';
import 'package:flutter_app/app_state.dart';
import 'dart:developer' as developer;
import 'package:flutter_app/nav_key.dart';
import 'package:flutter/widgets.dart';

/*    case FetchRemoteImagesCountAction:{
      print('FetchRemoteImagesCountAction reduce');
      developer.log('FetchRemoteImagesCountAction', name: 'reducer');
    }
    break;*/

MyAppState counterReducer(MyAppState state, dynamic action) {
  switch(action.runtimeType){
    case FetchSyncingDirsAction:{
      print('FetchSyncingDirsAction reduce');
      developer.log('FetchSyncingDirsAction', name: 'reducer');
    }
    break;
    case FetchSyncingDirsSucceededAction:{
      print('FetchSyncingDirsAction done');
      return state.copyWith(syncingDirs: action.syncingDirs);
    }
    break;
    case PressNavigationBarAction:{
      print('PressNativationBarAction index' + action.bottomBarIndex.toString());
      developer.log('PressNativationBarAction', name: 'reducer');
      return state.copyWith(bottomBarIndex: action.bottomBarIndex );
    }
    break;

/*    case GetLocalImagesCountAction:{
      print('GetLocalmagesCountAction reduce');
      developer.log('GetLocalmagesCountAction', name: 'reducer');
    }
    break;*/
    case FetchRemoteImagesCountSucceededAction:{
      print('FetchRemoteImagesCountSucceededAction done');
      return state.copyWith(remoteImagesState: action.remoteImagesState);
    }
    break;
    case GetLocalImagesCountSucceededAction:{
      print('GetLocalImagesCountSucceededAction done');
      print(action.localImagesState.localImagesTotalCount);
      return state.copyWith(localImagesState: action.localImagesState);
    }
    break;
    case GoLocalDetailAction:{
      print('GoLocalDetailAction done');
      Keys.navKey.currentState.pushNamed("/local_detail");
      return state.copyWith(localImageDetail: action.localImageDetailState);
    }
    break;

    case FetchRemoteImagesCountSucceededAction:{
      Keys.navKey.currentState.pushNamed("/remote");
    }
    break;
    case FetchRemoteTagsSucceededAction:{
      Keys.navKey.currentState.pushNamed("/remote_tags");
      print(action.remoteTagsState.tags.keys.toList().toString());
      return state.copyWith(remoteTagsState: action.remoteTagsState);
    }
    break;
    case FetchRemoteImagesSummaryAction:{

    }
    break;
    case FetchRemoteImagesSummarySucceededAction:{
      //Keys.navKey.currentState.pushNamed("/remote");
      return state.copyWith(remoteImagesState: action.remoteImagesState);
      //Keys.navKey.currentState.pushNamed("/remote");
    }
    break;
    case ToFetchRemoteImagesListAction:{
      if (state.remoteImagesState.isFetching != true) {
        print("Set fetching to true in ToFetchRemoteImagesListAction");
        return state.copyWith(
            remoteImagesState: state.remoteImagesState.copyWith(
                isFetching: true));
      }
    }
    break;
    case ToFetchRemoteImagesListByTagAction:{
      if (state.remoteImagesByTagState.isFetching != true) {
        return state.copyWith(
            remoteImagesByTagState: state.remoteImagesByTagState.copyWith(
                isFetching: true));
      }
    }
    break;
    case ToGetLocalImagesListAction:{
      if (state.localImagesState.isFetching != true) {

        return state.copyWith(
            localImagesState: state.localImagesState.copyWith(
                isFetching: true));
      }
    }
    break;
    case ConfirmImageTagSucceededAction:{
      return state.copyWith(remoteImageDetail: state.remoteImageDetail.copyWith(remoteImageTagConfirmed: true));
    }
    case FetchRemoteImagesListSucceededAction:{
      print('FetchRemoteImagesListSucceededAction done');
      //print(ModalRoute.of(Keys.navKey.currentState.context).settings.name);

      //Keys.navKey.currentState.pushNamed("/remote");
      return state.copyWith(remoteImagesState: action.remoteImagesState);
    }
    break;

    case GetLocalImagesListSucceededAction:{
      print('GetLocalImagesListSucceededAction done');
      //print(ModalRoute.of(Keys.navKey.currentState.context).settings.name);

      //Keys.navKey.currentState.pushNamed("/remote");
      return state.copyWith(localImagesState: action.localImagesState);
    }
    break;
    case RefreshRemoteImagesListSucceededAction:{
      print('RefresRemoteImagesListSucceededAction done');
      //print(ModalRoute.of(Keys.navKey.currentState.context).settings.name);

      //Keys.navKey.currentState.pushNamed("/remote");
      return state.copyWith(remoteImagesState: action.remoteImagesState);
    }
    break;
    case RefreshLocalImagesListSucceededAction:{
      print('RefreshLocalImagesListSucceededAction done');
      //print(ModalRoute.of(Keys.navKey.currentState.context).settings.name);

      //Keys.navKey.currentState.pushNamed("/remote");
      return state.copyWith(localImagesState: action.localImagesState);
    }
    break;
    case FetchRemoteImageDetailSucceededAction:{

      Keys.navKey.currentState.pushNamed("/remote_detail");
      return state.copyWith(remoteImageDetail: action.remoteImageState);
      //Keys.navKey.currentState.pushNamed("/remote");
    }
    break;
    case GoToRemoteListScreenAction:{

      Keys.navKey.currentState.pushNamed("/remote");
    }
    break;
    case GoToLocalListScreenAction:{

      Keys.navKey.currentState.pushNamed("/local");
    }
    break;
    case SelectImageTagAction:
      {
        var remoteImageTags = {};
        state.remoteImageDetail.remoteImageTags.forEach(
                (tag_name, tag_value){remoteImageTags[tag_name] = tag_value;});
        remoteImageTags[action.tag_name] = !remoteImageTags[action.tag_name];
        return state.copyWith(remoteImageDetail: state.remoteImageDetail.copyWith(remoteImageTags: remoteImageTags));

      }
      break;
    case UpdateImageTagsSucceededAction:{

      //Keys.navKey.currentState.pushReplacementNamed("/remote_detail");
      return state.copyWith(remoteImageDetail: state.remoteImageDetail.copyWith(remoteImageTags: action.tags));
    }
    break;
    case DeleteImageTagSucceededAction:{
      var remoteImageTags = {};
      state.remoteImageDetail.remoteImageTags.forEach(
              (tagName, tagValue){remoteImageTags[tagName] = tagValue;});
      remoteImageTags.remove(action.tagName);
      //Keys.navKey.currentState.pushReplacementNamed("/remote_detail");
      return state.copyWith(remoteImageDetail: state.remoteImageDetail.copyWith(remoteImageTags: remoteImageTags));
    }
    break;
    case AddImageTagSucceededAction:{
      var remoteImageTags = {};
      state.remoteImageDetail.remoteImageTags.forEach(
              (tagName, tagValue){remoteImageTags[tagName] = tagValue;});
      remoteImageTags[action.tagName] = false;
      //Keys.navKey.currentState.pushNamed("/remote_detail");
      return state.copyWith(remoteImageDetail: state.remoteImageDetail.copyWith(remoteImageTags: remoteImageTags));
    }
    break;
    case GoHomeAction:{
      print("GoHomeAction in redux");
      //Keys.navKey.currentState.popUntil(ModalRoute.withName('/'));
      //return state.copyWith(remoteImageDetail: state.remoteImageDetail.copyWith(remoteImageTags: remoteImageTags));
    }
    break;
    case GoSettingsAction:{
      print("GoSettingsAction in redux");
      Keys.navKey.currentState.pushNamed('/settings');
      //return state.copyWith(remoteImageDetail: state.remoteImageDetail.copyWith(remoteImageTags: remoteImageTags));
    }
    break;
    case LoadSettingsSucceededAction:{
      print("LoadSettingsSucceededAction in redux");
      //Keys.navKey.currentState.pushNamed('/settings');
      //store.dispatch(new FetchRemoteImagesSummaryAction());
      //store.dispatch(new GetLocalImagesCountAction());
      return state.copyWith(settingsState: action.settingsState);
    }
    break;
    case UpdateImageTagsSucceededAction:{
      print("UpdateImageTagsSucceededAction in redux");
      //Keys.navKey.currentState.pushNamed('/settings');
      return state.copyWith(settingsState: action.settingsState);
    }
    break;
    case ShowZoomableImageSucceededAction:{
      print("ShowZoomableImageAction in redux");
      //Keys.navKey.currentState.pushNamed('/settings');

      Keys.navKey.currentState.pushNamed("/remote_image_zoomable");
      return state.copyWith(remoteImageDetail: state.remoteImageDetail.copyWith(remoteImageCache: action.cachedImage));
    }
    break;
    case FetchRemoteImagesListByTagSucceededAction:{
      print("FetchRemoteImagesListByTagSucceededAction in redux");
      //Keys.navKey.currentState.pushNamed('/settings');

      //Keys.navKey.currentState.pushNamed("/remote_by_tag");
      return state.copyWith(remoteImagesByTagState: action.remoteImagesState);
    }
    break;
    case goToIamgeListByTagScreenAction:
      {
        Keys.navKey.currentState.pushNamed("/remote_by_tag");
      }
    break;
    default: {print("Ignore action in reducer");}
    break;
  }
/*  if (action is FetchSyncingDirsSucceededAction) {
    print('FetchSyncingDirsAction done');
    return MyAppState(bottomBarIndex: state.bottomBarIndex, syncingDirs: action.syncingDirs, remoteImagesCount: state.remoteImagesCount,localImagesCount: state.localImagesCount);
  }
  else if (action is FetchSyncingDirsAction) {
    print('FetchSyncingDirsAction reduce');
    developer.log('FetchSyncingDirsAction', name: 'reducer');
  }
  else if (action is PressNavigationBarAction) {
    print('PressNativationBarAction index' + action.bottomBarIndex.toString());
    developer.log('PressNativationBarAction', name: 'reducer');
    return MyAppState(bottomBarIndex: action.bottomBarIndex, syncingDirs: state.syncingDirs,remoteImagesCount: state.remoteImagesCount,localImagesCount: state.localImagesCount );
  }
  else if (action is FetchRemoteImagesCountAction) {
    print('FetchRemoteImagesCountAction reduce');
    developer.log('FetchRemoteImagesCountAction', name: 'reducer');
  }
  else if(action is FetchRemoteImagesCountSucceededAction){
    print('FetchRemoteImagesCountSucceededAction done');
    return MyAppState(bottomBarIndex: state.bottomBarIndex, syncingDirs: state.syncingDirs, remoteImagesCount: action.imagesCount, localImagesCount: state.localImagesCount);
  }*/
  return state;
}