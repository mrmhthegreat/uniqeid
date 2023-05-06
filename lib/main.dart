import 'dart:async';
import 'package:advertising_id/advertising_id.dart';
import 'package:amazone/animationsplash/animationsplash.dart';
import 'package:amazone/widget/nativehelper.dart';
import 'package:amazone/widget/webviewpage.dart';
import 'package:animate_do/animate_do.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var pref = await SharedPreferences.getInstance();
  String adsid = pref.getString('adsid') ?? "";
  var id = "";

  if (adsid == "") {
    try {
      var ida = await AdvertisingId.id();
      if (ida != null) {
        id = ida;
        await pref.setString('adsid', id);
      } else {
        final deviceInfoPlugin = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        id = androidInfo.display.replaceAll(" ", "") +
            androidInfo.id.replaceAll(" ", "").replaceAll(".", "");
        await pref.setString('adsid', id);
      }
    } on PlatformException {
      final deviceInfoPlugin = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      id = androidInfo.display.replaceAll(" ", "") +
          androidInfo.id.replaceAll(" ", "").replaceAll(".", "");
      await pref.setString('adsid', id);
    }
  } else {
    id = adsid;
  }

  runApp(MyApp(
    advertisingId3: id,
  ));
}

class MyApp extends StatelessWidget {
  final String advertisingId3;

  MyApp({super.key, required this.advertisingId3});
  final navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: navigatorKey,
      title: "Bacu Pro",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(
        keys: navigatorKey,
        advertisingId3: advertisingId3,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final keys;
  final String advertisingId3;

  const MyHomePage({super.key, this.keys, required this.advertisingId3});

  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.scale(
        duration: const Duration(milliseconds: 4000),
        onEnd: () async {
          Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
              builder: (BuildContext context) => WebViewMini(
                    url:
                        "https://www.bacu.me/app/index.php?appid=$advertisingId3&pro=1",
                  )));
        },
        animationDuration: const Duration(milliseconds: 3000),
        defaultNextScreen: Container(),
        backgroundColor: HexColor('#ffffff'),
        childWidget: Bounce(
          duration: Duration(milliseconds: 3000),
          child: SizedBox(
            height: 150,
            width: 150,
            child: Image.asset(
              'assets/images/Bacu_trasparent_512.png',
              height: 150,
              width: 150,
            ),
          ),
        ));
  }
}
