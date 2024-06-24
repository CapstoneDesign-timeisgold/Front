import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../screen/config.dart';

class AddAppointmentService {
  
  Future<bool> addAppointment(String title, String date, String time, int penalty/*, String location*/) async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');
    
    if (username == null) {
      // username이나 nickname이 없으면 요청을 보낼 수 없음
      return false;
    }

    var uri = Uri.parse("$baseUrl/promise");
    
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    Map data = {
      'title': title,
      'date': date,
      'time': time,
      'penalty': penalty,
      //'location': location,
      'creatorUsername': username, // 여기에서 username을 포함시킴
    };
    var body = json.encode(data);

    try {
      var response = await http.post(uri, headers: headers, body: body);
      print('Response Status Code: ${response.statusCode}');
      print("${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // 통신 오류
      print("Error: $e");
      return false;
    }
  }
} 