// ignore_for_file: file_names

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ScaleSplash extends StatefulWidget {
  ScaleSplash({super.key});

  /// Background color of flutter splash screen scaffold.

  /// ```dart
  /// backgroundColor: const Color(0xff080A12),
  /// ```
  Color? backgroundColor;

  //#region Scale

  double scale = 0;

  /// A [VoidCallback] which will be triggered after flutter splash screen [Duration].
  /// ```dart
  /// onScaleEnd: ()  {
  ///   debugPrint("Opacity Animation End");
  /// }
  /// ```
  VoidCallback? onScaleEnd;

  /// A child [Widget] which will be shown during opacity animation.
  /// ```dart
  /// scaleChildWidget : SizedBox(
  ///          height: 200,
  ///          width: 200,
  ///          child: Image.asset("assets/dart_bird.png"),
  ///       )
  /// ```
  Widget? scaleChildWidget;

  /// [Duration] to complate opacity animation.
  /// ```dart
  /// scaleAnimationDuration: const Duration(milliseconds: 2000),
  /// ```
  Duration? scaleAnimationDuration;

  /// Takes curve of animation.
  /// ```dart
  /// Curve animationCurve = Curves.ease;
  /// ```
  Curve? animationCurve = Curves.ease;

  //#endregion

  /// Sets full screen background image.
  ///
  /// Supports both Image.assets() and Image.network()
  ///
  /// ```dart
  /// backgroundImage : Image.asset("assets/splash_bg.png");
  /// ```
  /// ```dart
  /// backgroundImage : Image.network("https://www.schemecolor.com/wallpaper?i=4334&og");
  /// ```
  Image? backgroundImage;

  /// Sets full screen gradient.
  ///
  /// ```dart
  /// gradient: const LinearGradient(
  ///          begin: Alignment.topCenter,
  ///          end: Alignment.bottomCenter,
  ///          colors: [
  ///            Colors.orange,
  ///            Colors.deepOrange,
  ///          ],
  ///        ),
  /// ```
  Gradient? gradient;

  @override
  State<ScaleSplash> createState() => _ScaleSplashState();
}

class _ScaleSplashState extends State<ScaleSplash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
            ),
            child: Center(
              child: widget.scaleChildWidget,
            )));
  }
}
