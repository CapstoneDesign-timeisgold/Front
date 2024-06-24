import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './config.dart';

/*class AppointmentDetailScreen extends StatefulWidget {
  final int promiseId;

  AppointmentDetailScreen({required this.promiseId});

  @override
  _AppointmentDetailScreenState createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late Future<Map<String, dynamic>> _futureAppointment;

  @override
  void initState() {
    super.initState();
    _futureAppointment = _fetchAppointmentDetail();
  }

  Future<Map<String, dynamic>> _fetchAppointmentDetail() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      print('Username not found in SharedPreferences');
      return Future.error('Username not found in SharedPreferences');
    }

    final response = await http.get(Uri.parse('$baseUrl/promise/${widget.promiseId}'),
    headers: {'username': username},);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load appointment detail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Detail', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureAppointment,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final appointment = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Title: ${appointment['title']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('Date: ${appointment['date']}'),
                  Text('Time: ${appointment['time']}'),
                  Text('Location: ${appointment['location']}'),
                  Text('Penalty: ${appointment['penalty']}'),
                  Text('Promise ID: ${appointment['promiseId']}'),
                  SizedBox(height: 20),
                  Text(
                    'Participants:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (appointment['participantUsernames'] as List<dynamic>)
                        .map((participant) => Text('Username: ${participant['username']}'))
                        .toList(),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}*/

class AppointmentDetailScreen extends StatefulWidget {
  final int promiseId;

  AppointmentDetailScreen({required this.promiseId});

  @override
  _AppointmentDetailScreenState createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late Future<Map<String, dynamic>> _futureAppointment;

  @override
  void initState() {
    super.initState();
    _futureAppointment = _fetchAppointmentDetail();
  }

  Future<Map<String, dynamic>> _fetchAppointmentDetail() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      print('Username not found in SharedPreferences');
      return Future.error('Username not found in SharedPreferences');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/promise/${widget.promiseId}'),
      headers: {'username': username},
    );

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to load appointment detail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Detail', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureAppointment,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final appointment = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Title: ${appointment['title']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('Date: ${appointment['date']}'),
                  Text('Time: ${appointment['time']}'),
                  //Text('Location: ${appointment['location']}'),
                  Text('Penalty: ${appointment['penalty']}'),
                  //Text('Promise ID: ${appointment['promiseId']}'),
                  SizedBox(height: 20),
                  Text(
                    'Participants:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (appointment['participantUsernames'] as List<dynamic>)
                        .map((username) => Text('Username: $username'))
                        .toList(),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}