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

class RemoteImageListByTagScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<MyAppState, RemoteSumViewModel>(
      distinct: true,
      converter: (store) {
        print("Conver to RemoteSumViewModel");
        return RemoteSumViewModel.fromStore(store);
      },
      builder: (context, vm) {
        Widget childBody;
//        if(vm.remoteImagesByTagState.isFetching){
//          vm.loadMoreByTag();
//        }
        print("Build RemoteImageListByTagScreen");
        if (vm.remoteImagesByTagState.remoteImages.length == 0) {
          childBody = Center(
            child: Text("No image found"),
          );
        } else {
          print("Image builder ***********");
          //print(vm.remoteImagesByTagState.remoteImages[0].remoteImageUrl);
          childBody = Scrollbar(
              //controller: vm.remoteImagesByTagState.pageController,
              child: PageView.builder(
                //onPageChanged: vm.onPageChanged(),
              controller: vm.remoteImagesByTagState.pageController,
              //physics: ScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: (vm.remoteImagesByTagState.remoteImages.length/15).ceil(),
              itemBuilder: (BuildContext context, int index) {
                print("Item total count ${vm.remoteImagesByTagState.remoteImages.length}");
                print("Item page count ${(vm.remoteImagesByTagState.remoteImages.length/15).ceil()}");
                print("Index in grid view $index");
                print(vm.remoteImagesByTagState.pageController.hasClients);
                print("Current remote images total count ${vm.remoteImagesByTagState
                    .remoteImagesTotalCount}");
//                  if ((index+1)*15 >= vm.remoteImagesByTagState.next && vm.remoteImagesByTagState.next <vm.remoteImagesByTagState.remoteImagesTotalCount && vm.remoteImagesByTagState.isFetching == false){
//                    print("To load more");
//                    vm.toLoadMoreByTag();
//                  }
                if ( vm.remoteImagesByTagState.remoteImages.length > index*15 + 15 && vm.remoteImagesByTagState.remoteImages[index*15+15] == null && vm.remoteImagesByTagState.isFetching == false){
                  print("Load more start");
                  //vm.toLoadMore();
                  vm.toLoadMoreByTag();
                  vm.loadMoreByTag(index*15+15);
                  print("Local more end");
                }
                var imageGrid = <Widget>[];

                //if (index*15 + 15 >= vm.remoteImagesByTagState.next) {

                  //for(var i = index*15; i < vm.remoteImagesByTagState.next; i++){
                  for(var i = index*15; i < index*15 + 15 && i< vm.remoteImagesByTagState.next; i++){
                    //if((i ==  vm.remoteImagesByTagState.next -1 )&& (vm.remoteImagesByTagState.isFetching == false)){
                     // vm.toLoadMoreByTag();
                    // }
                    if (vm.remoteImagesByTagState
                        .remoteImages[i] != null) {
                      imageGrid.add(
                        Container(
                          padding: const EdgeInsets.all(8),
                          child:
                          InkWell(
                              onTap: () {
                                print("Tap " +
                                    vm.remoteImagesByTagState.remoteImages[i]
                                        .remoteImageUrl);
                                vm.goToRemoteDetail(vm.remoteImagesByTagState
                                    .remoteImages[i].remoteImageUUID);
                              },
                              child: Image.network(vm.remoteImagesByTagState
                                  .remoteImages[i].remoteImageUrl,
                                fit: BoxFit.cover,)),
                          //color: Colors.teal[100],
                        ),
                      );
                    } else {
                      imageGrid.add( Icon(Icons.file_download));
                    }
                  };
                return GridView.count(
                  primary: false,
                  padding: const EdgeInsets.all(5),
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  crossAxisCount: 3,
                  children: imageGrid,);
              }));
        }

        var title = "remote image list by tag screen";
        return new Scaffold(
        appBar:
         new AppBar(
            title: new Text(title),
          ),
          body: childBody,
          //bottomNavigationBar: AddBottomBar(),
        );
      },
    );
  }
}
