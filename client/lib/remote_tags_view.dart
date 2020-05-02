import 'package:flutter_app/actions.dart';
import 'package:flutter_app/app_state.dart';
import 'package:flutter_app/remote_tags_state.dart';
import 'package:redux/redux.dart';

class RemoteTagsViewModel{
  final RemoteTagsState remoteTagsState;
  final Function(int,String) fetchImageListByTag;
  final Function(String) goToIamgeListByTagScreen;



  RemoteTagsViewModel({
    this.remoteTagsState,
    this.fetchImageListByTag,
    this.goToIamgeListByTagScreen,
});


  static RemoteTagsViewModel fromStore(Store<MyAppState> store) {
    print(store.state.remoteTagsState.tags.toString());
    return RemoteTagsViewModel(
      remoteTagsState: store.state.remoteTagsState,
      fetchImageListByTag: (index,tag) => store.dispatch(new FetchRemoteImagesListByTagAction(index, tag)),
      goToIamgeListByTagScreen: (tag) => store.dispatch(new goToIamgeListByTagScreenAction(tag)),
    ); }
}