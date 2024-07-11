import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './config.dart';
import './friend_list.dart';

class InviteAppointmentScreen extends StatefulWidget {
  final int promiseId;

  InviteAppointmentScreen({required this.promiseId});

  @override
  _InviteAppointmentScreenState createState() => _InviteAppointmentScreenState();
}

class _InviteAppointmentScreenState extends State<InviteAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _guestUsername = '';
  String? _selectedFriendUsername;
  late Future<List<Friend>> _futureFriends;

  @override
  void initState() {
    super.initState();
    _futureFriends = _fetchFriends();
  }

  Future<List<Friend>> _fetchFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      return Future.error('Username not found in SharedPreferences');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/friend/list/$username'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Friend.fromJson(json)).where((friend) => friend.status == "ACCEPTED").toList();
    } else {
      throw Exception('Failed to load friends');
    }
  }

  Future<void> _inviteFriend(String guestUsername) async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      print('Username not found in SharedPreferences');
      return;
    }

    print('Inviting friend: $guestUsername');

    final url = Uri.parse('$baseUrl/promise/invitation');
    final headers = {
      'Content-Type': 'application/json',
      'username': username,
    };
    final body = jsonEncode({
      'promiseId': widget.promiseId,
      'guestUsername': guestUsername,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Invitation sent successfully');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invitation sent successfully')));
      } else {
        print('Failed to send invitation. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send invitation')));
      }
    } catch (e) {
      print('Error sending invitation: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sending invitation')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('약속 초대', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: '상대방의 ID를 입력하세요'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a friend\'s username';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _guestUsername = value;
                    },
                    onSaved: (value) {
                      _guestUsername = value!;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        await _inviteFriend(_guestUsername);
                      }
                    },
                    child: Text('검색한 ID로 초대', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 36, 115, 179),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              '친구목록에서 초대하기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            FutureBuilder<List<Friend>>(
              future: _futureFriends,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final friends = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        return Card(
                          color: _selectedFriendUsername == friend.username2 ? Colors.blue[100] : null,
                          child: ListTile(
                            title: Text(friend.username2),
                            onTap: () {
                              setState(() {
                                _selectedFriendUsername = friend.username2;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedFriendUsername == null
                  ? null
                  : () async {
                      await _inviteFriend(_selectedFriendUsername!);
                    },
              child: Text('선택한 친구 초대', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 36, 115, 179),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Friend {
  final String username2;
  final String status;

  Friend({required this.username2, required this.status});

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      username2: json['username2'],
      status: json['status'],
    );
  }
}








//original
/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './config.dart';

class InviteAppointmentScreen extends StatefulWidget {
  final int promiseId;

  InviteAppointmentScreen({required this.promiseId});

  @override
  _InviteAppointmentScreenState createState() => _InviteAppointmentScreenState();
}

class _InviteAppointmentScreenState extends State<InviteAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _guestUsername = '';

  Future<void> _inviteFriend() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      print('Username not found in SharedPreferences');
      return;
    }

    print('Inviting friend: $_guestUsername');

    final url = Uri.parse('$baseUrl/promise/invitation');
    final headers = {
      'Content-Type': 'application/json',
      'username': username,
    };
    final body = jsonEncode({
      'promiseId': widget.promiseId,
      'guestUsername': _guestUsername,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Invitation sent successfully');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invitation sent successfully')));
      } else {
        print('Failed to send invitation. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send invitation')));
      }
    } catch (e) {
      print('Error sending invitation: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sending invitation')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invite to Appointment', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Friend Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a friend\'s username';
                  }
                  return null;
                },
                onChanged: (value) {
                  _guestUsername = value;
                },
                onSaved: (value) {
                  _guestUsername = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await _inviteFriend();
                  }
                },
                child: Text('Invite', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 36, 115, 179),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/



