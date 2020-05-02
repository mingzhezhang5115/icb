
import 'package:flutter_app/actions.dart';
import 'package:flutter_app/app_state.dart';
import 'package:flutter_app/local_images_state.dart';
import 'package:redux/redux.dart';


class LocalSumViewModel{
  final LocalImagesState localImagesState;
  final Function(String) goToLocalDetail;
  final Function(int) loadMore;
  final Function() toLoadMore;
  final Function() refresh;
  final Function() uploadAll;


  LocalSumViewModel({
    this.localImagesState,
    this.goToLocalDetail,
    this.loadMore,
    this.toLoadMore,
    this.refresh,
    this.uploadAll,
  });


  static LocalSumViewModel fromStore(Store<MyAppState> store) {
    return LocalSumViewModel(
      localImagesState: store.state.localImagesState,
      goToLocalDetail: (imageUri) => store.dispatch(new GetLocalImageDetailAction(imageUri)),
      loadMore: (index) => store.dispatch(new GetLocalImagesListAction(index)),
      toLoadMore: () => store.dispatch(new ToGetLocalImagesListAction()),
      refresh: () => store.dispatch(new RefreshLocalImagesListAction()),
      uploadAll: () => store.dispatch(new UploadAllLocalImagesAction()),

    ); }
}