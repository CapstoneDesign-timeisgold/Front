import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:ui' as ui;
import './config.dart';

class RealTimeLocationScreen extends StatefulWidget {
  final int promiseId;

  RealTimeLocationScreen({required this.promiseId});

  @override
  _RealTimeLocationScreenState createState() => _RealTimeLocationScreenState();
}

class _RealTimeLocationScreenState extends State<RealTimeLocationScreen> {
  late Completer<WebViewController> _controllerCompleter;
  String? message;
  bool iframeLoaded = false;
  int? promiseId;
  String? username; // username 추가

  @override
  void initState() {
    super.initState();
    _controllerCompleter = Completer<WebViewController>();

    _fetchAndSendAppointmentDetail();  // 초기 데이터 로드 및 전송

    if (kIsWeb) {
      _registerIframeElement(widget.promiseId);
    }

    // 메시지 리스너 등록
    html.window.onMessage.listen((event) {
      if (event.data == 'data1') {
        _updateLateStatus(true);
      } else if (event.data == 'data2') {
        _updateLateStatus(false);
      }
    });
  }

  @override
  void didUpdateWidget(RealTimeLocationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.promiseId != oldWidget.promiseId) {
      iframeLoaded = false;
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
      final date = appointment['date'];
      final time = appointment['time'];
      final dateTime = '${date}T${time}:00';  // 약속 시간을 'YYYY-MM-DDTHH:MM:SS' 형식으로 변환
      promiseId = appointment['promiseId'];

      message = jsonEncode({
        'type': 'appointment',
        'latitude': latitude,
        'longitude': longitude,
        'dateTime': dateTime,
      });

      if (iframeLoaded) {
        _sendMessageToIframe();
      }
    } catch (e) {
      print('Failed to fetch appointment detail: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchAppointmentDetail() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username'); // username 가져오기

    if (username == null) {
      print('Username not found in SharedPreferences');
      return Future.error('Username not found in SharedPreferences');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/promise/${widget.promiseId}'),
      headers: {'username': username!},
    );

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to load appointment detail');
    }
  }

  void _registerIframeElement(int promiseId) {
    final iframe = html.IFrameElement()
      ..width = '100%'
      ..height = '100%'
      ..style.border = 'none'
      ..src = 'assets/index3.html';

    iframe.onLoad.listen((event) {
      print("Iframe loaded");
      iframeLoaded = true;
      if (message != null) {
        _sendMessageToIframe();
      }
    });

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('iframeElement25', (int viewId) => iframe);
  }

  void _sendMessageToIframe() {
    if (!iframeLoaded) {
      print("Iframe not loaded yet, delaying message sending.");
      return;
    }
    print("Sending message to iframe: $message");
    final iframe = html.document.querySelector('iframe[src="assets/index3.html"]') as html.IFrameElement?;
    if (iframe != null) {
      print("Iframe found: true");
      iframe.contentWindow?.postMessage(message, '*');
    } else {
      print("Iframe found: false");
    }
  }

  void _sendMessageToWebView() {
    _controllerCompleter.future.then((controller) {
      if (message != null) {
        controller.runJavascript("receiveMessage('$message')");
      }
    });
  }

  Future<void> _updateLateStatus(bool late) async {
    if (promiseId == null) {
      print('Promise ID is null');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/promise/update-late-status'),
        headers: {
          'Content-Type': 'application/json',
          'username': username!, // username 헤더 추가
        },
        body: jsonEncode({
          'promiseId': promiseId,
          'late': late,
        }),
      );

      if (response.statusCode == 200) {
        print('Late status updated successfully');
      } else {
        print('Failed to update late status');
      }
    } catch (e) {
      print('Error updating late status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('실시간 위치', style: TextStyle(color: Colors.white)),
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
            final dateTime = '${date}T${time}:00';  // 약속 시간을 'YYYY-MM-DDTHH:MM:SS' 형식으로 변환

            message = jsonEncode({
              'type': 'appointment',
              'latitude': latitude,
              'longitude': longitude,
              'dateTime': dateTime,
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (kIsWeb) {
                _sendMessageToIframe();
              } else {
                _sendMessageToWebView();
              }
            });

            return kIsWeb
                ? HtmlElementView(viewType: 'iframeElement25')
                : WebView(
                    initialUrl: '',
                    onWebViewCreated: (WebViewController webViewController) {
                      _controllerCompleter.complete(webViewController);
                      _loadHtmlFromAssets(latitude, longitude, dateTime);
                    },
                    javascriptMode: JavascriptMode.unrestricted,
                  );
          }
        },
      ),
    );
  }

  Future<void> _loadHtmlFromAssets(double latitude, double longitude, String dateTime) async {
    String fileText = await rootBundle.loadString('assets/index3.html');
    fileText = fileText.replaceAll('{LATITUDE}', latitude.toString());
    fileText = fileText.replaceAll('{LONGITUDE}', longitude.toString());
    fileText = fileText.replaceAll('{DATETIME}', dateTime);
    final controller = await _controllerCompleter.future;
    controller.loadUrl(Uri.dataFromString(fileText, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString());
  }
}
