import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Earthwormrise extends StatefulWidget {
  const Earthwormrise({Key? key}) : super(key: key);

  @override
  _EarthwormriseState createState() => _EarthwormriseState();
}

class _EarthwormriseState extends State<Earthwormrise> {
  final String targetUrl = 'https://beamish-dango-8bf8dc.netlify.app/dashboard';

  // Method to launch URL within the app
  Future<void> _launchInAppWebView() async {
    final Uri url = Uri.parse(targetUrl);
    if (!await launchUrl(
      url, 
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(
        enableJavaScript: true,
        enableDomStorage: true,
      ),
    )) {
      _showErrorSnackBar('Could not launch $url');
    }
  }

  // Method to launch URL in external browser
  Future<void> _launchExternalBrowser() async {
    final Uri url = Uri.parse(targetUrl);
    if (!await launchUrl(
      url, 
      mode: LaunchMode.externalApplication,
    )) {
      _showErrorSnackBar('Could not launch $url');
    }
  }

  // Helper method to show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web View Options'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _launchInAppWebView,
              child: const Text('Open in App WebView'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _launchExternalBrowser,
              child: const Text('Open in External Browser'),
            ),
          ],
        ),
      ),
    );
  }
}