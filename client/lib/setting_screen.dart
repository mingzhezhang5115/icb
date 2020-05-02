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
import 'package:flutter_app/settings_state.dart';
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

class SettingsScreen extends StatelessWidget {
  Future<void> addTestServerAddr(
      BuildContext context, SettingsViewModel vm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update test server addr'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: vm.settingsState.textEditingController,
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Server IP',
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
                //vm.addImageTag(vm.remoteImageDetail.textEditingController.text);
                vm.updateTestServerAddr();
                Keys.navKey.currentState.pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<MyAppState, SettingsViewModel>(
        distinct: true,
        converter: (store) {
          return SettingsViewModel.fromStore(store);
        },
        builder: (context, vm) {
          Widget testServer;
          if (vm.settingsState.testServerAddr == "") {
            testServer = ListTile(
              title: Text('Not Set'),
              trailing: IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () => {addTestServerAddr(context, vm)}),
              onTap: () => {print("Tap list tile")},
            );
          } else {
            testServer = ListTile(
              title: Text(vm.settingsState.testServerAddr),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => {addTestServerAddr(context, vm)},
              ),
              //onTap: () => {print("Tap list tile")},
            );
          }

          return new Scaffold(
              appBar: new AppBar(
                title: new Text("settings screen"),
              ),
              body: ListView(children: <Widget>[
                Text(
                  'Directory In Sync',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: Text('Photos'),
                  trailing: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () => {print("Tap tailling")},
                  ),
                  onTap: () => {print("Tap list tile")},
                ),
                ListTile(
                  title: Text('Add a new directory'),
                  trailing: IconButton(
                    icon: Icon(Icons.arrow_forward_ios),
                    onPressed: () => {print("Tap tailling")},
                  ),
                  onTap: () => {},
                ),
                Text(
                  'API server address(Debug)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                testServer,
                ListTile(
                  title: Text('Empty test database'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => {vm.emptyTestDatabase()},
                  ),
                  onTap: () => {},
                ),
              ]));
        });
  }
}

/*            TextField(
              //controller: vm.remoteImageDetail.textEditingController,
              obscureText: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Test server address',
              ),*/

//]),
//bottomNavigationBar: AddBottomBar(),
// );
