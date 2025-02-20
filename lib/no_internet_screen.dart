import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:masss/internet_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  InternetController internetController = Get.find();
  late InAppWebViewController _webViewController;
  int progressNum = 0;
  bool showAppbar = false;
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness:
          Brightness.dark, // Ensure icons are visible on white status bar
    ));

    // controller = WebViewController()
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..setBackgroundColor(Colors.white)
    //   ..setNavigationDelegate(
    //     NavigationDelegate(
    //       onUrlChange: (change) {
    //         print('URL-----------------> ${change.url}');
    //       },
    //       onProgress: (int progress) async {
    //         if (await controller.canGoBack()) {
    //           setState(() {
    //             showAppbar = true;
    //           });
    //         } else {
    //           setState(() {
    //             showAppbar = false;
    //           });
    //         }
    //         setState(() {
    //           progressNum = progress;
    //         });
    //       },
    //       onPageStarted: (String url) {},
    //       onPageFinished: (String url) {},
    //     ),
    //   )
    //   ..loadRequest(
    //       Uri.parse('https://www.wizardeducationalinstitute.com/login'));
  }

  Future<bool> _exitApp(BuildContext context) async {
    if (await _webViewController.canGoBack()) {
      _webViewController.goBack();

      return Future.value(false);
    } else {
      if (await _webViewController.canGoForward()) {}
    }

    return Future.value(true);
  }

  updateAppBar() {
    setState(() {
      showAppbar = bool.parse(_exitApp(context).toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    internetController.onInit();

    return Obx(() {
      if (internetController.internetStatus.toString() == "NOINTERNET") {
        return const NoInternetScreen();
      }
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (await _webViewController.canGoBack()) {
            _webViewController.goBack();

            return Future.value(false);
          } else {
            SystemNavigator.pop();
            return Future.value(true);
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri("https://www.wizardeducationalinstitute.com/login"),
              ),
              onWebViewCreated: (InAppWebViewController controller) {
                _webViewController = controller;
                internetController.setWebViewController(_webViewController);
              },
              initialSettings: InAppWebViewSettings(
                  supportZoom: false, // Disables zooming
                  builtInZoomControls: false, // Disables zoom controls
                  displayZoomControls: false,
                  mediaPlaybackRequiresUserGesture: F
                  // Hides zoom buttons (for Android)
                  ),
              // Enable JavaScript for the custom player
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  mediaPlaybackRequiresUserGesture: false, // Allow autoplay
                ),
                android: AndroidInAppWebViewOptions(
                  useWideViewPort: true,
                  domStorageEnabled: true,
                  allowContentAccess: true, // Allow cross-origin access
                  builtInZoomControls: true,
                  displayZoomControls: false,
                ),
                // ios: IOSInAppWebViewOptions(
                //   allowsAirPlayForMediaPlayback: true,
                //   allowsInlineMediaPlayback: true,
                //   disallowOverScroll: true,
                //   ignoresViewportScaleLimits: true,
                //   allowsPictureInPictureMediaPlayback: true,
                //   enableViewportScale: true,
                // ),
              ),
              onConsoleMessage: (controller, consoleMessage) {
                // Debugging console messages
                print("Console Message: ${consoleMessage.message}");
              },
              onLoadStop: (controller, url) async {
                // Handle onLoadStop event to confirm page has fully loaded
                print("Loaded: $url");
              },
            ),
          ),
        ),
      );

      //   WillPopScope(
      //     onWillPop: () {
      //       return _exitApp(context);
      //     },
      //     child: DoubleBack(
      //       onFirstBackPress: (context) {
      //         const snackBar = SnackBar(
      //             backgroundColor: Colors.black,
      //             behavior: SnackBarBehavior.floating,
      //             content: Text('Press back again to exit'));
      //         ScaffoldMessenger.of(context).showSnackBar(snackBar);
      //       },
      //       child: SafeArea(
      //         child: Scaffold(
      //           //   appBar: showAppbar == true
      //           //       ? AppBar(
      //           //           toolbarHeight: 60,
      //           //           flexibleSpace:
      //           //               NavigationControls(webViewController: controller),
      //           //           backgroundColor: Colors.white,
      //           //         )
      //           //       : null,
      //           body: WebViewWidget(controller: controller),
      //         ),
      //       ),
      //     ),
      //   );
    });
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls({super.key, required this.webViewController});

  final WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () async {
            if (await webViewController.canGoBack()) {
              await webViewController.goBack();
            } else {
              if (context.mounted) {}
            }
          },
        ),
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Wizzard LMS',
              style: TextStyle(
                  color: Colors.black,
                  //   letterSpacing: 2,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const Spacer(),
        // Row(
        //   children: [
        //     IconButton(
        //       icon: const Icon(
        //         Icons.arrow_forward_ios,
        //         color: Colors.black,
        //       ),
        //       onPressed: () async {
        //         if (await webViewController.canGoForward()) {
        //           await webViewController.goForward();
        //         } else {
        //           if (context.mounted) {}
        //         }
        //       },
        //     ),
        //     IconButton(
        //       icon: const Icon(
        //         Icons.replay,
        //         color: Colors.black,
        //       ),
        //       onPressed: () => webViewController.reload(),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 70,
                width: 70,
                child: Icon(Icons.network_check),
              ),
              Text(
                "No Internet",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
