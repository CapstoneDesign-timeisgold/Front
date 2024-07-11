import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './map_screen.dart';
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

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    if (arguments != null) {
      _latitude = double.parse(arguments['latitude']);
      _longitude = double.parse(arguments['longitude']);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _date = DateFormat('yyyy-MM-dd').format(picked);
        _dateController.text = _date;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _time = '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
        _timeController.text = _time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새로운 약속 생성', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '약속이름',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                SizedBox(height: 24),
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: '약속날짜 (YYYY-MM-DD)',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
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
                SizedBox(height: 24),
                TextFormField(
                  controller: _timeController,
                  decoration: InputDecoration(
                    labelText: '약속시간 (HH:mm)',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  readOnly: true,
                  onTap: () => _selectTime(context),
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
                SizedBox(height: 24),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '지각 벌금',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
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
                            MaterialPageRoute(builder: (context) => MainList(shouldRefresh: true)),
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
                    child: Text('확인', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 36, 115, 179),
                    ),
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








/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './map_screen.dart';
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

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    if (arguments != null) {
      _latitude = double.parse(arguments['latitude']);
      _longitude = double.parse(arguments['longitude']);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _date = DateFormat('yyyy-MM-dd').format(picked);
        _dateController.text = _date;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _time = '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
        _timeController.text = _time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새로운 약속 생성', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '약속이름',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                SizedBox(height: 24),
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: '약속날짜 (YYYY-MM-DD)',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
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
                SizedBox(height: 24),
                TextFormField(
                  controller: _timeController,
                  decoration: InputDecoration(
                    labelText: '약속시간 (HH:mm)',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  readOnly: true,
                  onTap: () => _selectTime(context),
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
                SizedBox(height: 24),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '지각 벌금',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
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
                    child: Text('확인', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 36, 115, 179),
                    ),
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
}*/



