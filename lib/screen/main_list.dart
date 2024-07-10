//최종(삭제기능까지 다 완료) original
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './config.dart';
import './add_appointment.dart';
import './login.dart';
import './appointment_detail.dart';
import './friend_list.dart';
import './map_screen.dart';
import './invite_appointment.dart'; // import invite_appointment.dart
import './invite_agree.dart'; // import invite_agree.dart
import './test.dart';


class MainList extends StatefulWidget {
  @override
  _MainListState createState() => _MainListState();
}

class _MainListState extends State<MainList> {
  final List<Appointment> appointments = [];
  String? username;
  int? userPoints;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadAppointments();
    _fetchAppointmentsFromServer();
    _fetchUserPoints();
  }

  @override
  void dispose() {
    _saveAppointments();
    super.dispose();
  }

  void _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
    });
  }

  void _loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? appointmentsString = prefs.getString('appointments');
    if (appointmentsString != null) {
      final List<dynamic> appointmentsJson = jsonDecode(appointmentsString);
      setState(() {
        appointments.clear();
        appointments.addAll(appointmentsJson.map((json) => Appointment.fromJson(json)).toList());
      });
    }
  }

  void _saveAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final String appointmentsString = jsonEncode(appointments.map((appointment) => appointment.toJson()).toList());
    prefs.setString('appointments', appointmentsString);
  }

  void _addAppointment(Appointment appointment) {
    setState(() {
      appointments.add(appointment);
    });
    _saveAppointments();
  }

  Future<void> _fetchAppointmentsFromServer() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      print('Username not found in SharedPreferences');
      return;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/promise'),
      headers: {'username': username},
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        appointments.clear();
        appointments.addAll(data.map((json) => Appointment.fromJson(json)).toList());
      });
      _saveAppointments();
    } else {
      print('Failed to load appointments from server');
    }
  }

  Future<void> _fetchUserPoints() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      print('Username not found in SharedPreferences');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/money'),
        headers: {'username': username},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['money'] != null && data['money'] is int) {
          setState(() {
            userPoints = data['money'];
          });
        } else {
          print('Error: money value is null or not an integer');
        }
      } else {
        print('Failed to load user points from server');
      }
    } catch (e) {
      print('Error fetching user points: $e');
    }
  }

  Future<void> _deleteAppointment(int promiseId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      print('Username not found in SharedPreferences');
      return;
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/promise/$promiseId'),
      headers: {'username': username},
    );

    if (response.statusCode == 200) {
      setState(() {
        appointments.removeWhere((appointment) => appointment.promiseId == promiseId);
      });
      _saveAppointments();
    } else {
      print('Failed to delete appointment from server');
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LogIn()),
    );
  }

  void _inviteToAppointment(int promiseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InviteAppointmentScreen(promiseId: promiseId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Appointments', style: TextStyle(color: Colors.white)),
            Spacer(),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${userPoints ?? 0} p',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      body: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return Card(
            child: ListTile(
              title: Text(
                appointment.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              subtitle: Text('${appointment.date} @ ${appointment.time}',
                style: TextStyle(color: Colors.grey),),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _inviteToAppointment(appointment.promiseId);
                    },
                    child: Text('약속초대',
                    style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 36, 115, 179),
                    ),
                  ),
                  if (appointment.creatorUsername == username) // Add condition to show delete button only for the creator
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteAppointment(appointment.promiseId);
                      },
                      tooltip: '삭제',
                    ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentDetailScreen(promiseId: appointment.promiseId),
                  ),
                );
              },
            ),
          );
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
                // Navigate to home
              },
              tooltip: '홈',
            ),
            IconButton(
              icon: Icon(Icons.list, color: Colors.blueGrey),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FriendListScreen()),
                );
              },
              tooltip: '친구 목록',
            ),
            IconButton(
              icon: Icon(Icons.mail, color: Colors.blueGrey),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InviteAgreeScreen()),
                );
              },
              tooltip: '약속 초대 요청 확인',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WebPage(nextRoute: AddAppointmentScreen())),
          );
          if (result != null) {
            _addAppointment(result);
          }
        },
        tooltip: '새로운 약속 추가',
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class Appointment {
  final String title;
  final String date;
  final String time;
  final int promiseId;
  final String creatorUsername;

  Appointment({required this.title, required this.date, required this.time, required this.promiseId, required this.creatorUsername});

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': date,
        'time': time,
        'promiseId': promiseId,
        'creatorUsername': creatorUsername,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      title: json['title'],
      date: json['date'],
      time: json['time'],
      promiseId: json['promiseId'],
      creatorUsername: json['creatorUsername'],
    );
  }
}











//약속삭제기능-수정1(참여자에게도 삭제버튼 보이는상태)

/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './config.dart';
import './add_appointment.dart';
import './login.dart';
import './appointment_detail.dart';
import './friend_list.dart';
import './map_screen.dart';
import './invite_appointment.dart'; // import invite_appointment.dart
import './invite_agree.dart'; // import invite_agree.dart

class MainList extends StatefulWidget {
  @override
  _MainListState createState() => _MainListState();
}

class _MainListState extends State<MainList> {
  final List<Appointment> appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _fetchAppointmentsFromServer();
  }

  @override
  void dispose() {
    _saveAppointments();
    super.dispose();
  }

  void _loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? appointmentsString = prefs.getString('appointments');
    if (appointmentsString != null) {
      final List<dynamic> appointmentsJson = jsonDecode(appointmentsString);
      setState(() {
        appointments.clear();
        appointments.addAll(appointmentsJson.map((json) => Appointment.fromJson(json)).toList());
      });
    }
  }

  void _saveAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final String appointmentsString = jsonEncode(appointments.map((appointment) => appointment.toJson()).toList());
    prefs.setString('appointments', appointmentsString);
  }

  void _addAppointment(Appointment appointment) {
    setState(() {
      appointments.add(appointment);
    });
    _saveAppointments();
  }

  Future<void> _fetchAppointmentsFromServer() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      print('Username not found in SharedPreferences');
      return;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/promise'),
      headers: {'username': username},
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        appointments.clear();
        appointments.addAll(data.map((json) => Appointment.fromJson(json)).toList());
      });
      _saveAppointments();
    } else {
      // Handle the error
      print('Failed to load appointments from server');
    }
  }

  Future<void> _deleteAppointment(int promiseId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      print('Username not found in SharedPreferences');
      return;
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/promise/$promiseId'),
      headers: {'username': username},
    );

    if (response.statusCode == 200) {
      setState(() {
        appointments.removeWhere((appointment) => appointment.promiseId == promiseId);
      });
      _saveAppointments();
    } else {
      // Handle the error
      print('Failed to delete appointment from server');
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LogIn()),
    );
  }

  void _inviteToAppointment(int promiseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InviteAppointmentScreen(promiseId: promiseId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return Card(
            child: ListTile(
              title: Text(
                appointment.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              subtitle: Text('${appointment.date} @ ${appointment.time}',
                style: TextStyle(color: Colors.grey),),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _inviteToAppointment(appointment.promiseId);
                    },
                    child: Text('약속초대',
                    style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 36, 115, 179),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteAppointment(appointment.promiseId);
                    },
                    tooltip: '삭제',
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentDetailScreen(promiseId: appointment.promiseId),
                  ),
                );
              },
            ),
          );
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
                // Navigate to home
              },
              tooltip: '홈',
            ),
            IconButton(
              icon: Icon(Icons.list, color: Colors.blueGrey),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FriendListScreen()),
                );
              },
              tooltip: '친구 목록',
            ),
            IconButton(
              icon: Icon(Icons.mail, color: Colors.blueGrey),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InviteAgreeScreen()),
                );
              },
              tooltip: '약속 초대 요청 확인',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WebPage(nextRoute: AddAppointmentScreen())),
          );
          if (result != null) {
            _addAppointment(result);
          }
        },
        tooltip: '새로운 약속 추가',
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
*/




//original 코드 (약속삭제기능 전)
/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './config.dart';
import './add_appointment.dart';
import './login.dart';
import './appointment_detail.dart';
import './friend_list.dart';
import './map_screen.dart';
import './invite_appointment.dart'; // import invite_appointment.dart
import './invite_agree.dart'; // import invite_agree.dart

class MainList extends StatefulWidget {
  @override
  _MainListState createState() => _MainListState();
}

class _MainListState extends State<MainList> {
  final List<Appointment> appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _fetchAppointmentsFromServer();
  }

  @override
  void dispose() {
    _saveAppointments();
    super.dispose();
  }

  void _loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? appointmentsString = prefs.getString('appointments');
    if (appointmentsString != null) {
      final List<dynamic> appointmentsJson = jsonDecode(appointmentsString);
      setState(() {
        appointments.clear();
        appointments.addAll(appointmentsJson.map((json) => Appointment.fromJson(json)).toList());
      });
    }
  }

  void _saveAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final String appointmentsString = jsonEncode(appointments.map((appointment) => appointment.toJson()).toList());
    prefs.setString('appointments', appointmentsString);
  }

  void _addAppointment(Appointment appointment) {
    setState(() {
      appointments.add(appointment);
    });
    _saveAppointments();
  }

  Future<void> _fetchAppointmentsFromServer() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      print('Username not found in SharedPreferences');
      return;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/promise'),
      headers: {'username': username},
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        appointments.clear();
        appointments.addAll(data.map((json) => Appointment.fromJson(json)).toList());
      });
      _saveAppointments();
    } else {
      // Handle the error
      print('Failed to load appointments from server');
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LogIn()),
    );
  }

  void _inviteToAppointment(int promiseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InviteAppointmentScreen(promiseId: promiseId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return Card(
            child: ListTile(
              title: Text(
                appointment.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              subtitle: Text('${appointment.date} @ ${appointment.time}',
                style: TextStyle(color: Colors.grey),),
              trailing: ElevatedButton(
                onPressed: () {
                  _inviteToAppointment(appointment.promiseId);
                },
                child: Text('약속초대',
                style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 36, 115, 179),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentDetailScreen(promiseId: appointment.promiseId),
                  ),
                );
              },
            ),
          );
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
                // Navigate to home
              },
              tooltip: '홈',
            ),
            IconButton(
              icon: Icon(Icons.list, color: Colors.blueGrey),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FriendListScreen()),
                );
              },
              tooltip: '친구 목록',
            ),
            IconButton(
              icon: Icon(Icons.mail, color: Colors.blueGrey),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InviteAgreeScreen()),
                );
              },
              tooltip: '약속 초대 요청 확인',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WebPage(nextRoute: AddAppointmentScreen())),
          );
          if (result != null) {
            _addAppointment(result);
          }
        },
        tooltip: '새로운 약속 추가',
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
}*/




