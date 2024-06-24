/*import 'package:flutter/foundation.dart';
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




/*import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:ui' as ui;
import './add_appointment.dart'; // Add the import for the AddAppointmentScreen
import './config.dart';

class WebPage extends StatelessWidget {
  final Widget nextRoute;

  WebPage({required this.nextRoute});

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
                  MaterialPageRoute(builder: (context) => nextRoute),
                );
              },
              tooltip: '다음',
            ),
          ],
        ),
        body: Center(
          child: HtmlElementView(viewType: 'iframeElement'),
        ),
      );
    } else {
      // 모바일 환경
      return WebViewExample(nextRoute: nextRoute);
    }
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
}

void registerIframeElement() {
  final iframe = html.IFrameElement()
    ..width = '100%'
    ..height = '100%'
    ..src = '$baseUrl/index1.html'
    ..style.border = 'none';

  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory('iframeElement', (int viewId) => iframe);
}
*/


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:ui' as ui;
import './add_appointment.dart';
import './config.dart'; // Add the import for the AddAppointmentScreen

class WebPage extends StatelessWidget {
  final Widget nextRoute;

  WebPage({required this.nextRoute});

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
                  MaterialPageRoute(builder: (context) => nextRoute),
                );
              },
              tooltip: '다음',
            ),
          ],
        ),
        body: Center(
          child: HtmlElementView(viewType: 'iframeElement'),
        ),
      );
    } else {
      // 모바일 환경
      return WebViewExample(nextRoute: nextRoute);
    }
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
    if (WebView.platform == null) {
      WebView.platform = SurfaceAndroidWebView();
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
}

void registerIframeElement() {
  final iframe = html.IFrameElement()
    ..width = '100%'
    ..height = '100%'
    ..src = '$baseUrl/index1.html'
    ..style.border = 'none';

  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory('iframeElement', (int viewId) => iframe);
}


