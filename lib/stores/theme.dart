//import '../data/repository.dart';
import '../stores/error.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'theme.g.dart';

class ThemeStore = _ThemeStore with _$ThemeStore;

abstract class _ThemeStore with Store {
  final String TAG = "_ThemeStore";

  final ErrorStore errorStore = ErrorStore();

  // store variables
  @observable
  bool _darkMode = false;

  // getters
  bool get darkMode => _darkMode;

  // constructor
  /*_ThemeStore(Repository repository)
      : this._repository = repository {
    init();
  }*/

  // actions
  @action
  Future changeBrightnessToDark(bool value) async {
    _darkMode = value;
  }

  // general methods
  /*Future init() async {
    _darkMode = await _repository?.isDarkMode ?? false;
  }*/

  bool isPlatformDark(BuildContext context) =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark;

  // dispose
  @override
  dispose() {}
}
