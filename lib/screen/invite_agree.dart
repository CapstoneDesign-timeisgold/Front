import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './config.dart';
import './main_list.dart';

class InviteAgreeScreen extends StatefulWidget {
  @override
  _InviteAgreeScreenState createState() => _InviteAgreeScreenState();
}

class _InviteAgreeScreenState extends State<InviteAgreeScreen> {
  late Future<List<InviteRequest>> _futureRequests;

  @override
  void initState() {
    super.initState();
    _futureRequests = _fetchInviteRequests();
  }

  Future<List<InviteRequest>> _fetchInviteRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      return Future.error('Username not found in SharedPreferences');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/promise/invitation/$username'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => InviteRequest.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load invite requests');
    }
  }

  Future<void> _respondToInvite(int participantId, int promiseId, bool accept) async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      print('Username not found in SharedPreferences');
      return;
    }

    final String url = accept
        ? '$baseUrl/promise/accept/$participantId'
        : '$baseUrl/promise/decline/$participantId';
    
    final body = jsonEncode({
      'message': accept ? 'invite request accepted' : 'invite request declined',
      'participantId': participantId,
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'username': username,
      },
      body: body,
    );

    if (response.statusCode == 200) {
      if (accept) {
        await _addAppointmentToMainList(promiseId);  // 여기서 promiseId를 사용
      }
      setState(() {
        _futureRequests = _fetchInviteRequests();
      });
    } else {
      print('Failed to respond to invite request. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> _addAppointmentToMainList(int promiseId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      print('Username not found in SharedPreferences');
      return;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/promise/$promiseId'),
      headers: {'username': username},
    );

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      final Appointment appointment = Appointment.fromJson(data);
      // Save appointment to local storage
      final String appointmentsString = prefs.getString('appointments') ?? '[]';
      final List<dynamic> appointmentsJson = jsonDecode(appointmentsString);
      appointmentsJson.add(appointment.toJson());
      prefs.setString('appointments', jsonEncode(appointmentsJson));
      // Navigate back to main list
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainList()),
      );
    } else {
      print('Failed to load appointment details. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invite Requests', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      body: FutureBuilder<List<InviteRequest>>(
        future: _futureRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No invite requests found.'));
          } else {
            final requests = snapshot.data!;
            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return Card(
                  child: ListTile(
                    title: Text('Request from: ${request.hostUsername}'),
                    subtitle: Text('Promise ID: ${request.promiseId}\nGuest: ${request.guestUsername}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            _respondToInvite(request.participantId, request.promiseId, true);
                          },
                          tooltip: 'Accept',
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            _respondToInvite(request.participantId, request.promiseId, false);
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
              icon: Icon(Icons.mail, color: Colors.blueGrey),
              onPressed: () {
                // Already on this screen
              },
              tooltip: '약속 초대 요청 확인',
            ),
          ],
        ),
      ),
    );
  }
}

// InviteRequest 클래스 수정
class InviteRequest {
  final int promiseId;
  final String hostUsername;
  final String guestUsername;
  final int participantId;

  InviteRequest({required this.promiseId, required this.hostUsername, required this.guestUsername, required this.participantId});

  factory InviteRequest.fromJson(Map<String, dynamic> json) {
    return InviteRequest(
      promiseId: json['promiseId'],
      hostUsername: json['hostUsername'],
      guestUsername: json['guestUsername'],
      participantId: json['participantId'],
    );
  }
}

class Appointment {
  final String title;
  final String date;
  final String time;
  final int promiseId;

  Appointment({required this.title, required this.date, required this.time, required this.promiseId});

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': date,
        'time': time,
        'promiseId': promiseId,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      title: json['title'],
      date: json['date'],
      time: json['time'],
      promiseId: json['promiseId'],
    );
  }
}
