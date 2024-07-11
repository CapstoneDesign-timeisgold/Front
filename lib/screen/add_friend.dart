import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './config.dart';

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _usernameController = TextEditingController();
  String _statusMessage = '';

  Future<void> _sendFriendRequest(String receiverUsername) async {
    final prefs = await SharedPreferences.getInstance();
    final String? senderUsername = prefs.getString('username');

    if (senderUsername == null) {
      setState(() {
        _statusMessage = 'Username not found in SharedPreferences';
      });
      return;
    }

    final response = await http.post(
      Uri.parse('http://172.20.10.9:8080/friend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': senderUsername, 'username2': receiverUsername}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _statusMessage = 'Friend request sent successfully';
      });
    } else {
      setState(() {
        _statusMessage = 'Failed to send friend request';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('친구 추가', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '상대방의 ID를 입력하세요',
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),  // 라벨과 입력 필드 사이의 간격을 추가했습니다
                  TextField(
                    controller: _usernameController,
                  ),
                ],
              ),
              SizedBox(height: 30),  // 두 요소 사이의 간격을 넓혔습니다
              ElevatedButton(
                onPressed: () {
                  _sendFriendRequest(_usernameController.text);
                },
                child: Text('친구 추가'),
              ),
              SizedBox(height: 20),
              Text(_statusMessage),
            ],
          ),
        ),
      ),
    );
  }
}
