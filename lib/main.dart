import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot_env;

int? isviewed;
String? chatRoom;
void main() async {
  await dot_env.dotenv.load(fileName: "dotenv");
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();
  WidgetsFlutterBinding.ensureInitialized();
  String apiKey = dot_env.dotenv.env["apiKey"].toString();
  String authDomain = dot_env.dotenv.env["authDomain"].toString();
  String projectId = dot_env.dotenv.env["projectId"].toString();
  String storageBucket = dot_env.dotenv.env["storageBucket"].toString();
  String messagingSenderId = dot_env.dotenv.env["messagingSenderId"].toString();
  String appId = dot_env.dotenv.env["appId"].toString();
  String measurementId = dot_env.dotenv.env["measurementId"].toString();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: apiKey,
        authDomain: authDomain,
        projectId: projectId,
        storageBucket: storageBucket,
        messagingSenderId: messagingSenderId,
        appId: appId,
        measurementId: measurementId,
      ),
    ).then((value) => runApp(ProviderScope(
            child: Center(
          child: SizedBox(
              width: 500,
              height: 1000,
              child: MyApp(settingsController: settingsController)),
        ))));
  } else {
    await Firebase.initializeApp().then((value) => runApp(ProviderScope(
          child: MyApp(settingsController: settingsController),
        )));
  }
}
