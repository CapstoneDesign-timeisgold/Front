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
    /*final prefs = await SharedPreferences.getInstance();
    final String? receiverUsername = prefs.getString('username');

    if (receiverUsername == null) {
      return;
    }

    final response = await http.post(
      Uri.parse('http://172.20.10.9:8080/friend/respond'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': senderUsername,
        'username2': receiverUsername,
        'status': accept ? 'accepted' : 'declined'
      }),
    );*/

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
        title: Text('Friend Requests', style: TextStyle(color: Colors.white)),
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
                    subtitle: Text('Request from: ${request.username}'),
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
                          tooltip: 'Accept',
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
                          tooltip: 'Decline',
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
                // Already on this screen
              },
              tooltip: '친구 요청 확인',
            ),
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


/*class FriendRequestsScreen extends StatefulWidget {
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
    // 하드코딩된 데이터 사용
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    return [
      FriendRequest(senderUsername: 'friend1'),
      FriendRequest(senderUsername: 'friend2'),
    ];
  }

  void _respondToRequest(String senderUsername, bool accept) {
    // 서버 요청 부분을 주석 처리하고 대신 하드코딩된 상태 메시지 설정
    print(accept ? 'Accepted $senderUsername' : 'Declined $senderUsername');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Requests', style: TextStyle(color: Colors.white)),
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
                    title: Text(request.senderUsername),
                    subtitle: Text('Request from: ${request.senderUsername}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            _respondToRequest(request.senderUsername, true);
                          },
                          tooltip: 'Accept',
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            _respondToRequest(request.senderUsername, false);
                          },
                          tooltip: 'Decline',
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
                // Already on this screen
              },
              tooltip: '친구 요청 확인',
            ),
          ],
        ),
      ),
    );
  }
}

class FriendRequest {
  final String senderUsername;

  FriendRequest({required this.senderUsername});

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      senderUsername: json['username'],
    );
  }
}*/