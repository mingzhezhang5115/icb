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
import 'package:flutter_app/local_image_state.dart';
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

class LocalDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<MyAppState, LocalImageDetailViewModel>(
        distinct: true,
        converter: (store) {
          return LocalImageDetailViewModel.fromStore(store);
        },
        builder: (context, vm) {
          Widget childBody = ListView(children: <Widget>[
            GestureDetector(
              onTap: () { print("Check image detail");
              //vm.viewImage();
              },
              child:
              ExtendedImage.memory(Uint8List.fromList(vm.localImageDetail.localImageData),
                width: 1080,
                height: 360,
                fit: BoxFit.contain,
                //cache: true,
              ),),
/*            Align(
                alignment: Alignment.topLeft,
                child: Container(
                    margin: const EdgeInsets.all(10.0), child: Text("Tags"))),*/
            //tagView,
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
              title: new Text("local detail screen"),
              actions: <Widget>[
                PopupMenuButton(
                  onSelected: (result) {},
                  itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry>[
                    PopupMenuItem(
                      value: 1,
                      child: IconButton(icon: Icon(Icons.cloud_upload),
                        onPressed: () => {vm.uploadImage(vm.localImageDetail.localImageUri)},
                      ),
                    ),

                  ],
                ),
              ],
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
/*
  Future<void> _neverSatisfied(
      BuildContext context, LocalImageDetailViewModel vm) async {
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
  }*/
}

class LocalImageDetailViewModel {
  final LocalImageDetailState localImageDetail;
  final Function(String) uploadImage;

  //final Function() viewImage;


  LocalImageDetailViewModel({
    this.localImageDetail,
    this.uploadImage,
    //this.viewImage,
  });

  static LocalImageDetailViewModel fromStore(Store<MyAppState> store) {
    return LocalImageDetailViewModel(
        localImageDetail: store.state.localImageDetail,

        uploadImage: (imageUri) => store.dispatch(new UploadImageAction(imageUri)),
        //shareFile: (cachePath) => store.dispatch(new ShareFileAction(cachePath))
    );
  }
}


