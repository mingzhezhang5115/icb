import 'package:flutter/material.dart';
import 'package:flutter_app/actions.dart';
import 'package:flutter_app/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';


import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
class AddBottomBar extends StatefulWidget {
  @override
  _AddBottomBarState createState() => new _AddBottomBarState();
}


class _AddBottomBarState extends State<AddBottomBar> {
  final TextEditingController _controller = new TextEditingController();


  @override
  Widget build(BuildContext context) {
//    return new StoreConnector<MyAppState, List<String>>(
    return new StoreConnector<MyAppState, BottomBarViewModel>(
      converter: (store) {

        return BottomBarViewModel.fromStore(store);
      },
      builder: (context, vm) {
        return BottomNavigationBar(
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
          currentIndex: vm.bottemBarIndex,
          selectedItemColor: Colors.amber[800],
          onTap: (index) => vm.pressBottomBar(index),
        );
      },
    );
  }
}

class BottomBarViewModel{

  final int bottemBarIndex;

  final Function(int) pressBottomBar;
  //final Function(int) pressSettingsBar;
  final List<String> syncingDirs;

  BottomBarViewModel({
    this.bottemBarIndex,
    this.pressBottomBar,
    this.syncingDirs});


  static BottomBarViewModel fromStore(Store<MyAppState> store){
    return BottomBarViewModel(
      bottemBarIndex: store.state.bottomBarIndex,
      syncingDirs: store.state.syncingDirs,
      pressBottomBar: (index) => store.dispatch(new PressNavigationBarAction(index)),
      //navigateToRegistration: () => store.dispatch(new NavigateToRegistrationAction())
    );
  }
}