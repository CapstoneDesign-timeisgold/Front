import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gkey_front/screen/signup.dart';
import '../service/login_service.dart';
import './map_screen.dart';
import './main_list.dart';
import './config.dart';

class LogIn extends StatefulWidget {
  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  TextEditingController controller = TextEditingController();
  TextEditingController controller2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');
    final String? password = prefs.getString('password');
    if (username != null && password != null) {
      final loginService = Service();
      bool success = await loginService.saveUser(username, password);
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainList()),
        );
      }
    }
  }

  void _login() async {
    final loginService = Service();
    bool success = await loginService.saveUser(controller.text, controller2.text);
    if (success) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('username', controller.text);
      prefs.setString('password', controller2.text);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainList()),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Login Error'),
            content: Text('Incorrect username or password.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log in', style: TextStyle(color: Colors.white)),
        elevation: 0.0,
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.menu), onPressed: () {}),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: () {})
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: 50)),
              Center(
                child: Image(
                  image: AssetImage('assets/image/로고.png'),
                  width: 170.0,
                ),
              ),
              Form(
                child: Theme(
                  data: ThemeData(
                    primaryColor: Colors.grey,
                    inputDecorationTheme: InputDecorationTheme(
                      labelStyle: TextStyle(color: Colors.teal, fontSize: 15.0),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        TextField(
                          autofocus: true,
                          controller: controller,
                          decoration: InputDecoration(labelText: 'Enter your ID'),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        TextField(
                          controller: controller2,
                          decoration: InputDecoration(labelText: 'Enter your Password'),
                          keyboardType: TextInputType.text,
                          obscureText: true,
                        ),
                        SizedBox(height: 40.0),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 36, 115, 179),
                          ),
                          child: Text('Log in', style: TextStyle(color: Colors.white)),
                        ),
                        SizedBox(height: 20.0),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUp()),
                            );
                          },
                          child: Text('Sign Up'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gkey_front/screen/signup.dart';
import '../service/login_service.dart';
import './map_screen.dart';
import './main_list.dart';

class LogIn extends StatefulWidget {
  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  TextEditingController controller = TextEditingController();
  TextEditingController controller2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');
    final String? password = prefs.getString('password');
    if (username != null && password != null) {
      if (username == 'gmk4513' && password == '1234') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainList()),
        );
      }
    }
  }

  void _login() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('username', controller.text);
    prefs.setString('password', controller2.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log in', style: TextStyle(color: Colors.white)),
        elevation: 0.0,
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.menu), onPressed: () {}),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: () {})
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: 50)),
              Center(
                child: Image(
                  image: AssetImage('assets/image/로고.png'),
                  width: 170.0,
                ),
              ),
              Form(
                child: Theme(
                  data: ThemeData(
                    primaryColor: Colors.grey,
                    inputDecorationTheme: InputDecorationTheme(
                      labelStyle: TextStyle(color: Colors.teal, fontSize: 15.0),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        TextField(
                          autofocus: true,
                          controller: controller,
                          decoration: InputDecoration(labelText: 'Enter your ID'),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        TextField(
                          controller: controller2,
                          decoration: InputDecoration(labelText: 'Enter your Password'),
                          keyboardType: TextInputType.text,
                          obscureText: true,
                        ),
                        SizedBox(height: 40.0),
                        ElevatedButton(
                          onPressed: () {
                            if (controller.text == 'gmk4513' && controller2.text == '1234') {
                              _login();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MainList()),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Login Error'),
                                    content: Text('Incorrect username or password.'),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 36, 115, 179),
                          ),
                          child: Text('Log in', style: TextStyle(color: Colors.white)),
                        ),
                        SizedBox(height: 20.0),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUp()),
                            );
                          },
                          child: Text('Sign Up'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/