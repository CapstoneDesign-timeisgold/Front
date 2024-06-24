import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../service/signup_service.dart';
import './login.dart';
import './config.dart';


class SignUp extends StatefulWidget {
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController controller4 = TextEditingController();
  TextEditingController controller5 = TextEditingController();
  TextEditingController controller6 = TextEditingController();
  TextEditingController controller7 = TextEditingController();

  Service service = Service();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up', style: TextStyle(color: Colors.white,),),
        elevation: 0.0,
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      // email, password 입력하는 부분을 제외한 화면을 탭하면, 키보드 사라지게 GestureDetector 사용 
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: 50)),
              Form(
                child: Theme(
                data: ThemeData(
                    primaryColor: Colors.grey,
                    inputDecorationTheme: InputDecorationTheme(
                        labelStyle: TextStyle(color: Colors.teal, fontSize: 15.0))),
                child: Container(
                    padding: EdgeInsets.all(40.0),
                    child: Builder(builder: (context) {
                      return Column(
                        children: [
                          TextField(
                            controller: controller4,
                            autofocus: true,
                            decoration: InputDecoration(labelText: 'Enter ID'),
                            keyboardType: TextInputType.text,
                          ),
                          TextField(
                            controller: controller5,
                            decoration:
                                InputDecoration(labelText: 'Enter password'),
                            keyboardType: TextInputType.text,
                            obscureText: true, // 비밀번호 안보이도록 하는 것
                          ),
                          TextField(
                            controller: controller6,
                            autofocus: true,
                            decoration: InputDecoration(labelText: 'Enter email address'),
                            keyboardType: TextInputType.text,
                          ),
                          TextField(
                            controller: controller7,
                            autofocus: true,
                            decoration: InputDecoration(labelText: 'Enter nickname'),
                            keyboardType: TextInputType.text,
                          ),
                          SizedBox(
                            height: 40.0,
                          ),
                          ButtonTheme(
                              minWidth: 100.0,
                              height: 50.0,
                              child: ElevatedButton(
                                onPressed: () {
                                  print("username: ${controller4.text}");
                                  print("password1: ${controller5.text}");
                                  print("email: ${controller6.text}");
                                  print("nickname: ${controller7.text}");
                                  //Service service = Service();
                                  service.saveUser(
                                    controller4.text,
                                    controller5.text,
                                    controller6.text,
                                    controller7.text,
                                  );
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 35.0,
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(255, 36, 115, 179)),
                                
                              ))
                        ],
                      );
                    })),
              ))
            ],
          ),
        ),
      ),
    );
  }
}

void showSnackBar(BuildContext context, Text text) {
  final snackBar = SnackBar(
    content: text,
    backgroundColor: Color.fromARGB(255, 112, 48, 48),
  );

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class NextPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}