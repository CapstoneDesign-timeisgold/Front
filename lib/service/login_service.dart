import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screen/config.dart';

class Service {
  Future<bool>saveUser(
    String username, String password) async{
      var uri = Uri.parse("$baseUrl/user/login");
      Map<String, String> headers = {"Content-Type": "application/json"};

      Map data = {
        'username': '$username',
        'password': '$password',
      };
      var body = json.encode(data);

      try{
        var response = await http.post(uri, headers: headers, body: body);
        print('Response Status Code: ${response.statusCode}');
        print("${response.body}");
        return response.statusCode == 200;
      } catch(e) {
        //통신 오류
        print("Error: $e");
        return false;
      }
    }
}