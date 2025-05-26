import 'package:drhouse/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:drhouse/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupForm();
}

class _SignupForm extends State<SignupForm> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _firstname = TextEditingController();
  final _lastname = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _number = TextEditingController();
  final _address = TextEditingController();

  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';
  String _firstnameError = '';
  String _lastnameError = '';
  String _phoneNumberError = '';
  String _addressError = '';
  bool isValid = false;

  bool _validatePhoneNumber(String phoneNumber) {
    RegExp regex = RegExp(r'^01[0125]\d{8}$');
    return regex.hasMatch(phoneNumber);
  }

  bool _isValidEmail(String email) {
    // Validate email format using regex
    RegExp regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  void _validateFields() {
    setState(() {
      _firstnameError =
          _firstname.text.isEmpty ? 'This field cannot be empty' : '';
      _lastnameError =
          _lastname.text.isEmpty ? 'This field cannot be empty' : '';
      _addressError = _address.text.isEmpty ? 'This field cannot be empty' : '';
      _phoneNumberError =
          _number.text.isEmpty ? 'This field cannot be empty' : '';
      _emailError =
          _emailController.text.isEmpty ? 'This field cannot be empty' : '';
      _passwordError =
          _passController.text.isEmpty ? 'This field cannot be empty' : '';

      // Validate phone number format using regex
      if (_number.text.isNotEmpty && !_validatePhoneNumber(_number.text)) {
        _phoneNumberError = 'Invalid phone number';
      }

      // Validate password strength
      if (_passController.text.isNotEmpty && _passController.text.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      }

      // Validate email format
      if (_emailController.text.isNotEmpty &&
          !_isValidEmail(_emailController.text)) {
        _emailError = 'Invalid email format';
      }

      // Validate confirm password
      if (_confirmPasswordController.text.isNotEmpty &&
          _confirmPasswordController.text != _passController.text) {
        _confirmPasswordError = "Passwords don't match";
      } else {
        _confirmPasswordError = '';
      }
    });
  }

  Future<void> _registerUser() async {
    // Validate form fields before proceeding with registration
    _validateFields();

    // Check if there are any validation errors
    if (_firstnameError.isNotEmpty ||
        _lastnameError.isNotEmpty ||
        _addressError.isNotEmpty ||
        _phoneNumberError.isNotEmpty ||
        _emailError.isNotEmpty ||
        _passwordError.isNotEmpty ||
        _confirmPasswordError.isNotEmpty) {
      // Display error message to the user

      return; // Stop registration process if there are errors
    }

    try {
      if (_passController.text != _confirmPasswordController.text) {
        setState(() {
          _confirmPasswordError = "Passwords don't match";
        });
        return;
      } else {
        setState(() {
          _confirmPasswordError = '';
        });
      }

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passController.text,
      );

      // Check if user was successfully created
      if (userCredential.user != null) {
        // Save user details to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'firstName': _firstname.text,
          'lastName': _lastname.text,
          'address': _address.text,
          'phoneNumber': _number.text,
        });
        // Navigate to login page only if registration was successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          _passwordError = 'The password provided is too weak.';
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          _emailError = 'The account already exists for that email.';
        });
      }
    } catch (e) {
      setState(() {});
    }
  }

  bool obsecurePass = true;
  bool confobsecurePass = true;
  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(
      children: <Widget>[
        TextFormField(
            controller: _firstname,
            keyboardType: TextInputType.name,
            cursorColor: Colors.green,
            decoration: InputDecoration(
              hintText: 'First name',
              labelText: 'First name',
              errorText: _firstnameError.isNotEmpty ? _firstnameError : null,
              prefixIcon: const Icon(Icons.person, size: 30),
              prefixIconColor: Colors.green,
              hintStyle: const TextStyle(fontSize: 20),
              labelStyle: const TextStyle(fontSize: 20),
            ),
            onChanged: (value) {
              setState(() {
                _firstnameError =
                    value.isEmpty ? 'This field cannot be empty' : '';
              });
            }),
        Config.spaceSmall,
        TextFormField(
            controller: _lastname,
            keyboardType: TextInputType.name,
            cursorColor: Colors.green,
            decoration: InputDecoration(
              hintText: 'Last name',
              labelText: 'Last name',
              errorText: _lastnameError.isNotEmpty ? _lastnameError : null,
              prefixIcon: const Icon(Icons.person, size: 30),
              prefixIconColor: Colors.green,
              hintStyle: const TextStyle(fontSize: 20),
              labelStyle: const TextStyle(fontSize: 20),
            ),
            onChanged: (value) {
              setState(() {
                _lastnameError =
                    value.isEmpty ? 'This field cannot be empty' : '';
              });
            }),
        Config.spaceSmall,
        TextFormField(
            controller: _address,
            keyboardType: TextInputType.streetAddress,
            cursorColor: Colors.green,
            decoration: InputDecoration(
              hintText: 'Address',
              labelText: 'Address',
              errorText: _addressError.isNotEmpty ? _addressError : null,
              prefixIcon: const Icon(Icons.location_pin, size: 30),
              prefixIconColor: Colors.green,
              hintStyle: const TextStyle(fontSize: 20),
              labelStyle: const TextStyle(fontSize: 20),
            ),
            onChanged: (value) {
              setState(() {
                _addressError =
                    value.isEmpty ? 'This field cannot be empty' : '';
              });
            }),
        Config.spaceSmall,
        TextFormField(
            controller: _number,
            keyboardType: TextInputType.phone,
            cursorColor: Colors.green,
            decoration: InputDecoration(
              hintText: 'Phone Number',
              labelText: 'Phone Number',
              errorText:
                  _phoneNumberError.isNotEmpty ? _phoneNumberError : null,
              prefixIcon: const Icon(Icons.phone, size: 30),
              prefixIconColor: Colors.green,
              hintStyle: const TextStyle(fontSize: 20),
              labelStyle: const TextStyle(fontSize: 20),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(
                  11), // Limit to 10 characters (excluding formatting)
            ],
            onChanged: (value) {
              if (!_validatePhoneNumber(_number.text)) {
                setState(() {
                  _phoneNumberError = "Not a valid phone number";
                });
                return;
              } else {
                setState(() {
                  _phoneNumberError = '';
                });
              }
              setState(() {
                _phoneNumberError =
                    value.isEmpty ? 'This field cannot be empty' : '';
              });
            }),
        Config.spaceSmall,
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
        Config.spaceSmall,
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
        Config.spaceSmall,
        TextFormField(
            controller: _confirmPasswordController,
            keyboardType: TextInputType.visiblePassword,
            cursorColor: Colors.green,
            obscureText: confobsecurePass,
            decoration: InputDecoration(
              hintText: ' Confirm Password',
              labelText: 'Confirm Password',
              errorText: _confirmPasswordError.isNotEmpty
                  ? _confirmPasswordError
                  : null,
              prefixIcon: const Icon(Icons.lock_outlined, size: 30),
              prefixIconColor: Colors.green,
              hintStyle: const TextStyle(fontSize: 20),
              labelStyle: const TextStyle(fontSize: 20),
              suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      confobsecurePass = !confobsecurePass;
                    });
                  },
                  icon: confobsecurePass
                      ? const Icon(Icons.visibility_off_outlined,
                          color: Color.fromARGB(255, 18, 19, 18), size: 30)
                      : const Icon(Icons.visibility_outlined,
                          color: Colors.green, size: 30)),
            ),
            onChanged: (value) {
              setState(() {
                _confirmPasswordError =
                    value.isEmpty ? 'This field cannot be empty' : '';
              });
            }),
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
              _registerUser();
            },
            child: const Text(
              "Sign up",
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    ));
  }
}
