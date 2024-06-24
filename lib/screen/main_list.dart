
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './map_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './add_appointment.dart';
import './login.dart';
import './appointment_detail.dart';
import './friend_list.dart';
import './config.dart';


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
                // Navigate to friends list
              },
              tooltip: '친구 목록',
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

class Appointment_detail {
  final String title;
  final String date;
  final String time;
  final int penalty;
  final String location;
  final int promiseId;
  final List<String> participantUsernames; // 새로 추가된 속성

  Appointment_detail({
    required this.title,
    required this.date,
    required this.time,
    required this.penalty,
    required this.location,
    required this.promiseId,
    required this.participantUsernames // 새로 추가된 매개변수
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': date,
        'time': time,
        'penalty': penalty,
        'location': location,
        'promiseId': promiseId,
        'participantUsernames': participantUsernames, // 새로 추가된 속성
      };

  factory Appointment_detail.fromJson(Map<String, dynamic> json) {
    return Appointment_detail(
      title: json['title'],
      date: json['date'],
      time: json['time'],
      penalty: json['penalty'],
      location: json['location'],
      promiseId: json['promiseId'],
      participantUsernames: List<String>.from(json['participantUsernames']), // 새로 추가된 속성
    );
  }
}

class Appointment {
  final String title;
  final String date;
  final String time;
  final int promiseId;

  Appointment({required this.title,
    required this.date,
    required this.time,
    required this.promiseId});

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







/*class MainList extends StatefulWidget {
  @override
  _MainListState createState() => _MainListState();
}

class _MainListState extends State<MainList> {
  final List<Appointment> appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
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

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LogIn()),
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
              icon: Icon(Icons.list, color: Colors.blueGrey),
              onPressed: () {
              /*Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MapScreen()),
                            );// Navigate to friends list */
              },
              tooltip: '친구 목록',
            ),
            IconButton(
              icon: Icon(Icons.person_add, color: Colors.blueGrey),
              onPressed: () {
                // Navigate to add friend
              },
              tooltip: '친구 추가',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAppointmentScreen()),
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

  Appointment({required this.title, required this.date, required this.time});

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': date,
        'time': time,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      title: json['title'],
      date: json['date'],
      time: json['time'],
    );
  }
}*/