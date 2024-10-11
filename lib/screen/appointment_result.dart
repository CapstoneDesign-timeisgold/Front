//약속결과확인 화면
/*import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class AppointmentResultScreen extends StatefulWidget {
  final int promiseId;

  AppointmentResultScreen({required this.promiseId});

  @override
  _AppointmentResultScreenState createState() => _AppointmentResultScreenState();
}

class _AppointmentResultScreenState extends State<AppointmentResultScreen> {
  late Future<Map<String, dynamic>> _futureResult;

  @override
  void initState() {
    super.initState();
    _futureResult = _fetchAppointmentResult();
  }

  Future<Map<String, dynamic>> _fetchAppointmentResult() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      throw Exception('Username not found in SharedPreferences');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/promise/${widget.promiseId}/result'),
      headers: {'username': username},
    );

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to load appointment result');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('약속 결과 확인'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureResult,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final result = snapshot.data!;
            final lateParticipants = result['lateParticipants'] as List<dynamic>;
            final onTimeParticipants = result['onTimeParticipants'] as List<dynamic>;
            final totalPenaltyCollected = result['totalPenaltyCollected'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                    color: Colors.white,
                    child: ListTile(
                      title: Text('약속 이름', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(result['title']),
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    color: Colors.white,
                    child: ListTile(
                      title: Text('벌금', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(result['penalty'].toString()),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '지각한 사람 및 벌금:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Card(
                    color: Colors.white,
                    child: Column(
                      children: lateParticipants.map((participant) {
                        return ListTile(
                          title: Text(participant['username']),
                          trailing: Text(
                            '-${participant['penaltyAmount']}',
                            style: TextStyle(
                              color: Colors.blue, // 음수는 파란색
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '약속 지킨 사람 및 보상:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Card(
                    color: Colors.white,
                    child: Column(
                      children: onTimeParticipants.map((participant) {
                        return ListTile(
                          title: Text(participant['username']),
                          trailing: Text(
                            '+${participant['rewardAmount']}',
                            style: TextStyle(
                              color: Colors.red, // 양수는 빨간색
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    color: Colors.white,
                    child: ListTile(
                      title: Text('총 벌금액', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text('${totalPenaltyCollected}'),
                    ),
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
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class AppointmentResultScreen extends StatefulWidget {
  final int promiseId;

  AppointmentResultScreen({required this.promiseId});

  @override
  _AppointmentResultScreenState createState() => _AppointmentResultScreenState();
}

class _AppointmentResultScreenState extends State<AppointmentResultScreen> {
  late Future<Map<String, dynamic>> _futureResult;

  @override
  void initState() {
    super.initState();
    _futureResult = _fetchAppointmentResult();
  }

  Future<Map<String, dynamic>> _fetchAppointmentResult() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      throw Exception('Username not found in SharedPreferences');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/promise/${widget.promiseId}/result'),
      headers: {'username': username},
    );

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to load appointment result');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('약속 결과 확인'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureResult,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final result = snapshot.data!;

            // Null 체크 후 빈 리스트와 기본값으로 초기화
            final lateUsers = result['lateUsers'] ?? [];
            final onTimeUsers = result['onTimeUsers'] ?? [];
            final totalPenalty = result['totalPenalty'] ?? 0;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20),
                  Text(
                    '지각한 사람 및 벌금:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Card(
                    color: Colors.white,
                    child: Column(
                      children: [
                        for (var user in lateUsers)
                          ListTile(
                            title: Text(user['username'] ?? '알 수 없음'),
                            trailing: Text(
                              '-${user['penaltyAmount'] ?? 0}',
                              style: TextStyle(
                                color: Colors.blue, // 음수는 파란색
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '약속 지킨 사람 및 보상:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Card(
                    color: Colors.white,
                    child: Column(
                      children: [
                        for (var user in onTimeUsers)
                          ListTile(
                            title: Text(user['username'] ?? '알 수 없음'),
                            trailing: Text(
                              '+${user['rewardAmount'] ?? 0}',
                              style: TextStyle(
                                color: Colors.red, // 양수는 빨간색
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    color: Colors.white,
                    child: ListTile(
                      title: Text('총 벌금액', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text('${totalPenalty}'),
                    ),
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
