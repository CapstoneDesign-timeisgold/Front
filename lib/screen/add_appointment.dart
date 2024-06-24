
import 'package:flutter/material.dart';
import './map_screen.dart'; // map_screen.dart를 임포트
import '../service/add_appointment_service.dart';
import './config.dart';

class AddAppointmentScreen extends StatefulWidget {
  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _date = '';
  String _time = '';
  int _penalty = 0;
  //String _location = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Appointment', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _title = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Date (YYYY/MM/DD)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a date';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _date = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Time (HH:mm)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a time';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _time = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Penalty'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a penalty';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _penalty = int.parse(value!);
                  },
                ),
                /*TextFormField(
                  decoration: InputDecoration(labelText: 'Location'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _location = value!;
                  },
                ),*/
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      final addAppointmentService = AddAppointmentService();
                      bool success = await addAppointmentService.addAppointment(
                        _title, _date, _time, _penalty/*, _location*/);

                      if (success) {
                        final newAppointment = Appointment(
                          label: _title,
                          date: _date,
                          time: _time,
                          penalty: _penalty,
                          //location: _location,
                        );
                        Navigator.pop(context, newAppointment);
                        /*Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WebPage()), // map_screen.dart로 네비게이트
                        );*/
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text('Failed to add appointment. Please try again.'),
                              actions: <Widget>[
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  child: Text('다음', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 36, 115, 179),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Appointment {
  final String label;
  final String date;
  final String time;
  final int penalty;
  //final String location;

  Appointment({
    required this.label,
    required this.date,
    required this.time,
    required this.penalty,
    //required this.location,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'date': date,
        'time': time,
        'penalty': penalty,
        //'location': location,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      label: json['label'],
      date: json['date'],
      time: json['time'],
      penalty: json['penalty'],
      //location: json['location'],
    );
  }
}


