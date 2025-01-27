// Main server link opener

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

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

//     // Ensure status bar is visible
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..addJavaScriptChannel(
//         'flutter_inject',
//         onMessageReceived: (JavaScriptMessage message) {
//           final Map<String, dynamic> data = jsonDecode(message.message);
//           if (data.containsKey('username') && data.containsKey('password')) {
//             _saveCredentials(data['username'], data['password']);
//           }
//         },
//       )
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
//           debugPrint('Page finished loading: $url');
//           _checkForLoginFields();

//           // Check if the URL contains 'logout.php', if so, remove credentials
//           if (url.contains('logout.php')) {
//             debugPrint('Logout detected, clearing credentials');
//             _removeCredentials();
//           }
//         },
//         onWebResourceError: (WebResourceError error) {
//           setState(() {
//             _error = error.description;
//             _isLoading = false;
//           });
//           debugPrint('Error: ${error.description}');
//         },
//       ))
//       ..loadRequest(
//           Uri.parse('http://192.168.1.2/index.php?application=invoices'));
//   }

//   Future<void> _checkForLoginFields() async {
//     try {
//       final result = await _controller.runJavaScriptReturningResult('''
//         (function() {
//           var usernameField = document.querySelector("input[name='username']");
//           var passwordField = document.querySelector("input[name='password']");
//           var loginButton = document.querySelector("input[type='button'][value='login']");

//           if (usernameField && passwordField && loginButton) {
//             // Listen for form submission to save credentials
//             document.querySelector("form").addEventListener("submit", function() {
//               var username = usernameField.value;
//               var password = passwordField.value;
//               window.flutter_inject.postMessage(JSON.stringify({username: username, password: password}));
//             });
//             return true;
//           }
//           return false;
//         })();
//       ''');

//       if (result != null && (result == true || result.toString() == 'true')) {
//         debugPrint('Login fields detected, performing auto-login');
//         _autoLogin();
//       } else {
//         debugPrint('No login fields detected');
//       }
//     } catch (e) {
//       debugPrint('Error checking login fields: $e');
//     }
//   }

//   Future<void> _autoLogin() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedUsername = prefs.getString('username');
//     final savedPassword = prefs.getString('password');

//     if (savedUsername != null && savedPassword != null) {
//       debugPrint('Auto login in progress...');
//       _controller.runJavaScript('''
//         document.querySelector("input[name='username']").value = '$savedUsername';
//         document.querySelector("input[name='password']").value = '$savedPassword';
//         document.querySelector("input[type='button'][value='login']").click();
//       ''');
//     } else {
//       debugPrint('No saved credentials found.');
//     }
//   }

//   Future<void> _saveCredentials(String username, String password) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('username', username);
//     await prefs.setString('password', password);
//     debugPrint('Credentials saved successfully.');
//     _printSavedCredentials();
//   }

//   Future<void> _printSavedCredentials() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedUsername = prefs.getString('username');
//     final savedPassword = prefs.getString('password');

//     if (savedUsername != null && savedPassword != null) {
//       debugPrint('Retrieved Username: $savedUsername');
//       debugPrint('Retrieved Password: $savedPassword');
//     } else {
//       debugPrint('No credentials found in SharedPreferences');
//     }
//   }

//   Future<void> _removeCredentials() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('username');
//     await prefs.remove('password');
//     debugPrint('Credentials removed successfully.');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: kToolbarHeight),
//             child: WebViewWidget(controller: _controller),
//           ),
//           if (_isLoading)
//             const Center(
//               child: CircularProgressIndicator(),
//             ),
//           if (_error != null)
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text('Error: $_error'),
//                   ElevatedButton(
//                     onPressed: () {
//                       _controller.reload();
//                     },
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

// textile server for testing link opener

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

    // Ensure status bar is visible
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'flutter_inject',
        onMessageReceived: (JavaScriptMessage message) {
          final Map<String, dynamic> data = jsonDecode(message.message);
          if (data.containsKey('username') && data.containsKey('password')) {
            _saveCredentials(data['username'], data['password']);
          }
        },
      )
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
        },
        onPageFinished: (String url) async {
          debugPrint('Page finished loading: $url');
          _checkForLoginFields();

          // Check if the URL contains 'logout.php', if so, remove credentials
          if (url.contains('logout.php')) {
            debugPrint('Logout detected, clearing credentials');
            _removeCredentials();
          }
        },
        onWebResourceError: (WebResourceError error) {
          setState(() {
            _error = error.description;
            _isLoading = false;
          });
          debugPrint('Error: ${error.description}');
        },
      ))
      ..loadRequest(Uri.parse('http://141.144.206.40:2080/index.php'));
  }

  Future<void> _checkForLoginFields() async {
    try {
      final result = await _controller.runJavaScriptReturningResult('''
        (function() {
          var usernameField = document.querySelector("input[name='user_name_entry_field']");
          var passwordField = document.querySelector("input[name='password']");
          
          if (usernameField && passwordField) {
            // Listen for form submission to save credentials
            document.querySelector("form").addEventListener("submit", function() {
              var username = usernameField.value;
              var password = passwordField.value;
              window.flutter_inject.postMessage(JSON.stringify({username: username, password: password}));
            });
            return true;
          }
          return false;
        })();
      ''');

      if (result != null && (result == true || result.toString() == 'true')) {
        debugPrint('Login fields detected, performing auto-login');
        _autoLogin();
      } else {
        debugPrint('No login fields detected');
      }
    } catch (e) {
      debugPrint('Error checking login fields: $e');
    }
  }

  Future<void> _autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final savedPassword = prefs.getString('password');

    if (savedUsername != null && savedPassword != null) {
      debugPrint('Auto login in progress...');
      _controller.runJavaScript('''
        document.querySelector("input[name='user_name_entry_field']").value = '$savedUsername';
        document.querySelector("input[name='password']").value = '$savedPassword';
        document.querySelector("input[name='SubmitUser']").click();
      ''');
    } else {
      debugPrint('No saved credentials found.');
    }
  }

  Future<void> _saveCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
    debugPrint('Credentials saved successfully.');
    _printSavedCredentials();
  }

  Future<void> _printSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final savedPassword = prefs.getString('password');

    if (savedUsername != null && savedPassword != null) {
      debugPrint('Retrieved Username: $savedUsername');
      debugPrint('Retrieved Password: $savedPassword');
    } else {
      debugPrint('No credentials found in SharedPreferences');
    }
  }

  Future<void> _removeCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
    debugPrint('Credentials removed successfully.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight),
            child: WebViewWidget(controller: _controller),
          ),
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
    );
  }
}




// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
















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
