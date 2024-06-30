import 'package:flutter/material.dart';
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
  String _inviteUsername = '';

  Future<void> _inviteFriend() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      print('Username not found in SharedPreferences');
      return;
    }

    print('Inviting friend: $_inviteUsername');

    final url = Uri.parse('$baseUrl/promise/invitation');
    final headers = {
      'Content-Type': 'application/json',
      'username': username,
    };
    final body = jsonEncode({
      'promiseId': widget.promiseId,
      'inviteUsername': _inviteUsername,
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
                  _inviteUsername = value;
                },
                onSaved: (value) {
                  _inviteUsername = value!;
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
