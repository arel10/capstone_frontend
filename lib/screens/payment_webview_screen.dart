import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum PaymentStatus { success, pending, failed, userClosed }

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  const PaymentWebViewScreen({super.key, required this.paymentUrl});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  var loadingPercentage = 0;

  final String finishUrl = 'https://example.com/finish';
  final String unfinishUrl = 'https://example.com/unfinish';
  final String errorUrl = 'https://example.com/error';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => loadingPercentage = 0);
            if (url.startsWith(finishUrl)) {
              Navigator.of(context).pop(PaymentStatus.success);
            } else if (url.startsWith(unfinishUrl)) {
              Navigator.of(context).pop(PaymentStatus.pending);
            } else if (url.startsWith(errorUrl)) {
              Navigator.of(context).pop(PaymentStatus.failed);
            }
          },
          onProgress: (int progress) =>
              setState(() => loadingPercentage = progress),
          onPageFinished: (String url) =>
              setState(() => loadingPercentage = 100),
          onWebResourceError: (WebResourceError error) {
            debugPrint(
              'Page resource error: code: ${error.errorCode}, description: ${error.description}',
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(PaymentStatus.userClosed);
        return false;
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        appBar: AppBar(
          backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          title: Text(
            'Complete Payment',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () =>
                Navigator.of(context).pop(PaymentStatus.userClosed),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (loadingPercentage < 100)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: loadingPercentage / 100.0,
                  backgroundColor: isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[300],
                  color: Colors.blueAccent,
                  minHeight: 3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
