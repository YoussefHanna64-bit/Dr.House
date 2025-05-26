import 'package:drhouse/components/dialog.dart';
import 'package:drhouse/utils/main_layout.dart';
import 'package:drhouse/utils/config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:drhouse/utils/text.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginForm();
}

class _LoginForm extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  String _emailError = '';
  String _passwordError = '';

  bool obsecurePass = true;

  void _validateFields() {
    if (mounted) {
      setState(() {
        _emailError =
            _emailController.text.isEmpty ? 'This field cannot be empty' : '';
        _passwordError =
            _passController.text.isEmpty ? 'This field cannot be empty' : '';
      });
    }
  }

  Future<void> _login() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text, password: _passController.text);
      if (credential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          _emailError = 'No user found for that email.';
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          _passwordError = 'Wrong password provided for that user.';
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Colors.green,
            decoration: InputDecoration(
              hintText: 'Email address',
              labelText: 'Email',
              errorText: _emailError.isNotEmpty ? _emailError : null,
              prefixIcon: const Icon(Icons.email_outlined, size: 30),
              prefixIconColor: Colors.green,
              hintStyle: const TextStyle(fontSize: 20),
              labelStyle: const TextStyle(fontSize: 20),
            ),
            onChanged: (value) {
              setState(() {
                _emailError = value.isEmpty ? 'This field cannot be empty' : '';
              });
            }),
        const SizedBox(
          height: 35,
        ),
        TextFormField(
            controller: _passController,
            keyboardType: TextInputType.visiblePassword,
            cursorColor: Colors.green,
            obscureText: obsecurePass,
            decoration: InputDecoration(
              hintText: 'Password',
              labelText: 'Password',
              errorText: _passwordError.isNotEmpty ? _passwordError : null,
              prefixIcon: const Icon(Icons.lock_outlined, size: 30),
              prefixIconColor: Colors.green,
              hintStyle: const TextStyle(fontSize: 20),
              labelStyle: const TextStyle(fontSize: 20),
              suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obsecurePass = !obsecurePass;
                    });
                  },
                  icon: obsecurePass
                      ? const Icon(Icons.visibility_off_outlined,
                          color: Color.fromARGB(255, 18, 19, 18), size: 30)
                      : const Icon(Icons.visibility_outlined,
                          color: Colors.green, size: 30)),
            ),
            onChanged: (value) {
              setState(() {
                _passwordError =
                    value.isEmpty ? 'This field cannot be empty' : '';
              });
            }),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
          child: RichText(
            // textAlign: TextAlign.left,
            text: TextSpan(
                text: AppText.enText['forgot-password']!,
                style: const TextStyle(
                  fontSize: 17,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    dialogBox(context);
                  }),
          ),
        ),
        Config.spaceSmall,
        SizedBox(
          width: double.infinity,
          height: 70,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              _validateFields();
              _login();
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const MainLayout()),
              // );
            },
            child: const Text(
              "Login",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    ));
  }

  dialogBox(BuildContext context) {
    final emailController = TextEditingController();

    String? validateEmail(String email) {
      if (email.isEmpty) {
        return "This field cannot be empty";
      } else {
        return null;
      }
    }

    var baseDialog = BaseAlertDialog(
      title: "Reset Password",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: "Enter your Email",
            ),
            validator: (value) => validateEmail(value!),
          ),
        ],
      ),
      yesOnPressed: () async {
        try {
          await FirebaseAuth.instance.sendPasswordResetEmail(
            email: emailController.text,
          );
          Navigator.of(context).pop();
        } catch (error) {
          print("Password reset email failed: $error");
        }
      },
      noOnPressed: () {
        Navigator.of(context).pop();
      },
      yes: "Submit",
      no: "Cancel",
    );
    showDialog(
      context: context,
      builder: (context) => baseDialog,
    );
  }
}
