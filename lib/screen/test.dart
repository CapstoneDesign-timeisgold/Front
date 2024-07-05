import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert'; // for utf8 encoding
import './config.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _registerHtmlElement();
    }
  }

  void _registerHtmlElement() {
    final iframe = html.IFrameElement()
      ..width = '100%'
      ..height = '100%'
      ..src = '$baseUrl/page1.html'
      ..style.border = 'none';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('iframeElement', (int viewId) => iframe);
  }

  void _loadHtmlFromAssets() async {
    String fileText = await rootBundle.loadString('$baseUrl/page1.html');
    print('Loading HTML from assets: $fileText'); // 디버깅 로그 추가
    _controller?.loadUrl(Uri.dataFromString(fileText, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView Test', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 36, 115, 179),
      ),
      body: kIsWeb
          ? HtmlElementView(viewType: 'iframeElement')
          : WebView(
              initialUrl: 'about:blank',
              onWebViewCreated: (WebViewController webViewController) {
                _controller = webViewController;
                _controller?.clearCache();
                print('WebViewController created: $_controller'); // 디버깅 로그 추가
                _loadHtmlFromAssets();
              },
              javascriptMode: JavascriptMode.unrestricted,
            ),
    );
  }
}
