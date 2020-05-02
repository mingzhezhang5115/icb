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
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;


/// This Widget is the main application widget.
class LocalDetailPage extends StatelessWidget {
  static const String _title = 'DetailPage';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.orange,
      ),
      darkTheme:
      ThemeData(brightness: Brightness.dark, primarySwatch: Colors.orange),
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  static const platform = const MethodChannel('app.channel.shared.data');
  static String dataShared = "No data";
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void _onItemTapped(int index) async {
    developer.log('log me', name: 'my.app.category');
    _incrementCounter();
    var sharedData = await platform.invokeMethod("getSharedText");
    developer.log('log me', name: sharedData);
    if (sharedData != null) {
      developer.log('log me callback', name: 'call back');
      setState(() {
        dataShared = sharedData;
        _selectedIndex = index;
      });
    } else if (sharedData == null) {
      developer.log('log me no call back', name: 'No call back');
      setState(() {
        dataShared = "Failed to access gallery";
        _selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getSharedText();
  }

  getSharedText() async {
    var sharedData = await platform.invokeMethod("getSharedText");
    if (sharedData != null) {
      setState(() {
        dataShared = sharedData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DetailPage'),
      ),
      body: Center(
        child: _buildBody(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Settings'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  _incrementCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = (prefs.getInt('counter') ?? 0) + 1;
    print('Pressed $counter times.');
    await prefs.setInt('counter', counter);
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        {
          return _buildHome();
        }
        break;
      case 1:
        {
          return _buildSettings();
        }
        break;
      default:
        {
          return Text(
            'Wrong Index',
            style: optionStyle,
          );
        }
    }
  }

  GridView _buildHome() {
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 1,
      children: <Widget>[
        InkWell(
          onTap: () {},
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Text('Remote'),
              color: Colors.white,
            ),
          ),
        ),
        InkWell(
          onTap: () {},
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Text('Local'),
              color: Colors.teal[200],
            ),
          ),
        ),
      ],
    );
  }

  _buildSettings() {
    return ListView(
      children: const <Widget>[
        Text('Directory In Sync'),
        Card(
          child: ListTile(
            title: Text('Add a new directory'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Camera'),
            trailing: Icon(Icons.delete),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Downloads'),
            trailing: Icon(Icons.delete),
          ),
        ),
        Card(
          child: ListTile(
            leading: FlutterLogo(),
            title: Text('One-line with both widgets'),
            trailing: Icon(Icons.more_vert),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('One-line dense ListTile'),
            dense: true,
          ),
        ),
        Card(
          child: ListTile(
            leading: FlutterLogo(size: 56.0),
            title: Text('Two-line ListTile'),
            subtitle: Text('Here is a second line'),
            trailing: Icon(Icons.more_vert),
          ),
        ),
        Card(
          child: ListTile(
            leading: FlutterLogo(size: 72.0),
            title: Text('Three-line ListTile'),
            subtitle:
            Text('A sufficiently long subtitle warrants three lines.'),
            trailing: Icon(Icons.more_vert),
            isThreeLine: true,
          ),
        ),
      ],
    );
  }
}
