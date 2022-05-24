import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutterfire_ui/auth.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({Key? key}) : super(key: key);

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  @override
  Widget build(BuildContext context) {
    var clientId = dotenv.env["clientId"].toString();
    return SignInScreen(
      showAuthActionSwitch: false,
      subtitleBuilder: (context, action) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            action == AuthAction.signIn
                ? 'Welcome to Chatapp! Please sign in with Google to continue.'
                : 'Welcome to FlutterFire UI! Please create an account to continue',
          ),
        );
      },
      footerBuilder: (context, _) {
        return const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'Chatapp is brought to you, by Pablo Cardoso.',
            style: TextStyle(color: Colors.grey),
          ),
        );
      },
      headerMaxExtent: 300,
      headerBuilder: (context, BoxConstraints constraints, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 40, 0, 30),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.asset('assets/images/pc_300.png'),
          ),
        );
      },
      providerConfigs: [
        // const EmailProviderConfiguration(),
        GoogleProviderConfiguration(
          // get client Id from Google/Firebase
          clientId: clientId,
        ),
      ],
    );
  }
}
