import 'package:flutter/foundation.dart'; // foundation 임포트
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'package:universal_html/html.dart' as html;
import 'dart:ui' as ui;
import './config.dart';
import 'recommend_place.dart';
import 'realtime_location.dart';
import 'main_list.dart'; // 추가된 임포트
import 'appointment_result.dart'; //약속결과

class AppointmentDetailScreen extends StatefulWidget {
  final int promiseId;

  AppointmentDetailScreen({required this.promiseId});

  @override
  _AppointmentDetailScreenState createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late Future<Map<String, dynamic>> _futureAppointment;
  late Completer<WebViewController> _controllerCompleter;
  String? message; // message 변수를 nullable로 정의
  bool iframeLoaded = false; // iframe 로드 상태를 추적하는 변수 추가

  @override
  void initState() {
    super.initState();
    _controllerCompleter = Completer<WebViewController>();

    _fetchAndSendAppointmentDetail(); // 초기 데이터 로드 및 전송

    if (kIsWeb) {
      _registerIframeElement(widget.promiseId);
    }
  }

  @override
  void didUpdateWidget(AppointmentDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.promiseId != oldWidget.promiseId) {
      iframeLoaded = false; // iframe 로드 상태 초기화
      _fetchAndSendAppointmentDetail();
      if (kIsWeb) {
        _registerIframeElement(widget.promiseId);
      }
    }
  }

  Future<void> _fetchAndSendAppointmentDetail() async {
    try {
      final appointment = await _fetchAppointmentDetail();
      final latitude = double.parse(appointment['latitude'].toString());
      final longitude = double.parse(appointment['longitude'].toString());
      message = jsonEncode({'latitude': latitude, 'longitude': longitude});

      if (iframeLoaded) {
        _sendMessageToIframe();
      }
    } catch (e) {
      print('Failed to fetch appointment detail: $e');
    }
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

  Future<void> _loadHtmlFromAssets(double latitude, double longitude) async {
    String fileText = await rootBundle.loadString('assets/index2.html');
    fileText = fileText.replaceAll('{LATITUDE}', latitude.toString());
    fileText = fileText.replaceAll('{LONGITUDE}', longitude.toString());
    final controller = await _controllerCompleter.future;
    controller.loadUrl(
        Uri.dataFromString(fileText, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString());
  }

  void _registerIframeElement(int promiseId) {
    final iframe = html.IFrameElement()
      ..width = '100%'
      ..height = '100%'
      ..style.border = 'none'
      ..src = 'assets/index2.html';

    iframe.onLoad.listen((event) {
      print("Iframe loaded");
      iframeLoaded = true; // iframe 로드 상태 업데이트
      if (message != null) {
        _sendMessageToIframe();
      }
    });

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('iframeElement${promiseId}', (int viewId) => iframe);
  }

  void _sendMessageToIframe() {
    if (!iframeLoaded) {
      print("Iframe not loaded yet, delaying message sending.");
      // iframe이 로드될 때까지 대기
      return;
    }
    print("Sending message to iframe: $message");
    final iframe = html.document.querySelector('iframe') as html.IFrameElement?;
    if (iframe != null) {
      print("Iframe found: true");
      iframe.contentWindow?.postMessage(message, '*');
    } else {
      print("Iframe found: false");
    }
  }

  void _sendMessageToWebView() {
    if (!kIsWeb) {
      _controllerCompleter.future.then((controller) {
        if (message != null) {
          controller.runJavascript("receiveMessage('$message')");
        }
      });
    } else {
      print("Sending message to iframe: $message");
      final iframe = html.document.querySelector('iframe') as html.IFrameElement?;
      if (iframe != null) {
        print("Iframe found: true");
        iframe.contentWindow?.postMessage(message, '*');
      } else {
        print("Iframe found: false");
      }
    }
  }

  void _navigateToRecommendPlaceScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecommendPlaceScreen(promiseId: widget.promiseId),
      ),
    );
  }

  void _navigateToRealTimeLocationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RealTimeLocationScreen(promiseId: widget.promiseId),
      ),
    );
  }

  //약속결과화면으로 이동
  void _navigateToAppointmentResultScreen() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AppointmentResultScreen(promiseId: widget.promiseId),
    ),
  );
}

  bool _isPenaltyButtonEnabled(DateTime appointmentDateTime) {
    DateTime now = DateTime.now();
    return now.isAfter(appointmentDateTime);
  }

  Future<void> _handlePenaltySettlement() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      print('Username not found in SharedPreferences');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment/reward'),
        headers: {'Content-Type': 'application/json', 'username': username},
        body: jsonEncode({'promiseId': widget.promiseId}),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('성공'),
              content: Text('벌금정산이 완료되었습니다'),
              actions: <Widget>[
                TextButton(
                  child: Text('확인'),
                  onPressed: () {
                    Navigator.pop(context); // AlertDialog 닫기
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MainList()),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        print('Failed to settle penalty');
      }
    } catch (e) {
      print('Error settling penalty: $e');
    }
  }

  void _showPenaltyWarning() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text('약속시간이 지난 후 정산이 가능합니다'),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.pop(context); // AlertDialog 닫기
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('약속 상세정보', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchAppointmentDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final appointment = snapshot.data!;
            final latitude = double.parse(appointment['latitude'].toString());
            final longitude = double.parse(appointment['longitude'].toString());
            final date = appointment['date'];
            final time = appointment['time'];
            final dateTimeString = '$date $time';
            final appointmentDateTime = DateTime.parse(dateTimeString);
            message = jsonEncode({'latitude': latitude, 'longitude': longitude}); // 메시지 초기화
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _sendMessageToIframe();
            });
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Card(
                      color: Colors.white,
                      child: ListTile(
                        title: Text('약속 이름', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(appointment['title']),
                      ),
                    ),
                    SizedBox(height: 10),
                    Card(
                      color: Colors.white,
                      child: ListTile(
                        title: Text('날짜', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(date),
                      ),
                    ),
                    SizedBox(height: 10),
                    Card(
                      color: Colors.white,
                      child: ListTile(
                        title: Text('시간', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(time),
                      ),
                    ),
                    SizedBox(height: 10),
                    Card(
                      color: Colors.white,
                      child: ListTile(
                        title: Text('벌금', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(appointment['penalty'].toString()),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '약속 참가자:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: (appointment['participantUsernames'] as List<dynamic>)
                              .map((username) => Chip(label: Text(username)))
                              .toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '약속장소:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Container(
                      width: double.infinity,
                      height: 300,
                      child: kIsWeb
                          ? HtmlElementView(viewType: 'iframeElement${widget.promiseId}')
                          : WebView(
                              initialUrl: '',
                              onWebViewCreated: (WebViewController webViewController) {
                                _controllerCompleter.complete(webViewController);
                                _loadHtmlFromAssets(latitude, longitude);
                              },
                              javascriptMode: JavascriptMode.unrestricted,
                            ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        /*ElevatedButton(
                          onPressed: _navigateToRecommendPlaceScreen,
                          child: Text('주변추천장소', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 36, 115, 179),
                          ),
                        ),*/
                        ElevatedButton(
                          onPressed: _navigateToRealTimeLocationScreen,
                          child: Text('실시간위치', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 36, 115, 179),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isPenaltyButtonEnabled(appointmentDateTime)
                              ? _handlePenaltySettlement
                              : _showPenaltyWarning,
                          child: Text('벌금정산', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        ),
                        //약속결과확인 버튼 추가
                        ElevatedButton(
                          onPressed: _navigateToAppointmentResultScreen,
                          child: Text('약속결과확인', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // 색상 변경 예정
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
