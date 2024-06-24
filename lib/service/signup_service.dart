import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screen/config.dart';

class Service {
  Future<http.Response>saveUser(
    String username, String password1, String email, String nickname) async{
      var uri = Uri.parse("$baseUrl/user/signup");
      Map<String, String> headers = {"Content-Type": "application/json"};

      Map data = {
        'username': '$username',
        'password1': '$password1',
        'email' : '$email',
        'nickname': '$nickname',
      };
      var body = json.encode(data);

      print('Request URL: $uri');
      print('Request Headers: $headers');
      print('Request Body: $body');

      try{
        var response = await http.post(uri, headers: headers, body: body);
        print('Response Status Code: ${response.statusCode}');
        print("${response.body}");
        return response;
      } catch(e) {
        //통신 오류
        print('Error: $e');
        throw e;
      }
    }
}