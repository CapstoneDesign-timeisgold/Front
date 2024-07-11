import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './main_list.dart';  
import './add_friend.dart';
import './config.dart';

class FriendRequestsScreen extends StatefulWidget {
  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  late Future<List<FriendRequest>> _futureRequests;

  @override
  void initState() {
    super.initState();
    _futureRequests = _fetchFriendRequests();
  }

  Future<List<FriendRequest>> _fetchFriendRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      return Future.error('Username not found in SharedPreferences');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/friend/requests/$username'),
      //headers: {'username': username},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => FriendRequest.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load friend requests');
    }
  }

  Future<void> _respondToRequest(int friendId, bool accept) async {
    final String url = accept
        ? '$baseUrl/friend/accept/$friendId'
        : '$baseUrl/friend/decline/$friendId';

    final response = await http.post(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      setState(() {
        _futureRequests = _fetchFriendRequests();
      });
    } else {
      print('Failed to respond to friend request');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('친구 요청', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      body: FutureBuilder<List<FriendRequest>>(
        future: _futureRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final requests = snapshot.data!;
            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return Card(
                  child: ListTile(
                    title: Text(request.username),
                    subtitle: Text('요청한 사람: ${request.username}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            if (request.friendId != null) {
                              _respondToRequest(request.friendId!, true);
                            } else {
                              print('friendId is null');
                            }
                          },
                          tooltip: '수락',
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            if (request.friendId != null) {
                              _respondToRequest(request.friendId!, false);
                            } else {
                              print('friendId is null');
                            }
                          },
                          tooltip: '거절',
                        ),
                      ],
                    ),
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
            /*IconButton(
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
                // Already on this screen
              },
              tooltip: '친구 요청 확인',
            ),*/
          ],
        ),
      ),
    );
  }
}

class FriendRequest {
  final int friendId;
  final String username;

  FriendRequest({required this.friendId, required this.username});

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      friendId: json['friendId'],
      username: json['username'],
    );
  }
}


