import 'constants/config.dart';
import 'constants/theme.dart';
import 'routes.dart';
import 'screens/splash.dart';
import 'services/prefs.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Config.appName,
      theme: themeData,
      routes: Routes.routes,
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
