import 'package:flutter_app/actions.dart';
import 'package:flutter_app/app_state.dart';
import 'package:flutter_app/remote_images_state.dart';
import 'package:redux/redux.dart';

class RemoteSumViewModel {
  final int remoteImagesCount;

  //final int currentTag;
  final RemoteImagesState remoteImagesState;
  final RemoteImagesState remoteImagesByTagState;
  final Function(String) goToRemoteDetail;
  final Function(int) loadMore;
  final Function(int) loadMoreByTag;
  final Function() toLoadMore;
  final Function() toLoadMoreByTag;
  final Function() refresh;
  final Function() onPageChanged;
  //final int currentPage;


  RemoteSumViewModel(
      {this.remoteImagesCount,
      //this.currentTag,
      this.remoteImagesState,
      this.remoteImagesByTagState,
      this.goToRemoteDetail,
      this.loadMore,
      this.loadMoreByTag,
      this.toLoadMore,
      this.toLoadMoreByTag,
      this.refresh,
      this.onPageChanged,
      //this.currentPage
      });

  static RemoteSumViewModel fromStore(Store<MyAppState> store) {
    return RemoteSumViewModel(
      //currentTag: store.state.remoteImagesByTagState.cu,
      remoteImagesState: store.state.remoteImagesState,
      remoteImagesByTagState: store.state.remoteImagesByTagState,
      goToRemoteDetail: (image_uuid) =>
          store.dispatch(new FetchRemoteImageDetailAction(image_uuid)),
      loadMore: (index) => store.dispatch(new FetchRemoteImagesListAction(index)),
      loadMoreByTag: (index) => store.dispatch(new FetchRemoteImagesListByTagAction(index,
          store.state.remoteImagesByTagState.currentTag)),
      toLoadMore: () => store.dispatch(new ToFetchRemoteImagesListAction()),
      toLoadMoreByTag: () =>
          store.dispatch(new ToFetchRemoteImagesListByTagAction()),
      refresh: () => store.dispatch(new RefreshRemoteImagesListAction()),
      onPageChanged: () => store.dispatch(new OnPageChangedAction()),
      //currentPage: page,
    );
  }
}
