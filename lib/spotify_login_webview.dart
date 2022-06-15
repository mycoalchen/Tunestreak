import 'package:flutter/material.dart';
import 'package:tunestreak/config.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ResponseUriWrapper {
  var value;
  ResponseUriWrapper(this.value);
}

class WebViewContainer extends StatefulWidget {
  final url;
  ResponseUriWrapper responseUri;

  WebViewContainer(this.url, this.responseUri);

  @override
  State<WebViewContainer> createState() => _WebViewContainerState(url, responseUri);
}

class _WebViewContainerState extends State<WebViewContainer> {
  var _url;
  var _responseUri;
  final _key = UniqueKey();

  _WebViewContainerState(this._url, this._responseUri);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: WebView(
              key: _key,
              javascriptMode: JavascriptMode.unrestricted,
              initialUrl: _url,
              navigationDelegate: (navReq) {
                print("navreq.url = " + navReq.url);
                if (navReq.url.startsWith(spotifyRedirectUri)) {
                  _responseUri.value = navReq.url;
                  print("preventing");
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            )
          ),
        ],
      )
    );
  }
}