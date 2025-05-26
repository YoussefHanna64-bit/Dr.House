import 'package:drhouse/components/signup_form.dart';
import 'package:drhouse/screens/login.dart';

import 'package:drhouse/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:drhouse/utils/config.dart';
import 'package:flutter/gestures.dart';

class signup extends StatefulWidget {
  const signup({Key? key}) : super(key: key);

  @override
  State<signup> createState() => _AuthState();
}

class _AuthState extends State<signup> {
  @override
  Widget build(BuildContext context) {
    //login text filed
    return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Container(
                  decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.white,
              Color.fromARGB(255, 207, 255, 209),
              Colors.white,
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  ),
                  child: Padding(
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Text(
                        AppText.enText['welcome_text']!,
                        style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                    Config.spaceSmall,
                    Text(
                      AppText.enText['Signup_text']!,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Config.spaceSmall,
                    const SignupForm(),
                    Config.spaceSmall,
                    Center(
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: AppText.enText['HaveAcc']!,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                              text: AppText.enText['justsignin']!,
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
                                        builder: (context) => const Login()),
                                  );
                                }),
                        ]),
                      ),
                    ),
                  ],
                ),
              )),
                ),
          ),
        )
        );
  }
}
