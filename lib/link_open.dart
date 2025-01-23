import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

class link_opener_helper extends StatefulWidget {
  const link_opener_helper({super.key});

  @override
  State<link_opener_helper> createState() => _link_opener_helperState();
}

class _link_opener_helperState extends State<link_opener_helper> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    // Set full-screen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          setState(() {
            _isLoading = progress < 100;
          });
          debugPrint('WebView loading: $progress%');
        },
        onPageStarted: (String url) {
          setState(() {
            _error = null;
          });
          debugPrint('Page started loading: $url');

          // Detect logout URL and clear credentials
          if (url.contains('access/logout.php')) {
            _clearCredentials();
          }
        },
        onPageFinished: (String url) {
          setState(() {
            _isLoading = false;
          });
          debugPrint('Page finished loading: $url');

          // Trigger auto-login when page finishes loading
          _autoLogin();
        },
        onWebResourceError: (WebResourceError error) {
          setState(() {
            _error = error.description;
            _isLoading = false;
          });
          debugPrint('Error: ${error.description}');
        },
      ))
      ..loadRequest(Uri.parse('http://141.144.206.40:2080/'));
  }

  Future<void> _autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final savedPassword = prefs.getString('password');

    if (savedUsername != null && savedPassword != null) {
      debugPrint('Attempting auto-login with username: $savedUsername');

      // Inject credentials into the login form and submit
      await _controller.runJavaScript('''
        setTimeout(function() {
          var usernameField = document.querySelector("input[name='user_name_entry_field']");
          var passwordField = document.querySelector("input[name='password']");
          var submitButton = document.querySelector("input[name='SubmitUser']");

          if (usernameField && passwordField && submitButton) {
            usernameField.value = '$savedUsername';
            passwordField.value = '$savedPassword';
            submitButton.click();
            console.log('Auto-login successful');
          } else {
            console.error('Login elements not found');
          }
        }, 2000);  // Delay to ensure elements are available
      ''');
    } else {
      debugPrint('No saved credentials found');
    }
  }

  Future<void> _saveCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
    debugPrint('Credentials saved: $username');
  }

  Future<void> _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
    debugPrint('Credentials cleared on logout');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Using SafeArea to avoid system UI like status bar
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (_error != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $_error'),
                    ElevatedButton(
                      onPressed: () {
                        _controller.reload();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

















// scaled down the screen size to fit the webview

// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class link_opener_helper extends StatefulWidget {
//   const link_opener_helper({super.key});

//   @override
//   State<link_opener_helper> createState() => _link_opener_helperState();
// }

// class _link_opener_helperState extends State<link_opener_helper> {
//   late final WebViewController _controller;
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0x00000000))
//       ..setNavigationDelegate(NavigationDelegate(
//         onProgress: (int progress) {
//           setState(() {
//             _isLoading = progress < 100;
//           });
//           debugPrint('WebView loading: $progress%');
//         },
//         onPageStarted: (String url) {
//           setState(() {
//             _error = null;
//           });
//           debugPrint('Page started loading: $url');
//         },
//         onPageFinished: (String url) async {
//           setState(() {
//             _isLoading = false;
//           });

//           // Inject viewport settings and force scaling adjustments
//           await _controller.runJavaScript('''
//             (function() {
//               var meta = document.querySelector('meta[name="viewport"]');
//               if (!meta) {
//                 meta = document.createElement('meta');
//                 meta.name = 'viewport';
//                 document.getElementsByTagName('head')[0].appendChild(meta);
//               }
//               meta.content = 'width=device-width, initial-scale=0.8, viewport-fit=cover, user-scalable=no';

//               // Force fit content to screen width
//               document.body.style.width = '100vw';
//               document.body.style.height = '100vh';
//               document.body.style.overflow = 'hidden';
//               document.documentElement.style.width = '100vw';
//               document.documentElement.style.height = '100vh';

//               // Force zoom to fit content
//               document.body.style.transformOrigin = '0 0';
//               document.body.style.transform = 'scale(1.0)';
//               document.body.style.margin = '0';
//               document.body.style.padding = '0';
//             })();
//           ''');

//           debugPrint('Viewport settings injected');
//         },
//         onWebResourceError: (WebResourceError error) {
//           setState(() {
//             _error = error.description;
//             _isLoading = false;
//           });
//           debugPrint('Error: ${error.description}');
//         },
//       ))
//       ..loadRequest(Uri.parse('http://141.144.206.40:2080/'));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         // Ensures content is below status bar
//         child: Stack(
//           children: [
//             WebViewWidget(controller: _controller),
//             if (_isLoading)
//               const Center(
//                 child: CircularProgressIndicator(),
//               ),
//             if (_error != null)
//               Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text('Error: $_error'),
//                     ElevatedButton(
//                       onPressed: () {
//                         _controller.reload();
//                       },
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
