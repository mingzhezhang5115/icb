import 'dart:async';
import 'dart:convert';
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
import 'package:flutter_app/remote_image_state.dart';
import 'package:flutter_app/remote_sum_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:extended_image/extended_image.dart';
import 'package:photo_view/photo_view.dart';

class RemoteDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<MyAppState, RemoteImageDetailViewModel>(
        distinct: true,
        converter: (store) {
          return RemoteImageDetailViewModel.fromStore(store);
        },
        builder: (context, vm) {
          Widget tagView = Container();
          Widget tagConfirmedView =Container();
          if (vm.remoteImageDetail.remoteImageTags.length == 0) {
            tagView = Center(
                child: Column(children: <Widget>[
              Text(
                "No tags found.\nTap button bellow to add more for categorization",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.grey[300],
                ),
              ),
              IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: Colors.grey,
                    //size: 240.0,
                    semanticLabel: 'Text to announce in accessibility modes',
                  ),
                  iconSize: 240.0,
                  onPressed: () {
                    print("ICON Pressed");
                    _neverSatisfied(context, vm);
                  })
            ]));
            tagConfirmedView = Container();
          } else {
            var tagList = List.from(vm.remoteImageDetail.remoteImageTags.keys);
            List<Widget> chipList = List<Widget>.generate(
                vm.remoteImageDetail.remoteImageTags.length,
                (int index) => InputChip(
                    label: Text(
                        tagList[index].trim()),
                    selected: vm.remoteImageDetail.remoteImageTags[tagList[index]],
/*                    avatar: vm.remoteImageDetail.remoteImageTags[tagList[index]]?CircleAvatar(child: Icon(Icons.check),
                      backgroundColor: vm.remoteImageDetail.remoteImageTags[tagList[index]]?Colors.orange:Colors.transparent,
                      foregroundColor: vm.remoteImageDetail.remoteImageTags[tagList[index]]?Colors.deepOrange:Colors.transparent,):Avatar.,*/
                    selectedColor: Colors.blue,
                    onSelected: (bool selected) {
                      vm.selectTag(tagList[index]);
                    },
                deleteIcon: Icon(Icons.clear),
                    onDeleted: () =>{ vm.deleteImageTag(tagList[index].trim())},
                deleteIconColor: Colors.grey,));
            chipList.add(IconButton(
              icon: Icon(Icons.add_circle),
              onPressed: () {
                _neverSatisfied(context, vm);
              },
            ));
            tagView = Align(
                alignment: Alignment.topLeft,
                child: Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.start,
                    children: chipList));
            if(vm.remoteImageDetail.remoteImageTagConfirmed) {
              tagConfirmedView = Container();
//              tagConfirmedView = Center(
//                  child: Column(children: <Widget>[
//                    Text(
//                      "Above tags are annotated automatically.\nTap button bellow to confirmed",
//                      textAlign: TextAlign.center,
//                      style: TextStyle(
//                        fontSize: 30,
//                        color: Colors.grey[300],
//                      ),
//                    ),
//                    IconButton(
//                        icon: Icon(
//                          Icons.check_circle,
//                          color: Colors.grey,
//                          //size: 240.0,
//                          semanticLabel: 'Text to announce in accessibility modes',
//                        ),
//                        iconSize: 240.0,
//                        onPressed: () {
//                          print("ICON Pressed");
//                          _neverSatisfied(context, vm);
//                        })
//                  ]));
            }else{
              tagConfirmedView = Center(
                  child: Column(children: <Widget>[
                    Text(
                      "Above tags are annotated automatically.\nTap button bellow to confirmed",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.grey[300],
                      ),
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.check_circle,
                          color: Colors.grey,
                          //size: 240.0,
                          semanticLabel: 'Text to announce in accessibility modes',
                        ),
                        iconSize: 240.0,
                        onPressed: () {
                          print("ICON Pressed");
                          vm.confirmTag();
                        })
                  ]));
            }
          }
          Widget childBody;

          //childBody = PhotoView(
          //  imageProvider: NetworkImage(vm.remoteImageUrl),
          //);
          /*ExtendedImage.network(vm.remoteImageUrl,
            //width: 1080,
            //height: 360,
            fit: BoxFit.contain,
            mode: ExtendedImageMode.gesture,
            initGestureConfigHandler: (state) {
              return GestureConfig(
                minScale: 0.9,
                animationMinScale: 0.7,
                maxScale: 3.0,
                animationMaxScale: 3.5,
                speed: 1.0,
                inertialSpeed: 100.0,
                initialScale: 1.0,
                inPageView: false,
                initialAlignment: InitialAlignment.center,
              );
            },);*/
          childBody = ListView(children: <Widget>[
              GestureDetector(
              onTap: () { print("Check image detail");
              vm.viewImage();
          },
          child:
            ExtendedImage.network(vm.remoteImageDetail.remoteImageUrl,
                width: 1080,
                height: 360,
                fit: BoxFit.contain,
                cache: true,
            ),),
/*            Align(
                alignment: Alignment.topLeft,
                child: Container(
                    margin: const EdgeInsets.all(10.0), child: Text("Tags"))),*/
            tagView,
            tagConfirmedView,
          ]);
          //);
/*            child: new ListView.builder(  itemCount: vm.remoteImages.length, itemBuilder: (BuildContext context, int index) {
              return Container(
                height: 50,
                child: Center(child: ExtendedImage.network(vm.remoteImages[index].remoteImageUrl)),
                //Text('Entry ${vm.remoteImages[index].remoteImageUrl}')),
              );
            }),*/
          return new Scaffold(
            appBar: new AppBar(
              title: new Text("remote detail screen"),
            ),
            body: childBody,
            //bottomNavigationBar: AddBottomBar(),
            resizeToAvoidBottomInset: false,
          );
//            Center(
//                child: Card(
//                    child: TextField(
//              obscureText: true,
//              decoration: InputDecoration(
//                border: OutlineInputBorder(),
//                labelText: 'Password',
//              ),
//            )))
        });
  }

  Future<void> _neverSatisfied(
      BuildContext context, RemoteImageDetailViewModel vm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a new tag'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: vm.remoteImageDetail.textEditingController,
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Tag Name',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Keys.navKey.currentState.pop();
              },
            ),
            FlatButton(
              child: Text('Confirm'),
              onPressed: () {
                vm.addImageTag(vm.remoteImageDetail.textEditingController.text);
                Keys.navKey.currentState.pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class RemoteImageDetailViewModel {
  final RemoteImageDetailState remoteImageDetail;
  final Function() updateImageTags;
  final Function(String) selectTag;
  final Function(String) deleteImageTag;
  final Function(String) addImageTag;
  final Function() viewImage;
  final Function(String) shareFile;
  final Function() confirmTag;

  RemoteImageDetailViewModel({
    this.remoteImageDetail,
    this.updateImageTags,
    this.deleteImageTag,
    this.selectTag,
    this.addImageTag,
    this.viewImage,
    this.shareFile,
    this.confirmTag,
  });

  static RemoteImageDetailViewModel fromStore(Store<MyAppState> store) {
    return RemoteImageDetailViewModel(
      remoteImageDetail: store.state.remoteImageDetail,
      updateImageTags: () => store.dispatch(new UpdateImageTagsAction()),
      deleteImageTag: (tagName) => store.dispatch(new DeleteImageTagAction(tagName)),
      addImageTag: (tagName) => store.dispatch(new AddImageTagAction(tagName)),
      selectTag: (tagName) => store.dispatch(new SelectImageTagAction(tagName)),
      viewImage: () => store.dispatch(new ShowZoomableImageAction()),
      shareFile: (cachePath) => store.dispatch(new ShareFileAction(cachePath)),
      confirmTag: () => store.dispatch(new ConfirmImageTagAction()),
    );
  }
}

class ImageTags extends StatelessWidget {
  final int _value = 1;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List<Widget>.generate(
        3,
        (int index) {
          return ChoiceChip(
            label: Text('Item $index'),
            selected: _value == index,
            onSelected: (bool selected) {},
          );
        },
      ).toList(),
    );
  }
}
