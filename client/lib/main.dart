// Flutter code sample for BottomNavigationBar

// This example shows a [BottomNavigationBar] as it is used within a [Scaffold]
// widget. The [BottomNavigationBar] has three [BottomNavigationBarItem]
// widgets and the [currentIndex] is set to index 0. The selected item is
// amber. The `_onItemTapped` function changes the selected item's index
// and displays a corresponding message in the center of the [Scaffold].
//
// ![A scaffold with a bottom navigation bar containing three bottom navigation
// bar items. The first one is selected.](https://flutter.github.io/assets-for-api-docs/assets/material/bottom_navigation_bar.png)

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

//import 'dart:ffi';
//import 'dart:js';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/local_detail_page.dart';
import 'package:flutter_app/actions.dart';
import 'package:flutter_app/app_state.dart';
import 'package:flutter_app/local_images_state.dart';
import 'package:flutter_app/nav_key.dart';
import 'package:flutter_app/reducers.dart';
import 'package:flutter_app/bottom_nav_bar.dart';
import 'package:flutter_app/remote_detail_screen.dart';
import 'package:flutter_app/remote_images_state.dart';
import 'package:flutter_app/remote_tags_screen.dart';
import 'package:flutter_app/remote_sum_screen.dart';
import 'package:flutter_app/remote_list_by_tag_screen.dart';
import 'package:flutter_app/local_sum_screen.dart';
import 'package:flutter_app/local_detail_screen.dart';
import 'package:flutter_app/middleware.dart';
import 'package:flutter_app/setting_screen.dart';

import 'package:flutter_app/remote_zoomable_image_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:extended_image/extended_image.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final store = new Store<MyAppState>(counterReducer,
      initialState: new MyAppState.initial(),
      middleware: [fetchListMiddleware]);

  runApp(MyApp(
    title: 'Image Collector EE5115',
    store: store,
  ));
}

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  final Store<MyAppState> store;
  final String title;

  MyApp({Key key, this.store, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //store.dispatch(new FetchSyncingDirsAction());
    store.dispatch(LoadSettingsAction());
    //store.dispatch(new FetchRemoteImagesSummaryAction());
    store.dispatch(new GetLocalImagesListAction(0));

    //store.dispatch(FetchSyncingDirsAction());
    return new StoreProvider<MyAppState>(
      // Pass the store to the StoreProvider. Any ancestor `StoreConnector`
      // Widgets will find and use this value as the `Store`.
      store: store,
      child: new MaterialApp(
        theme: new ThemeData.dark(),
        title: title,
        home: new Scaffold(
          appBar: new AppBar(
            title: new Text(title),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Sign In'),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () => {},
                ),
                ListTile(
                  leading: Icon(Icons.folder),
                  title: Text('Tags'),
                  onTap: () => {store.dispatch(new FetchRemoteTagsAction())},
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () => {store.dispatch(new GoSettingsAction())},
                ),
              ],
            ),
          ),
          body: Center(
            child: HomeScreen(),

          ),
        ),
        navigatorKey: Keys.navKey,
        routes: <String, WidgetBuilder>{
          '/remote': (BuildContext context) => RemoteSumScreen(),
          '/remote_detail': (BuildContext context) => RemoteDetailScreen(),
          '/local_detail': (BuildContext context) => LocalDetailScreen(),
          '/local': (BuildContext context) => LocalSumScreen(),
          '/settings': (BuildContext context) => SettingsScreen(),
          '/remote_image_zoomable': (BuildContext context) =>
              RemoteZoomableImageScreen(),
          '/remote_tags': (BuildContext context) =>
              RemoteTagsScreen(),
          '/remote_by_tag': (BuildContext context) =>
              RemoteImageListByTagScreen(),
        },
      ),
    );
  }
}

/*class HomeBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    return new StoreConnector<MyAppState, List<String>>(
    return new StoreConnector<MyAppState, int>(
      distinct: true,
      converter: (store) {

        return store.state.bottomBarIndex;
      },

        if(vm==0){
          return AddHomeBody();
        }
        else if(vm==1){
          return new AddSettingsBody();
        }
       // return mywidget;
      },
    );
  }

}*/

class AddSettingsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    return new StoreConnector<MyAppState, List<String>>(
    return new StoreConnector<MyAppState, List<String>>(
      distinct: true,
      converter: (store) {
        return store.state.syncingDirs;
      },
      builder: (context, vm) {
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollStartNotification) {
              //print("Start scoll");
            } else if (scrollNotification is ScrollUpdateNotification) {
              //print(scrollNotification.metrics);
            } else if (scrollNotification is ScrollEndNotification) {
              //print(scrollNotification.metrics);
            } else if (scrollNotification is OverscrollNotification) {
              print("Over scroll");
              // print(scrollNotification.metrics);
              print(scrollNotification.overscroll);
              //print(scrollNotification.metrics.axis.toString());
              if (scrollNotification.overscroll > 30) {
                //print("Item total count ${vm.remoteImagesState.next}");
                //print("Current remote images total count ${vm.remoteImagesState.remoteImagesTotalCount}");
                //print("is fetching ${vm.remoteImagesState.isFetching}");
//              if ((vm.remoteImagesState.next < vm.remoteImagesState.remoteImagesTotalCount) && (vm.remoteImagesState.isFetching == false))
//              {
//                print("Load more");
//                vm.toLoadMore();
//                //vm.loadMore();
//              }
              } else if (scrollNotification.overscroll < -30) {
                print("Refresh");
                //.refresh();
              }
            }
          },
          child: ListView(children: _buildListView(vm)),
        );
      },
    );
  }

  _buildListView(List<String> syncingDirs) {
    List<Widget> syncingDirsList = <Widget>[
      Text('Directory In Sync'),
      InkWell(
        child: Card(
          child: ListTile(
            title: Text('Add a new directory'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        ),
      )
    ];
    for (var i = 0; i < syncingDirs.length; i++) {
      syncingDirsList.add(_buildCard(syncingDirs[i]));
    }
    return syncingDirsList;
  }

  Card _buildCard(String string) {
    return Card(
      child: ListTile(
        onTap: null,
        title: Text(string),
        trailing: Icon(Icons.delete),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<MyAppState, HomePageViewModel>(
      distinct: true,
      converter: (store) {
        return HomePageViewModel.fromStore(store);
      },
      builder: (context, vm) {
        //vm.getLocalImagesCountAction();
        //vm.fetchSyncyingDirsAction();
        //vm.fetchRemoteImagesCountAction();
        Widget remoteView;
        Widget localView;
        if (vm.remoteImagesState.remoteImages.length == 0) {
          remoteView = InkWell(
            onTap: () {
              vm.goToRemoteDetail();
            },
            child: Card(
              child: Container(
                width: 300,
                height: 250,
                child: Center(
                  child: Text('No image has been synced',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,),
              ),),
            ),
          );
        }
        if (vm.localImagesState == null ||
            vm.localImagesState.localImages.length == 0) {
          localView = InkWell(
            onTap: () {
              vm.goToLocalList();
            },
            child: Card(
              child: Container(
                width: 300,
                height: 250,
                child: Center(
                  child: Text('No image found in Photos',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,),
                ),),
            ),
          );
        } else
        if (vm.localImagesState.localImages != null &&
            vm.localImagesState.localImages.length > 6) {
          localView = GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              InkWell(
                onTap: () {
                  vm.getLocalImageDetail(vm.localImagesState.localImages[0].localImageUri);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    child: Opacity(
                      opacity: 1,
                      child: ExtendedImage.memory(
                        Uint8List.fromList(vm.localImagesState.localImages[0]
                            .localImageThumbnail),
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                        //cache: true,
                        //cacheWidth: 300,
                        //cacheHeight: 300,
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () { vm.getLocalImageDetail(vm.localImagesState.localImages[1].localImageUri);},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    child: Opacity(
                      opacity: 1,
                      child: ExtendedImage.memory(
                        Uint8List.fromList(vm.localImagesState.localImages[1]
                            .localImageThumbnail),
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                        //cache: true,
                        //cacheWidth: 300,
                        //cacheHeight: 300,
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  vm.getLocalImageDetail(vm.localImagesState.localImages[2].localImageUri);
                  //vm.getRemoteDetail(vm.remoteImages[0].remoteImageUUID);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    child: Opacity(
                      opacity: 1,
                      child: ExtendedImage.memory(
                        Uint8List.fromList(vm.localImagesState.localImages[2]
                            .localImageThumbnail),
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                        //cache: true,
                        //cacheWidth: 300,
                        //cacheHeight: 300,
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  vm.getLocalImageDetail(vm.localImagesState.localImages[3].localImageUri);
                  //vm.getRemoteDetail(vm.remoteImages[0].remoteImageUUID);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    child: Opacity(
                      opacity: 1,
                      child: ExtendedImage.memory(
                        Uint8List.fromList(vm.localImagesState.localImages[3]
                            .localImageThumbnail),
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                        //cache: true,
                        //cacheWidth: 300,
                        //cacheHeight: 300,
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {

                  vm.getLocalImageDetail(vm.localImagesState.localImages[4].localImageUri);
                  //vm.getRemoteDetail(vm.remoteImages[0].remoteImageUUID);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    child: Opacity(
                      opacity: 1,
                      child: ExtendedImage.memory(
                        Uint8List.fromList(vm.localImagesState.localImages[4]
                            .localImageThumbnail),
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                        //cache: true,
                        //cacheWidth: 300,
                        //cacheHeight: 300,
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  //vm.getLocalImageDetail(vm.localImagesState.localImages[3].localImageUri)
                  //vm.getRemoteDetail(vm.remoteImages[4].remoteImageUUID);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Stack(children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(0),
                      child: Opacity(
                        opacity: 0.3,
                        child: Image.memory(
                          Uint8List.fromList(vm.localImagesState.localImages[5]
                              .localImageThumbnail),
                          width: 300,
                          height: 300,
                          fit: BoxFit.cover,
                          //cacheWidth: 300,
                          // cacheHeight: 300,
                        ),
                      ),
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "    " +
                              (vm.localImagesState.localImagesTotalCount - 5)
                                  .toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        )),
                    Center(
                        child: IconButton(
                            icon: Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                              size: 30,
                            ),
                            iconSize: 120.0,
                            onPressed: () {
                              vm.goToLocalList();
                            })),
                  ]),
                ),
              ),
            ],
          );
        } else if(vm.localImagesState.localImages != null &&
            vm.localImagesState.localImages.length <= 6){
          localView = GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.all(20),
              children: List<InkWell>.generate(vm.localImagesState.localImages.length, (int index) =>
                  InkWell(
                    onTap: () {

                      vm.getLocalImageDetail(vm.localImagesState.localImages[index].localImageUri);
                      //vm.getRemoteDetail(vm.remoteImages[0].remoteImageUUID);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(0),
                        child: Opacity(
                          opacity: 1,
                          child: ExtendedImage.memory(
                            Uint8List.fromList(vm.localImagesState.localImages[index]
                                .localImageThumbnail),
                            //width: 300,
                            //height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
              ));
        }
        if (vm.remoteImagesState.remoteImages.length > 6) {
          var imageGrid = <Widget>[];
          for(var i=0; i < 5; i++){
            if (vm.remoteImagesState.remoteImages[i] != null){
              imageGrid.add(              InkWell(
                onTap: () {
                  vm.getRemoteDetail(
                      vm.remoteImagesState.remoteImages[i].remoteImageUUID);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    child: Opacity(
                      opacity: 1,
                      child: ExtendedImage.network(
                        vm.remoteImagesState.remoteImages[i]
                            .remoteImageThumbnailUrl,
                        width: 300,
                        height: 300,
                        cache: true,
                        fit: BoxFit.cover,
                        //cacheWidth: 300,
                        //cacheHeight: 300,
                      ),
                    ),
                  ),
                ),
              ),);
            } else{
              imageGrid.add(Icon(Icons.file_download));
            }

          }
          if(vm.remoteImagesState.remoteImages[5] != null){
            imageGrid.add(InkWell(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Stack(children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(0),
                    child: Opacity(
                      opacity: 0.3,
                      child: Image.network(
                        vm.remoteImagesState.remoteImages[5]
                            .remoteImageThumbnailUrl,
                        width: 300,
                        height: 300,
                        cacheWidth: 300,
                        cacheHeight: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "    " +
                            (vm.remoteImagesState.remoteImagesTotalCount - 5)
                                .toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      )),
                  Center(
                      child: IconButton(
                          icon: Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                            size: 30,
                          ),
                          iconSize: 120.0,
                          onPressed: () {
                            vm.goToRemoteDetail();
                          })),
                ]),
              ),
            ),);
          } else{
            imageGrid.add(Icon(Icons.file_download));
          }
          remoteView = GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.all(20),
            children: imageGrid,
          );
        } else if(vm.remoteImagesState.remoteImages.length <= 6 ){
          remoteView = GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.all(20),
              children: List<InkWell>.generate(vm.remoteImagesState.remoteImages.length, (int index) =>
                  InkWell(
                    onTap: () {
                      vm.getRemoteDetail(
                          vm.remoteImagesState.remoteImages[index].remoteImageUUID);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(0),
                        child: Opacity(
                          opacity: 1,
                          child: ExtendedImage.network(
                            vm.remoteImagesState.remoteImages[index]
                                .remoteImageThumbnailUrl,
                            width: 300,
                            height: 300,
                            cache: true,
                          ),
                        ),
                      ),
                    ),
                  )
    ));
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollStartNotification) {
              //print("Start scoll");
            } else if (scrollNotification is ScrollUpdateNotification) {
              //print(scrollNotification.metrics);
            } else if (scrollNotification is ScrollEndNotification) {
              //print(scrollNotification.metrics);
            } else if (scrollNotification is OverscrollNotification) {
              print("Over scroll");
              // print(scrollNotification.metrics);
              print(scrollNotification.overscroll);
              //print(scrollNotification.metrics.axis.toString());
              if (scrollNotification.overscroll > 30) {
                //print("Item total count ${vm.remoteImagesState.next}");
                //print("Current remote images total count ${vm.remoteImagesState.remoteImagesTotalCount}");
                //print("is fetching ${vm.remoteImagesState.isFetching}");
//              if ((vm.remoteImagesState.next < vm.remoteImagesState.remoteImagesTotalCount) && (vm.remoteImagesState.isFetching == false))
//              {
//                print("Load more");
//                vm.toLoadMore();
//                //vm.loadMore();
//              }
              } else if (scrollNotification.overscroll < -30) {
                print("Refresh");
                vm.refresh();
              }
            }
          },
          child: ListView(
            children: <Widget>[
              //primary: false,
              //padding: const EdgeInsets.all(20),
              //crossAxisSpacing: 10,
              //mainAxisSpacing: 10,
              //crossAxisCount: 1,
              ListTile(
                title: Text('Remote: ' +
                    vm.remoteImagesState.remoteImagesTotalCount.toString() +
                    " in total"),
                onTap: () => vm.goToRemoteDetail(),
              ),
              remoteView,
              ListTile(
                title: Text('Local: ' +
                    vm.localImagesState.localImagesTotalCount.toString() +
                    " in total"),
                onTap: () => vm.goToLocalList(),
              ),
              localView,
/*            InkWell(
              onTap: () {},
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Opacity(
                      opacity: 0.5,
                      child: //Image(image: FileImage(File("content://media/external/images/media/149"))),
                      vm.localThumbnail,
                    )),
                ),
            ),*/
            ],
          ),
        );
      },
    );
  }
}

class HomePageViewModel {
  final RemoteImagesState remoteImagesState;
  final LocalImagesState localImagesState;
  //final Function() onTap;
  final Function() goToRemoteDetail;
  final Function() goToLocalList;
  final Function() fetchSyncyingDirsAction;
  final Function() fetchRemoteImagesCountAction;
  final Function() getLocalImagesCountAction;
  final Function(String) getRemoteDetail;
  final Function(String) getLocalImageDetail;
  final Function(int) getLocalImageList;
  final Function() refresh;

  HomePageViewModel({
    this.remoteImagesState,
    this.localImagesState,
    //this.onTap,
    this.goToRemoteDetail,
    this.goToLocalList,
    this.fetchRemoteImagesCountAction,
    this.fetchSyncyingDirsAction,
    this.getLocalImagesCountAction,
    this.getRemoteDetail,
    this.getLocalImageDetail,
    this.getLocalImageList,
    this.refresh,
  });

  static HomePageViewModel fromStore(Store<MyAppState> store) {
    return HomePageViewModel(
      remoteImagesState: store.state.remoteImagesState,
      localImagesState: store.state.localImagesState,
      //onTap: () => store.dispatch(new GoLocalDetailAction()),
      goToRemoteDetail: () => store.dispatch(new GoToRemoteListScreenAction()),
      getRemoteDetail: (image_uuid) =>
          store.dispatch(new FetchRemoteImageDetailAction(image_uuid)),
      fetchSyncyingDirsAction: () =>
          store.dispatch(new FetchSyncingDirsAction()),
      fetchRemoteImagesCountAction: () =>
          store.dispatch(new FetchRemoteImagesListAction(0)),
      getLocalImagesCountAction: () =>
          store.dispatch(new GetLocalImagesCountAction()),
      getLocalImageDetail: (imageUri) =>
          store.dispatch(new GetLocalImageDetailAction(imageUri)),
      getLocalImageList: (index) =>
          store.dispatch(new GetLocalImagesListAction(index)),
      goToLocalList: () =>
          store.dispatch(new GoToLocalListScreenAction()),
      refresh: () => store.dispatch(new RefreshHomeAction()),
    );
  }
}

/*/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'MingzheEE5115';
  final Store<int> store;
  final String title;
  MyApp({Key key, this.store, this.title }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.orange,
      ),
      darkTheme:
          ThemeData(brightness: Brightness.dark, primarySwatch: Colors.orange),
      home: MyStatefulWidget(),
    );
  }
}*/

/*
class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  static const platform = const MethodChannel('app.channel.shared.data');
  static String dataShared = "No data";
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void _onItemTapped(int index) async {
    developer.log('log me', name: 'my.app.category');
    _incrementCounter();
    var sharedData = await platform.invokeMethod("getSharedText");
    developer.log('log me', name: sharedData);
    if (sharedData != null) {
      developer.log('log me callback', name: 'call back');
      setState(() {
        dataShared = sharedData;
        _selectedIndex = index;
      });
    } else if (sharedData == null) {
      developer.log('log me no call back', name: 'No call back');
      setState(() {
        dataShared = "Failed to access gallery";
        _selectedIndex = index;
      });
    }
  }

  void _onAddDirectory() async {
    developer.log('log me', name: 'my.app.category');
    _incrementCounter();
    var sharedData = await platform.invokeMethod("addDirectory");
    if (sharedData != null) {
      developer.log(sharedData, name: "Add new sync directory");
    } else if (sharedData == null) {
      developer.log('Failed', name: 'Add new sync directory');
    }
  }

  @override
  void initState() {
    super.initState();
    getSharedText();
  }

  getSharedText() async {
    var sharedData = await platform.invokeMethod("getSharedText");
    if (sharedData != null) {
      setState(() {
        dataShared = sharedData;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MingzheEE5115'),
      ),
      body: Center(
        child: _buildBody(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Settings'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  _incrementCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = (prefs.getInt('counter') ?? 0) + 1;
    print('Pressed $counter times.');
    List directory = prefs.getStringList("directories");
    print('Pressed $counter times.');
    print('Pressed $directory times.');
    await prefs.setInt('counter', counter);
    //await prefs.setStringList("directories",["a","b"]);
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        {
          return _buildHome();
        }
        break;
      case 1:
        {
          return SettingsWidget();
        }
        break;
      default:
        {
          return Text(
            'Wrong Index',
            style: optionStyle,
          );
        }
    }
  }

  GridView _buildHome() {
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 1,
      children: <Widget>[
        InkWell(
          onTap: () {},
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Text('Remote'),
              color: Colors.white,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocalDetailPage(),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Text('Local'),
              color: Colors.teal[200],
            ),
          ),
        ),
      ],
    );
  }

  _buildSettings() {
    return ListView(
      children: <Widget>[
        Text('Directory In Sync'),
        InkWell(
          onTap: () {
            _onAddDirectory();
          },
          child: Card(
            child: ListTile(
              title: Text('Add a new directory'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Camera'),
            trailing: Icon(Icons.delete),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Downloads'),
            trailing: Icon(Icons.delete),
          ),
        ),
        Card(
          child: ListTile(
            leading: FlutterLogo(),
            title: Text('One-line with both widgets'),
            trailing: Icon(Icons.more_vert),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('One-line dense ListTile'),
            dense: true,
          ),
        ),
        Card(
          child: ListTile(
            leading: FlutterLogo(size: 56.0),
            title: Text('Two-line ListTile'),
            subtitle: Text('Here is a second line'),
            trailing: Icon(Icons.more_vert),
          ),
        ),
        Card(
          child: ListTile(
            leading: FlutterLogo(size: 72.0),
            title: Text('Three-line ListTile'),
            subtitle:
                Text('A sufficiently long subtitle warrants three lines.'),
            trailing: Icon(Icons.more_vert),
            isThreeLine: true,
          ),
        ),
      ],
    );
  }
}
*/
