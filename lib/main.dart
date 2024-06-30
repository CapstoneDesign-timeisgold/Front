import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'screen/login.dart';
import './screen/map_screen.dart';
import './screen/add_appointment.dart';

void main() {
  if (kIsWeb) {
    registerIframeElement();
  }
  runApp(MyApp());
}

/*void main() => runApp(MyApp());*/

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      home: LogIn(),
    );
  }
}

