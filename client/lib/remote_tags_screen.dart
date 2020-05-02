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
import 'package:flutter_app/remote_tags_view.dart';
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

class RemoteTagsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<MyAppState, RemoteTagsViewModel>(
      distinct: true,
      converter: (store) {
        return RemoteTagsViewModel.fromStore(store);
      },
      builder: (context, vm) {
        Widget childBody;
//        if(vm.remoteTagsState.isFetching){
//          //vm.loadMore();
//
//        }
        print(vm.remoteTagsState.tags.keys.toList().toString());
        if (vm.remoteTagsState.tags.length == 0) {
          childBody = Center(
            child: Text("No tags found"),
          );
        } else {

          childBody = NotificationListener<ScrollNotification>(
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
//                    print("Item total count ${vm.remoteImagesState.next}");
//                    print("Current remote images total count ${vm.remoteImagesState.remoteImagesTotalCount}");
//                    print("is fetching ${vm.remoteImagesState.isFetching}");
//                    if ((vm.remoteImagesState.next < vm.remoteImagesState.remoteImagesTotalCount) && (vm.remoteImagesState.isFetching == false))
//                    {
//                      print("Load more");
//                      vm.toLoadMore();
//                      //vm.loadMore();
//                    }
                  }else if (scrollNotification.overscroll < -30){
//                    print("Refresh");
//                    vm.refresh();
                  }
                }
              },
            child: Container(
                child: Wrap(
                spacing: 8,
                alignment: WrapAlignment.start,
                children: List<Widget>.generate(
                    vm.remoteTagsState.tags.length,
                        (int index) => InputChip(
                      label: Text(
                          vm.remoteTagsState.tags.entries.elementAt(index).key.toString().trim() + " : " + vm.remoteTagsState.tags.entries.elementAt(index).value.toString().trim()),
                      selected: false,
/*                    avatar: vm.remoteImageDetail.remoteImageTags[tagList[index]]?CircleAvatar(child: Icon(Icons.check),
                      backgroundColor: vm.remoteImageDetail.remoteImageTags[tagList[index]]?Colors.orange:Colors.transparent,
                      foregroundColor: vm.remoteImageDetail.remoteImageTags[tagList[index]]?Colors.deepOrange:Colors.transparent,):Avatar.,*/
                      selectedColor: Colors.blue,
                      //onSelected: (bool selected) {
                        //vm.selectTag(tagList[index]);
                      //},
                          onPressed: (){
                        vm.goToIamgeListByTagScreen(vm.remoteTagsState.tags.entries.elementAt(index).key.toString().trim());
                          },
                      //deleteIcon: Icon(Icons.clear),
                      //onDeleted: () =>{ vm.deleteImageTag(tagList[index].trim())},
                      //deleteIconColor: Colors.grey
                          )
                ))));
        }
        return new Scaffold(
          appBar: new AppBar(
            title: new Text("remote tags screen"),
          ),
          body: childBody,
          //bottomNavigationBar: AddBottomBar(),
        );
      },
    );
  }
}
