import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './main_list.dart';  
import './add_friend.dart'; 
import './friend_requests.dart';
import './config.dart';


class FriendListScreen extends StatefulWidget {
  @override
  _FriendListScreenState createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
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
      //headers: {'username': username},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      //return data.map((json) => Friend.fromJson(json)).toList();
      return data.map((json) => Friend.fromJson(json)).where((friend) => friend.status == "ACCEPTED").toList();
    } else {
      throw Exception('Failed to load friends');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend List', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      body: FutureBuilder<List<Friend>>(
        future: _futureFriends,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final friends = snapshot.data!;
            return SingleChildScrollView( // Wrap with SingleChildScrollView
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return Card(
                        child: ListTile(
                          title: Text(friend.username2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home, color: Colors.blueGrey),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainList()), // Replace with your MainList screen
                );
              },
              tooltip: '홈',
            ),
            IconButton(
              icon: Icon(Icons.person_add, color: Colors.blueGrey),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddFriendScreen()),
                );
              },
              tooltip: '친구 추가',
            ),
            IconButton(
              icon: Icon(Icons.mail, color: Colors.blueGrey),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FriendRequestsScreen()),
                );
              },
              tooltip: '친구 요청 확인',
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


/*class FriendListScreen extends StatefulWidget {
  @override
  _FriendListScreenState createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  late Future<List<Friend>> _futureFriends;

  @override
  void initState() {
    super.initState();
    _futureFriends = _fetchFriends();
  }

  Future<List<Friend>> _fetchFriends() async {
    // 하드코딩된 데이터 사용
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    return [
      Friend(username2: 'friend1'),
      Friend(username2: 'friend2'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend List', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      body: FutureBuilder<List<Friend>>(
        future: _futureFriends,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final friends = snapshot.data!;
            return ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return Card(
                  child: ListTile(
                    title: Text(friend.username2),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home, color: Colors.blueGrey),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainList()), // Replace with your MainList screen
                );
              },
              tooltip: '홈',
            ),
            IconButton(
              icon: Icon(Icons.person_add, color: Colors.blueGrey),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddFriendScreen()),
                );
              },
              tooltip: '친구 추가',
            ),
            IconButton(
              icon: Icon(Icons.mail, color: Colors.blueGrey),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FriendRequestsScreen()),
                );
              },
              tooltip: '친구 요청 확인',
            ),
          ],
        ),
      ),
    );
  }
}

class Friend {
  final String username2;

  Friend({required this.username2});

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      username2: json['username2'],
    );
  }
}*/