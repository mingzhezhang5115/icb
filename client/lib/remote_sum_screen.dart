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
import 'package:flutter_app/remote_images_state.dart';
import 'package:flutter_app/remote_sum_view.dart';

//import 'package:flutter_app/remote_sum_view.dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:extended_image/extended_image.dart';

class RemoteSumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<MyAppState, RemoteSumViewModel>(
      distinct: true,
      converter: (store) {
        return RemoteSumViewModel.fromStore(store);
      },
      builder: (context, vm) {
        Widget childBody;
//        if(vm.remoteImagesState.isFetching){
//          vm.loadMore();
//
//        }
        if (vm.remoteImagesState.remoteImages.length == 0) {
          childBody = Center(
            child: Text("No image found"),
          );
        } else {
          print("Image builder ***********");
          //print(vm.remoteImagesState.remoteImages[0].remoteImageUrl);
          childBody = /*NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollStartNotification) {
                  //print("Start scoll");
                } else if (scrollNotification is ScrollUpdateNotification) {
                  //print(scrollNotification.metrics);
                } else if (scrollNotification is ScrollEndNotification) {
                  //print(scrollNotification.metrics);
                } else if (scrollNotification is OverscrollNotification)
                {
                  print("Over scroll");
                 // print(scrollNotification.metrics);
                  print(scrollNotification.overscroll);
                  //print(scrollNotification.metrics.axis.toString());
                  if (scrollNotification.overscroll >30){
                    print("Item total count ${vm.remoteImagesState.next}");
                    print("Current remote images total count ${vm.remoteImagesState.remoteImagesTotalCount}");
                    print("is fetching ${vm.remoteImagesState.isFetching}");
                    if ((vm.remoteImagesState.next < vm.remoteImagesState.remoteImagesTotalCount) && (vm.remoteImagesState.isFetching == false))
                    {
                      print("Load more");
                      vm.toLoadMore();
                      //vm.loadMore();
                    }
                  }else if (scrollNotification.overscroll < -30){
                    print("Refresh");
                    vm.refresh();
                  }
                }
              },
              child:*/Center(
            child: new GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //crossAxisCount: 3,
                  //primary: false,

                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  crossAxisCount: 3,),
                padding: const EdgeInsets.all(5),
                itemCount: vm.remoteImagesState.remoteImagesTotalCount,
                itemBuilder: (BuildContext context, int index) {
                  print("Item total count ${vm.remoteImagesState.next}");
                  print("Index in grid view $index");
                  print("Current remote images total count ${vm.remoteImagesState.remoteImagesTotalCount}");
/*                  if (index > vm.remoteImagesState.next && index <vm.remoteImagesState.remoteImagesTotalCount){
                    vm.loadMore();
                  }*/
                  if ( vm.remoteImagesState.remoteImages.length > index*15 + 15 && vm.remoteImagesState.remoteImages[index*15+15] == null && vm.remoteImagesState.isFetching == false){
                    print("Load more start");
                    vm.toLoadMore();
                    if(vm.remoteImagesState.remoteImages[index*15] == null) {
                      vm.loadMore(index * 15);
                    }else{
                      vm.loadMore(index * 15 + 15);
                    }
                    print("Local more end");
                  }
                  Widget imageContainer;
                  if (vm.remoteImagesState.remoteImages[index]!= null){
                    imageContainer = Container(
                      height: 50,
                      child:
                           InkWell(
                              onTap: () {
                                print("Tap " +
                                    vm.remoteImagesState.remoteImages[index]
                                        .remoteImageUrl);
                                vm.goToRemoteDetail(vm.remoteImagesState
                                    .remoteImages[index].remoteImageUUID);
                              },
                              child: Image.network(vm.remoteImagesState
                                  .remoteImages[index].remoteImageUrl,
                                fit: BoxFit.cover,
                                //width: 360,
                                //height: 360,
                              )),
                      //Text('Entry ${vm.remoteImages[index].remoteImageUrl}')),
                    );
                  } else{
                    imageContainer = Icon(Icons.file_download);
                  }
                  return imageContainer;
                }),
          );
        }
        return new Scaffold(
          appBar: new AppBar(
            title: new Text("remote sum screen"),
          ),
          body: childBody,
          //bottomNavigationBar: AddBottomBar(),
        );
      },
    );
  }
}
