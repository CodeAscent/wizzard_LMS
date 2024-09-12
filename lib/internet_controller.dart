import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InternetController extends GetxController {
  static InternetController instance = Get.find();
  var internetStatus = "".obs;
  WebViewController? webViewController;
  bool reloading = false;

  @override
  void onInit() {
    super.onInit();
    _checkInternetConnectivity();
    _watchForInternet();
  }

  setWebViewController(WebViewController controller) {
    webViewController = controller;
    update();
  }

  _checkInternetConnectivity() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.toString() == "ConnectivityResult.none") {
        internetStatus("NOINTERNET");
        reloading = true;
      } else {
        internetStatus("INTERNET");
        if (reloading) {
          webViewController!.reload();
          reloading = false;
        }
      }
    } finally {}
  }

  _watchForInternet() async {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result.toString() == "ConnectivityResult.none") {
        internetStatus("NOINTERNET");
        reloading = true;
      } else {
        internetStatus("INTERNET");
        if (reloading) {
          webViewController!.reload();
          reloading = false;
        }
      }
    });
  }
}
