import 'package:chatapp/pages/home.dart';
import 'package:chatapp/pages/signin.dart';
import 'package:chatapp/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'settings/settings_controller.dart';

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
    required this.settingsController,
  }) : super(key: key);

  final SettingsController settingsController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  double _overlap = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final renderObject = context.findRenderObject();
    final renderBox = renderObject as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final widgetRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      renderBox.size.width,
      renderBox.size.height,
    );
    final keyboardTopPixels =
        window.physicalSize.height - window.viewInsets.bottom;
    final keyboardTopPoints = keyboardTopPixels / window.devicePixelRatio;
    final overlap = widgetRect.bottom - keyboardTopPoints;
    if (overlap >= 0) {
      setState(() {
        _overlap = overlap;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final authState = ref.watch(authStateProvider);

            return authState.when(
              data: (authState) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                    brightness: Brightness.dark,
                    fontFamily: 'Roboto',
                  ),
                  home: authState != null
                      ? HomePage()
                      : Padding(
                          padding: EdgeInsets.only(bottom: _overlap),
                          child: const SigninPage(),
                        ),
                );
              },
              error: (e, s) => MaterialApp(
                home: Text('$e, $s'),
              ),
              loading: () => const MaterialApp(
                home: CircularProgressIndicator(),
              ),
            );
          },
        );
      },
    );
  }
}
