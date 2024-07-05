
//실행할때 쓰는 코드(original)
import 'package:flutter/material.dart';
import './map_screen.dart'; // map_screen.dart를 임포트
import '../service/add_appointment_service.dart';
import './config.dart';
import './main_list.dart';

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
  double _latitude = 0;
  double _longitude = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    if (arguments != null) {
      _latitude = double.parse(arguments['latitude']);
      _longitude = double.parse(arguments['longitude']);
    }
  }

  /*void _onLocationSelected(int locationId) {
    setState(() {
      _locationId = locationId;
    });
  }*/

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
                SizedBox(height: 20),
                Text('Latitude: $_latitude'),
                Text('Longitude: $_longitude'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      final addAppointmentService = AddAppointmentService();
                      bool success = await addAppointmentService.addAppointment(
                        _title, _date, _time, _penalty, _latitude, _longitude);

                      if (success) {
                        final newAppointment = Appointment(
                          label: _title,
                          date: _date,
                          time: _time,
                          penalty: _penalty,
                          latitude: _latitude,
                          longitude: _longitude,
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MainList()),
                        );
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
  final double latitude;
  final double longitude;

  Appointment({
    required this.label,
    required this.date,
    required this.time,
    required this.penalty,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'date': date,
        'time': time,
        'penalty': penalty,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      label: json['label'],
      date: json['date'],
      time: json['time'],
      penalty: json['penalty'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}



