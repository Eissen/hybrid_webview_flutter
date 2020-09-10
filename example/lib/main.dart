import 'package:flutter/material.dart';
import 'package:hybrid_webview_flutter/src/hybrid_webview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  HybridWebview webView;

  String jsResult = '';
  String jsCallback = '';

  @override
  void initState() {
    super.initState();
    webView = new HybridWebview(
        url:
            'https://calcbit.com/resource/flutter/hybrid_webview_flutter/fe-file/index.html',
        bridgeListener: this.bridgeListener);
  }

  Future<dynamic> bridgeListener(String method, dynamic content) async {
    if (method == 'exchangeHeight') {
      setState(() {
        jsResult = 'webview clientHeight: ${content[0]}';
      });
      return context.size.height;
    } else if (method == 'webViewDidStartLoad') {
      print('webViewDidStartLoad === ');
    } else if (method == 'webViewDidFinishLoad') {
      print('webViewDidFinishLoad === ');
    } else if (method == 'didFailLoadWithError') {
      print('didFailLoadWithError === $content');
    } else if (method == 'scrollViewWillBeginDragging') {
      print('scrollViewWillBeginDragging === ');
    } else if (method == 'scrollViewDidEndDragging') {
      print('scrollViewDidEndDragging === $content');
    } else if (method == 'scrollForwardTop') {
      print('scrollForwardTop === $content');
    } else if (method == 'scrollForwardBottom') {
      print('scrollForwardBottom === $content');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Container(
              color: Colors.blueGrey,
              child: Column(
                children: <Widget>[
                  Text(jsCallback),
                  RaisedButton(
                    child: Text("call js"),
                    onPressed: () async {
                      List results =
                          await webView.invokeMethod('getUserAgent', 'flutter');
                      setState(() {
                        jsCallback = results[0];
                      });
                    },
                  ),
                  Center(
                    child: Container(
                      width: 200,
                      height: 400,
                      child: webView,
                    ),
                  ),
                  Text(jsResult),
                ],
              ))),
    );
  }
}
