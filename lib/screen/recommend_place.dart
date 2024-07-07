import 'package:flutter/foundation.dart';  // foundation 임포트
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:ui' as ui;
import './config.dart';  // baseUrl이 정의된 파일을 임포트

class RecommendPlaceScreen extends StatefulWidget {
  final int promiseId;

  RecommendPlaceScreen({required this.promiseId});

  @override
  _RecommendPlaceScreenState createState() => _RecommendPlaceScreenState();
}

class _RecommendPlaceScreenState extends State<RecommendPlaceScreen> {
  late Completer<WebViewController> _controllerCompleter;
  String? message;
  bool iframeLoaded = false;

  @override
  void initState() {
    super.initState();
    _controllerCompleter = Completer<WebViewController>();

    _fetchAndSendAppointmentDetail();  // 초기 데이터 로드 및 전송

    if (kIsWeb) {
      _registerIframeElement(widget.promiseId);
    }
  }

  @override
  void didUpdateWidget(RecommendPlaceScreen oldWidget) {
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
    String fileText = await rootBundle.loadString('assets/index4.html');
    fileText = fileText.replaceAll('{LATITUDE}', latitude.toString());
    fileText = fileText.replaceAll('{LONGITUDE}', longitude.toString());
    final controller = await _controllerCompleter.future;
    controller.loadUrl(Uri.dataFromString(fileText, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString());
  }

  void _registerIframeElement(int promiseId) {
    final iframe = html.IFrameElement()
      ..width = '100%'
      ..height = '100%'
      ..style.border = 'none'
      ..src = 'assets/index4.html';

    iframe.onLoad.listen((event) {
      print("Iframe loaded");
      iframeLoaded = true;
      if (message != null) {
        _sendMessageToIframe();
      }
    });

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('iframeElement20${promiseId}', (int viewId) => iframe);
  }

  void _sendMessageToIframe() {
    if (!iframeLoaded) {
      print("Iframe not loaded yet, delaying message sending.");
      return;
    }
    print("Sending message to iframe: $message");
    final iframe = html.document.querySelector('iframe[src="assets/index4.html"]') as html.IFrameElement?;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주변 장소 추천', style: TextStyle(color: Colors.white)),
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
            message = jsonEncode({'latitude': latitude, 'longitude': longitude});
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _sendMessageToIframe();
            });
            return kIsWeb
                ? HtmlElementView(viewType: 'iframeElement20${widget.promiseId}')
                : WebView(
                    initialUrl: '',
                    onWebViewCreated: (WebViewController webViewController) {
                      _controllerCompleter.complete(webViewController);
                      _loadHtmlFromAssets(latitude, longitude);
                    },
                    javascriptMode: JavascriptMode.unrestricted,
                  );
          }
        },
      ),
    );
  }
}
