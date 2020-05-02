// Flutter code sample for BottomNavigationBar

// This example shows a [BottomNavigationBar] as it is used within a [Scaffold]
// widget. The [BottomNavigationBar] has three [BottomNavigationBarItem]
// widgets and the [currentIndex] is set to index 0. The selected item is
// amber. The `_onItemTapped` function changes the selected item's index
// and displays a corresponding message in the center of the [Scaffold].
//
// ![A scaffold with a bottom navigation bar containing three bottom navigation
// bar items. The first one is selected.](https://flutter.github.io/assets-for-api-docs/assets/material/bottom_navigation_bar.png)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/local_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'package:flushbar/flushbar.dart';

class SettingsWidget extends StatefulWidget {
  SettingsWidget({Key key}) : super(key: key);

  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  static const platform = const MethodChannel('app.channel.shared.data');
  static List<String> syncingDirs = [];
  static SharedPreferences prefs = null;

  @override
  void initState() {
    super.initState();
    getPreference();

  }

  getPreference() async {
    prefs = await SharedPreferences.getInstance();
    //List<String> directory = prefs.getStringList("directories");
    setState(() {
      //syncingDirs = directory;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(prefs !=null) {
      return ListView(
          children: _buildListView(prefs.getStringList("directories"))
      );
    }else{
      return ListView(
          children: _buildListView([])
      );
    }
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
        onTap: _rmSyncDir(string),
        title: Text(string),
        trailing: Icon(Icons.delete),

      ),
    );
  }
  _rmSyncDir(String dirPath) {
    //_showToast();
/*    print("Try to remove " + dirPath);
    var removed = await platform.invokeMethod('play', <String, dynamic>{
      'dirPath': dirPath,
    });
    if(removed){
      prefs.getStringList("directories").remove(dirPath);
    }*/
  }

  _showToast() {
    Flushbar(
      title: "Hey Ninja",
      message: "Lorem Ipsum is simply dummy text of the printing and typesetting industry",
      duration: Duration(seconds: 3),
      isDismissible: false,
    )..show(context);
  }
}
