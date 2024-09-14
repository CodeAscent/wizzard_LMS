import 'package:flutter/material.dart';

import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:masss/internet_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  InternetController internetController = Get.find();
  late final WebViewController controller;
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

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (change) {
            print('URL-----------------> ${change.url}');
          },
          onProgress: (int progress) async {
            if (await controller.canGoBack()) {
              setState(() {
                showAppbar = true;
              });
            } else {
              setState(() {
                showAppbar = false;
              });
            }
            setState(() {
              progressNum = progress;
            });
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
        ),
      )
      ..loadRequest(
          Uri.parse('https://www.wizardeducationalinstitute.com/login'));
    internetController.setWebViewController(controller);
  }

  Future<bool> _exitApp(BuildContext context) async {
    if (await controller.canGoBack()) {
      controller.goBack();

      return Future.value(false);
    } else {
      if (await controller.canGoForward()) {}
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
      return WillPopScope(
        onWillPop: () {
          return _exitApp(context);
        },
        child: DoubleBack(
          onFirstBackPress: (context) {
            const snackBar = SnackBar(
                backgroundColor: Colors.black,
                behavior: SnackBarBehavior.floating,
                content: Text('Press back again to exit'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          child: SafeArea(
            child: Scaffold(
              //   appBar: showAppbar == true
              //       ? AppBar(
              //           toolbarHeight: 60,
              //           flexibleSpace:
              //               NavigationControls(webViewController: controller),
              //           backgroundColor: Colors.white,
              //         )
              //       : null,
              body: WebViewWidget(controller: controller),
            ),
          ),
        ),
      );
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
