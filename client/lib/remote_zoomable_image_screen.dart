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
import 'package:flutter_app/remote_detail_screen.dart';
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
import 'package:photo_view/photo_view.dart';

enum WhyFarther { harder, smarter, selfStarter, tradingCharter }

class RemoteZoomableImageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<MyAppState, RemoteImageDetailViewModel>(
      distinct: true,
      converter: (store) {
        return RemoteImageDetailViewModel.fromStore(store);
      },
      builder: (context, vm) {
        return new Scaffold(
          appBar: new AppBar(
            title: new Text("remote zoomable image screen"),
            actions: <Widget>[
              PopupMenuButton(
                onSelected: (result) {},
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry>[
                  PopupMenuItem(
                    value: 1,
                    child: IconButton(icon: Icon(Icons.share),
                      onPressed: () => {vm.shareFile(vm.remoteImageDetail.remoteImageCache.path)},
                    ),
                  ),

                ],
              ),
            ],
          ),
          body: Container(
              child: PhotoView(
            imageProvider: FileImage(vm.remoteImageDetail.remoteImageCache),
          )),
          //bottomNavigationBar: AddBottomBar(),
        );
      },
    );
  }
}
