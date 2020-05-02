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
import 'package:flutter_app/remote_sum_screen.dart';
import 'package:flutter_app/middleware.dart';
import 'package:flutter_app/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';


import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:extended_image/extended_image.dart';
class SettingsState {
  final String testServerAddr;
  final List<String> syncingDirs;
  final TextEditingController textEditingController = new TextEditingController();

  SettingsState({
    @required this.testServerAddr,
    @required this.syncingDirs,
  });

  factory SettingsState.initial() {
    return SettingsState(testServerAddr: '0.0.0.0',syncingDirs: []);
    //print("Init remote image state");
  }

  SettingsState copyWith({
    String testServerAddr,
    List<String> syncingDirs,
  }) {
    return SettingsState(
      testServerAddr: testServerAddr ?? this.testServerAddr,
      syncingDirs: syncingDirs ?? this.syncingDirs,
    );
  }
}

class SettingsViewModel{

  final SettingsState settingsState;
  final Function() updateTestServerAddr;
  final Function() emptyTestDatabase;

  SettingsViewModel({
    this.settingsState,
    this.updateTestServerAddr,
    this.emptyTestDatabase,
});


  static SettingsViewModel fromStore(Store<MyAppState> store) {
    return SettingsViewModel(
      settingsState: store.state.settingsState,
      updateTestServerAddr: () => store.dispatch(new UpdateTestServerAddrAction(store.state.settingsState.textEditingController.text)),
      emptyTestDatabase: () => store.dispatch(new EmptyTestDatabaseAction()),
    ); }
}