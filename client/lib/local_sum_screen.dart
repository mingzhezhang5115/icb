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
import 'package:flutter_app/local_sum_view.dart';

//import 'package:flutter_app/remote_sum_view.dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:extended_image/extended_image.dart';

class LocalSumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<MyAppState, LocalSumViewModel>(
      distinct: true,
      converter: (store) {
        return LocalSumViewModel.fromStore(store);
      },
      builder: (context, vm) {
        Widget childBody;
        //if(vm.localImagesState.isFetching){
         // vm.loadMore();
        //}
        if (vm.localImagesState.localImages.length == 0) {
          childBody = Center(
            child: Text("No image found"),
          );
        } else {
          print("Image builder ***********");
          //print(vm.localImagesState.localImages[0].localImageUri);
          childBody = Center(
                child: new PageView.builder(

                    scrollDirection: Axis.vertical,
                    itemCount: (vm.localImagesState.localImagesTotalCount/15).ceil(),
                    itemBuilder: (BuildContext context, int index) {
                      print("Item total count ${vm.localImagesState.next}");
                      print("Index in grid view $index");
                      print("Current local images total count ${vm
                          .localImagesState.localImagesTotalCount}");
/*                  if (index > vm.remoteImagesState.next && index <vm.remoteImagesState.remoteImagesTotalCount){
                    vm.loadMore();
                  }*/
                      if ((index+1)*15 >= vm.localImagesState.next && vm.localImagesState.next <vm.localImagesState.localImagesTotalCount && vm.localImagesState.isFetching == false){
                        print("To load more");
                        //vm.toLoadMore();
                      }
                      var imageGrid = <Widget>[];

                      for (var i = index * 15; i < index * 15 + 15 && i < vm.localImagesState.localImagesTotalCount; i++) {
                        //if((i ==  vm.remoteImagesByTagState.next -1 )&& (vm.remoteImagesByTagState.isFetching == false)){
                        // vm.toLoadMoreByTag();
                        // }
                        print("Rendering image grid " + i.toString());
                        print("Is fetching " + vm.localImagesState.isFetching.toString());

                        if (vm.localImagesState
                            .localImages.length <= i || vm.localImagesState.localImages[i] == null) {
                          //if(vm.localImagesState.isFetching == false && i%15==0){
                            //vm.toLoadMore();

                          //}
                          print("Rendering icon");
                          imageGrid.add(Icon(Icons.favorite,));
                        } else {
                          print("Rendering image");
                          imageGrid.add(
                              Container(
                                height: 50,
                                child: Center(
                                    child: InkWell(
                                        onTap: () {
                                          print("Tap " +
                                              vm.localImagesState.localImages[i]
                                                  .localImageUri);
                                          vm.goToLocalDetail(vm.localImagesState
                                              .localImages[i].localImageUri);
                                        },
                                        child: Image.memory(
                                          Uint8List.fromList(vm.localImagesState
                                              .localImages[i]
                                              .localImageThumbnail),
                                          width: 360,
                                          height: 360,
                                          fit: BoxFit.cover,
                                        ))),
                                //Text('Entry ${vm.remoteImages[index].remoteImageUrl}')),
                              )
                          );
                        }
                      }
                      if ( vm.localImagesState
                          .localImages.length > index*15 + 15 && vm.localImagesState.localImages[index*15+15] == null && vm.localImagesState.isFetching == false){
                        print("Load more start");
                        vm.toLoadMore();
                        vm.loadMore(index*15+15);
                        print("Local more end");
                      }
                      return GridView.count(
                        primary: false,
                        padding: const EdgeInsets.all(5),
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        crossAxisCount: 3,
                        children: imageGrid,);
//                      return Container(
//                        height: 50,
//                        child: Center(
//                            child: InkWell(
//                                onTap: () {
//                                  print("Tap " +
//                                      vm.localImagesState.localImages[index]
//                                          .localImageUri);
//                                  vm.goToLocalDetail(vm.localImagesState
//                                      .localImages[index].localImageUri);
//                                },
//                                child: Image.memory(Uint8List.fromList(vm.localImagesState
//                                    .localImages[index].localImageThumbnail),
//                                  width: 360,
//                                  height: 360,))),
//                        //Text('Entry ${vm.remoteImages[index].remoteImageUrl}')),
//                      );
                    }),
              );
        }
        return new Scaffold(
          appBar: new AppBar(
            title: new Text("local sum screen"),
            actions: <Widget>[
              PopupMenuButton(
                onSelected: (result) {},
                itemBuilder: (BuildContext context) =>
                <PopupMenuEntry>[
                  PopupMenuItem(
                    value: 1,
                    child: IconButton(icon: Icon(Icons.cloud_upload),
                      onPressed: () => {vm.uploadAll()},
                    ),
                  ),

                ],
              ),
            ],
          ),
          body: childBody,
          //bottomNavigationBar: AddBottomBar(),
        );
      },
    );
  }
}
