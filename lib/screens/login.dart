import 'package:drhouse/components/login_form.dart';
import 'package:drhouse/screens/signup.dart';
import 'package:drhouse/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:drhouse/utils/config.dart';
import 'package:flutter/gestures.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    //login text filed
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.white,
          Color.fromARGB(255, 207, 255, 209),
          Colors.white,
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        child: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppText.enText['welcome_text']!,
              style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w600),
            ),
            Config.spaceSmall,
            Text(
              AppText.enText['Login_text']!,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: Color.fromARGB(255, 63, 63, 63)),
            ),
            Config.spaceSmall,
            const LoginForm(),
            Config.spaceSmall,
            Center(
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: AppText.enText['NoAcc']!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                    ),
                  ),
                  TextSpan(
                      text: AppText.enText['registered_text']!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const signup()),
                          );
                        }),
                ]),
              ),
            ),
          ],
        )),
      ),
    ));
  }
}
