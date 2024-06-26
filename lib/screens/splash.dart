import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/config.dart';
import '../routes.dart';
import '../widgets/app_icon.dart';
import '../services/prefs.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(child: AppIconWidget(image: Config.appLogo)),
    );
  }

  startTimer() {
    var _duration = Duration(milliseconds: 1000);
    return Timer(_duration, navigate);
  }

  navigate() async {
    if (Prefs.getBool('active') ?? false) {
      Navigator.of(context).pushReplacementNamed(Routes.home);
    } else {
      Navigator.of(context).pushReplacementNamed(Routes.login);
    }
  }
}
