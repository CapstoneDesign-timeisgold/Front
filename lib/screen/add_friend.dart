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
        title: Text('Add Friend', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Enter friend\'s username'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _sendFriendRequest(_usernameController.text);
              },
              child: Text('Send Friend Request'),
            ),
            SizedBox(height: 20),
            Text(_statusMessage),
          ],
        ),
      ),
    );
  }
}


/*class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _usernameController = TextEditingController();
  String _statusMessage = '';

  void _sendFriendRequest(String receiverUsername) {
    // 서버 요청 부분을 주석 처리하고 대신 하드코딩된 데이터로 상태 메시지 설정
    setState(() {
      _statusMessage = 'Friend request sent successfully to $receiverUsername';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friend', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Enter friend\'s username'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _sendFriendRequest(_usernameController.text);
              },
              child: Text('Send Friend Request'),
            ),
            SizedBox(height: 20),
            Text(_statusMessage),
          ],
        ),
      ),
    );
  }
}*/