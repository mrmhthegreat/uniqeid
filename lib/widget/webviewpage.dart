// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:amazone/widget/nativehelper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewMini extends StatefulWidget {
  final String url;

  const WebViewMini({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  _WebViewMiniState createState() => _WebViewMiniState();
}

class _WebViewMiniState extends State<WebViewMini> {
  InAppWebViewController? ctrl;
  late PullToRefreshController pullToRefreshController;

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final GlobalKey webViewKey = GlobalKey();
  bool error = false;
  int adattemp = 0;

  Future<bool> backbuton(BuildContext context) async {
    if (await ctrl!.canGoBack()) {
      ctrl!.goBack();

      return false;
    } else {
      var c = false;
      await showDialog(
        context: context,
        barrierDismissible: false,

        // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Close App'),
            content: SingleChildScrollView(
              child: Column(
                children: const <Widget>[
                  Text('Are you sure,You want to exit.'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Confirm'),
                onPressed: () {
                  c = true;
                  Navigator.of(context).pop();
                  exit(0);
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return c;
    }
  }

  @override
  void initState() {
    super.initState();
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          ctrl?.reload();
        }
      },
    );
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((e) async {
      if (e == ConnectivityResult.none) {
        setState(() {
          error = true;
        });
      } else {
        setState(() {
          error = false;
        });
      }
    });
  }

  int position = 1;
  doneLoading() async {}

  final snackBar = SnackBar(
    content: Row(
      children: const [
        SizedBox(height: 20, width: 20, child: CircularProgressIndicator()),
        SizedBox(
          width: 5,
        ),
        Text('Loading'),
      ],
    ),
    duration: const Duration(minutes: 2),
  );

  startLoading() {}

  @override
  void dispose() {
    _connectivitySubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: HexColor('#f8f9fa'),
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: HexColor('#f8f9fa'),
      systemNavigationBarDividerColor: HexColor('#f8f9fa'),
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return WillPopScope(
      onWillPop: () => backbuton(context),
      child: SafeArea(
        child: Scaffold(
          extendBody: false,
          body: error
              ? errorpage()
              : Column(
                  children: [
                    Expanded(
                      child: InAppWebView(
                          key: webViewKey,
                          initialUserScripts: UnmodifiableListView([]),
                          initialUrlRequest:
                              URLRequest(url: Uri.parse(widget.url)),
                          initialOptions: InAppWebViewGroupOptions(
                              crossPlatform: InAppWebViewOptions(
                                disableHorizontalScroll: false,
                                useOnDownloadStart: true,
                                supportZoom: false,
                                cacheEnabled: true,
                                javaScriptCanOpenWindowsAutomatically: true,
                                preferredContentMode:
                                    UserPreferredContentMode.MOBILE,
                                useShouldOverrideUrlLoading: true,
                                mediaPlaybackRequiresUserGesture: false,
                              ),
                              android: AndroidInAppWebViewOptions(
                                  useHybridComposition: true,
                                  textZoom: 96,
                                  supportMultipleWindows: true,
                                  mixedContentMode: AndroidMixedContentMode
                                      .MIXED_CONTENT_ALWAYS_ALLOW),
                              ios: IOSInAppWebViewOptions(
                                allowsInlineMediaPlayback: true,
                              )),
                          onWebViewCreated: (InAppWebViewController controlle) {
                            ctrl = controlle;
                          },
                          onCreateWindow: (c, b) async {
                            HeadlessInAppWebView? headlessWebView;

                            headlessWebView = HeadlessInAppWebView(
                              windowId: b.windowId,
                              initialOptions: InAppWebViewGroupOptions(
                                crossPlatform: InAppWebViewOptions(),
                              ),
                              onWebViewCreated:
                                  (InAppWebViewController controller) {},
                              onLoadStop: (a, bs) async {
                                var uri = bs;
                                var url = bs.toString();
                                if (Platform.isAndroid &&
                                    url.contains("intent")) {
                                  if (url.contains("maps")) {
                                    var mNewURL =
                                        url.replaceAll("intent://", "https://");
                                    if (await canLaunchUrl(
                                        Uri.parse(mNewURL))) {
                                      await launchUrl(Uri.parse(mNewURL));
                                      Future.delayed(
                                          const Duration(milliseconds: 500),
                                          () {
                                        Navigator.pop(context);
                                        headlessWebView?.dispose();
                                        ScaffoldMessenger.of(context)
                                            .clearSnackBars();
                                      });
                                    }
                                  } else {
                                    String id = url.substring(
                                        url.indexOf('id%3D') + 5,
                                        url.indexOf('#Intent'));
                                    await StoreRedirect.redirect(
                                        androidAppId: id);
                                  }
                                } else if (url.contains("linkedin.com") ||
                                    url.contains("market://") ||
                                    url.contains("whatsapp://") ||
                                    url.contains("truecaller://") ||
                                    url.contains("facebook.com") ||
                                    url.contains("whatsapp.com") ||
                                    url.contains("twitter.com") ||
                                    url.contains("tiktok.com") ||
                                    url.contains("www.google.com/maps") ||
                                    url.contains("pinterest.com") ||
                                    url.contains("snapchat.com") ||
                                    url.contains("instagram.com") ||
                                    url.contains("www.amazon.com") ||
                                    url.contains("play.google.com") ||
                                    url.contains("mailto:") ||
                                    url.contains("tel:") ||
                                    url.contains("google.it") ||
                                    url.contains("share=telegram") ||
                                    url.contains("messenger.com")) {
                                  try {
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url),
                                          mode: LaunchMode.externalApplication);
                                      Future.delayed(
                                          const Duration(milliseconds: 500),
                                          () {
                                        headlessWebView?.dispose();
                                        ScaffoldMessenger.of(context)
                                            .clearSnackBars();
                                      });
                                    } else {
                                      await launchUrl(Uri.parse(url),
                                          mode: LaunchMode.externalApplication);
                                      Future.delayed(
                                          const Duration(milliseconds: 500),
                                          () {
                                        headlessWebView?.dispose();
                                        ScaffoldMessenger.of(context)
                                            .clearSnackBars();
                                      });
                                    }
                                  } catch (e) {
                                    await launchUrl(Uri.parse(url),
                                        mode: LaunchMode.externalApplication);
                                    Future.delayed(
                                        const Duration(milliseconds: 500), () {
                                      headlessWebView?.dispose();
                                      ScaffoldMessenger.of(context)
                                          .clearSnackBars();
                                    });
                                  }
                                } else if (![
                                  "http",
                                  "https",
                                  "chrome",
                                  "data",
                                  "javascript",
                                  "about"
                                ].contains(uri!.scheme)) {
                                  if (await canLaunchUrl(Uri.parse(url))) {
                                    await launchUrl(Uri.parse(url),
                                        mode: LaunchMode.externalApplication);
                                  }
                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    headlessWebView?.dispose();
                                    ScaffoldMessenger.of(context)
                                        .clearSnackBars();
                                  });
                                } else if (url.contains('about:blank')) {
                                } else {
                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    ctrl?.loadUrl(
                                        urlRequest: URLRequest(url: uri));
                                    headlessWebView?.dispose();
                                    ScaffoldMessenger.of(context)
                                        .clearSnackBars();
                                  });
                                }
                              },
                              onCloseWindow: (controller) {
                                headlessWebView?.dispose();
                                ScaffoldMessenger.of(context).clearSnackBars();
                              },
                            );
                            await headlessWebView.run();

                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);

                            return true;
                          },
                          onProgressChanged: (controller, progress) async {
                            if (progress == 100) {
                              pullToRefreshController.endRefreshing();
                            }
                          },
                          onEnterFullscreen: (ctrl) {
                            SystemChrome.setPreferredOrientations([
                              DeviceOrientation.landscapeRight,
                              DeviceOrientation.landscapeLeft
                            ]);
                          },
                          onExitFullscreen: (ctrl) {
                            SystemChrome.setPreferredOrientations([
                              DeviceOrientation.portraitDown,
                              DeviceOrientation.portraitUp,
                              DeviceOrientation.landscapeRight,
                              DeviceOrientation.landscapeLeft,
                            ]);
                          },
                          shouldOverrideUrlLoading:
                              (controller, request) async {
                            var uri = request.request.url;
                            var url = request.request.url.toString();

                            if (Platform.isAndroid && url.contains("intent")) {
                              if (url.contains("maps")) {
                                var mNewURL =
                                    url.replaceAll("intent://", "https://");
                                if (await canLaunchUrl(Uri.parse(mNewURL))) {
                                  await launchUrl(Uri.parse(mNewURL));
                                  return NavigationActionPolicy.CANCEL;
                                }
                              } else {
                                String id = url.substring(
                                    url.indexOf('id%3D') + 5,
                                    url.indexOf('#Intent'));
                                await StoreRedirect.redirect(androidAppId: id);
                                return NavigationActionPolicy.CANCEL;
                              }
                            } else if (url.contains("linkedin.com") ||
                                url.contains("market://") ||
                                url.contains("whatsapp://") ||
                                url.contains("truecaller://") ||
                                url.contains("facebook.com") ||
                                url.contains("twitter.com") ||
                                url.contains("www.google.com/maps") ||
                                url.contains("pinterest.com") ||
                                url.contains("snapchat.com") ||
                                url.contains("instagram.com") ||
                                url.contains("www.amazon.com") ||
                                url.contains("play.google.com") ||
                                url.contains("mailto:") ||
                                url.contains("tel:") ||
                                url.contains("google.it") ||
                                url.contains("share=telegram") ||
                                url.contains("messenger.com")) {
                              try {
                                if (await canLaunchUrl(Uri.parse(url))) {
                                  launchUrl(Uri.parse(url),
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  launchUrl(Uri.parse(url),
                                      mode: LaunchMode.externalApplication);
                                }
                                return NavigationActionPolicy.CANCEL;
                              } catch (e) {
                                launchUrl(Uri.parse(url),
                                    mode: LaunchMode.externalApplication);
                                return NavigationActionPolicy.CANCEL;
                              }
                            } else if (![
                              "http",
                              "https",
                              "chrome",
                              "data",
                              "javascript",
                              "about"
                            ].contains(uri!.scheme)) {
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url),
                                    mode: LaunchMode.externalApplication);
                                return NavigationActionPolicy.CANCEL;
                              }
                            }

                            return NavigationActionPolicy.ALLOW;
                          },
                          onJsAlert: ((controller, jsAlertRequest) async {}),
                          pullToRefreshController: pullToRefreshController,
                          onLoadStop: (ctr, urli) {
                            doneLoading();
                            pullToRefreshController.endRefreshing();
                          },
                          onLoadError: (controller, url, code, message) {
                            pullToRefreshController.endRefreshing();
                            setState(() {
                              error = true;
                            });
                          },
                          onLoadStart: (ctr, urli) {
                            startLoading();
                            pullToRefreshController.endRefreshing();
                          }),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget errorpage() {
    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/10_Connection Lost.png'),
              fit: BoxFit.fill),
        ),
        alignment: Alignment.center,
        child: Align(
          alignment: FractionalOffset.bottomRight,
          child: Container(
            padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
            child: RawMaterialButton(
              onPressed: () async {
                final connectivityResult =
                    await Connectivity().checkConnectivity();
                if (connectivityResult != ConnectivityResult.none) {
                  setState(() {
                    error = false;

                    // I am connected to a mobile network.
                  });
                }
              },
              elevation: 2.0,
              fillColor: Colors.amberAccent,
              padding: const EdgeInsets.all(18.0),
              shape: const CircleBorder(),
              child: const Icon(
                Icons.refresh,
                color: Colors.blueGrey,
                size: 38.0,
              ),
            ),
          ),
        ));
  }
}

String _mapMimeTypeToYourExtension(String receivedMimeType) {
  if (receivedMimeType.contains("openxmlformats") ||
      receivedMimeType.contains("spreadsheetml")) {
    return "xlsx";
  } else if (receivedMimeType.contains("csv")) {
    return "csv";
  } else if (receivedMimeType.contains("pdf")) {
    return "pdf";
  }
  return "pdf";
}

Future load(BuildContext context) async {
  // showDialog(
  //     context: context,
  //     builder: (BuildContext context) => AlertDialog(
  //           content: SizedBox(
  //             height: 50,
  //             width: MediaQuery.of(context).size.width * 0.90,
  //             child: Row(
  //               children: [
  //                 const CircularProgressIndicator(),
  //                 const SizedBox(
  //                   width: 20,
  //                 ),
  //                 const Text("Loading")
  //               ],
  //             ),
  //           ),
  //         ));
  // Future.delayed(const Duration(seconds: 3), () => Navigator.of(context).pop());
}
