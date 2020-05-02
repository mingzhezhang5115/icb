
import 'package:flutter/material.dart';
import 'package:flutter_app/actions.dart';
import 'package:flutter_app/app_state.dart';
import 'package:redux/redux.dart';

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