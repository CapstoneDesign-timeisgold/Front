
//플러터에서 실행할때 쓰는 코드(index1.html플러터로 옮긴후)-original
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert'; // for utf8 encoding
import 'package:flutter/services.dart' show rootBundle;
import './add_appointment.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:ui' as ui;
import 'package:http/http.dart' as http; // for HTTP requests
import 'package:shared_preferences/shared_preferences.dart'; // for shared preferences
import './config.dart';


class WebPage extends StatefulWidget {
  final Widget nextRoute;

  WebPage({required this.nextRoute});

  @override
  _WebPageState createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  String latitude = '';
  String longitude = '';

  void updateCoordinates(String lat, String lng) {
    setState(() {
      latitude = lat;
      longitude = lng;
    });
    print("Updated coordinates: Latitude: $latitude, Longitude: $longitude"); // 디버깅 메시지 추가
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      registerIframeElement();
      html.window.addEventListener('message', (event) {
        if (event is html.MessageEvent) {
          final message = event.data;
          if (message != null && message is String && message.contains(',')) {
            final coordinates = message.split(',');
            updateCoordinates(coordinates[0], coordinates[1]);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // 웹 환경
      return Scaffold(
        appBar: AppBar(
          title: Text('Google WebView Example'),
          actions: [
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => widget.nextRoute,
                    settings: RouteSettings(
                      arguments: {'latitude': latitude, 'longitude': longitude},
                    ),
                  ),
                );
              },
              tooltip: '다음',
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: HtmlElementView(viewType: 'iframeElement'),
            ),
            Divider(), // 구분선 추가
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('Latitude: $latitude'),
                  Text('Longitude: $longitude'),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // 모바일 환경
      return WebViewExample(nextRoute: widget.nextRoute, updateCoordinates: updateCoordinates);
    }
  }
}

class WebViewExample extends StatefulWidget {
  final Widget nextRoute;
  final Function(String, String) updateCoordinates;

  WebViewExample({required this.nextRoute, required this.updateCoordinates});

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late WebViewController _controller;
  String latitude = '';
  String longitude = '';

  @override
  void initState() {
    super.initState();
    // Android WebView 초기화
    if (WebView.platform == null) {
      WebView.platform = SurfaceAndroidWebView();
    }
    _loadHtmlFromAssets();
  }

  _loadHtmlFromAssets() async {
    String fileText = await rootBundle.loadString('lib/screen/index1.html');
    _controller.loadUrl(Uri.dataFromString(fileText, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString());
  }

  void _onMessageReceived(JavascriptMessage message) {
    print("Received message: ${message.message}"); // 디버깅 메시지 추가
    List<String> coordinates = message.message.split(',');
    setState(() {
      latitude = coordinates[0];
      longitude = coordinates[1];
    });
    print("Parsed coordinates: Latitude: $latitude, Longitude: $longitude"); // 디버깅 메시지 추가
    widget.updateCoordinates(latitude, longitude);
    _sendLocationToServer(latitude, longitude);
  }

  Future<void> _sendLocationToServer(String lat, String lng) async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username == null) {
      print('Username not found in SharedPreferences');
      return;
    }

    final url = Uri.parse('$baseUrl/location');
    final headers = {
      'Content-Type': 'application/json',
      'username': username,
    };
    final body = jsonEncode({
      'latitude': lat,
      'longitude': lng,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Location sent successfully');
      } else {
        print('Failed to send location. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google WebView Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => widget.nextRoute,
                  settings: RouteSettings(
                    arguments: {'latitude': latitude, 'longitude': longitude},
                  ),
                ),
              );
            },
            tooltip: '다음',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: WebView(
              initialUrl: '',
              onWebViewCreated: (WebViewController webViewController) {
                _controller = webViewController;
              },
              javascriptMode: JavascriptMode.unrestricted,
              javascriptChannels: <JavascriptChannel>{
                JavascriptChannel(
                  name: 'CoordinatesChannel',
                  onMessageReceived: (JavascriptMessage message) {
                    _onMessageReceived(message);
                  },
                ),
              },
            ),
          ),
          Divider(), // 구분선 추가
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('Latitude: $latitude'),
                Text('Longitude: $longitude'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void registerIframeElement() {
  final iframe = html.IFrameElement()
    ..width = '100%'
    ..height = '100%'
    ..src = 'lib/screen/index1.html'
    ..style.border = 'none';
  

  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory('iframeElement', (int viewId) => iframe);
}







/* //apk 만들때?
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import './add_appointment.dart'; // Add the import for the AddAppointmentScreen
import './config.dart';

class WebPage extends StatelessWidget {
  final Widget nextRoute;

  WebPage({required this.nextRoute});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google WebView Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => nextRoute),
              );
            },
            tooltip: '다음',
          ),
        ],
      ),
      body: WebViewExample(nextRoute: nextRoute),
    );
  }
}


class WebViewExample extends StatefulWidget {
  final Widget nextRoute;

  WebViewExample({required this.nextRoute});

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  @override
  void initState() {
    super.initState();
    // Android WebView 초기화
    if (!kIsWeb && WebView.platform == null) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }
    /*if (WebView.platform == null) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google WebView Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => widget.nextRoute),
              );
            },
            tooltip: '다음',
          ),
        ],
      ),
      body: WebView(
        initialUrl: '$baseUrl/index1.html',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}*/






