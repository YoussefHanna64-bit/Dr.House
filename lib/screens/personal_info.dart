import 'package:drhouse/components/dialog.dart';
import 'package:drhouse/utils/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import "package:drhouse/utils/firestore_util.dart";

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  DateTime? _birthdate;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> _updateUserGender(String newGender) async {
    try {
      User user = FirebaseAuth.instance.currentUser!;
      String userId = user.uid; // Replace this with your actual user ID
      await usersCollection.doc(userId).update({'gender': newGender});
    } catch (e) {
      print('Error updating user gender: $e');
    }
  }

  Future<void> _loadBirthdate() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String userId = user!.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Timestamp? birthdateTimestamp = userDoc['birthDate'];
        if (birthdateTimestamp != null) {
          setState(() {
            _birthdate = birthdateTimestamp.toDate();
          });
        }
      }
    } catch (e) {
      print('Error loading birthdate: $e');
    }
  }

  Future<void> _updateBirthdate(DateTime newBirthdate) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String userId = user!.uid;

      Timestamp newBirthdateTimestamp = Timestamp.fromDate(newBirthdate);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'birthDate': newBirthdateTimestamp});
    } catch (e) {
      print('Error updating birthdate: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _birthdate = pickedDate;
        _updateBirthdate(pickedDate);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBirthdate();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
        body: SingleChildScrollView(
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Align(
                      alignment: Alignment(-0.86, -0.3),
                      child: FaIcon(
                        FontAwesomeIcons.arrowLeft,
                        color: Color.fromARGB(255, 95, 233, 54),
                        size: 35,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 13,
                    height: 16,
                  ),
                  const Text(
                    'Profile',
                    style: TextStyle(fontSize: 36),
                  ),
                ],
              ),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 95.0,
          child: FaIcon(
            FontAwesomeIcons.user,
            size: 95,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Full Name",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w100),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder(
                              future:
                                  getUserData(), // Fetch user data from Firestore
                              builder: (BuildContext context,
                                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                                // is an instance of the data in the firesote
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator(); // Show loading indicator while data is loading
                                }

                                if (snapshot.hasError) {
                                  return Text(
                                      'Error: ${snapshot.error}'); // Show error message if any
                                }

                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return const Text(
                                      'No user data found!'); // Show message if no user data is found
                                }

                                // User data exists, extract and display the user's name
                                var userData = snapshot.data!.data()
                                    as Map<String, dynamic>;
                                String userFName = userData['firstName'];
                                String userLName = userData['lastName'];
                                String fullName = '$userFName $userLName';

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: TextFormField(
                                            initialValue: fullName,
                                            onChanged: (newValue) {
                                              userFName =
                                                  newValue.split(' ')[0];
                                              userLName = newValue.split(' ')[
                                                  1]; // Update the user's first name as they type
                                            },
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(snapshot.data!.id)
                                                .update(
                                                    {'firstName': userFName});
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(snapshot.data!.id)
                                                .update(
                                                    {'lastName': userLName});
                                          },
                                          child: const FaIcon(
                                            FontAwesomeIcons.penToSquare,
                                            color: Colors.grey,
                                            size: 30,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Other widgets here...
                                  ],
                                );
                              }),
                        ],
                      ),
                    ],
                  ),
                  const Divider(thickness: 1),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "address",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w100),
                      ),
                      FutureBuilder(
                          future:
                              getUserData(), // Fetch user data from Firestore
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            // is an instance of the data in the firesote
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(); // Show loading indicator while data is loading
                            }

                            if (snapshot.hasError) {
                              return Text(
                                  'Error: ${snapshot.error}'); // Show error message if any
                            }

                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return const Text(
                                  'No user data found!'); // Show message if no user data is found
                            }

                            // User data exists, extract and display the user's name
                            var userData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            String address = userData['address'];

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: address,
                                        onChanged: (newValue) {
                                          address =
                                              newValue; // Update the user's first name as they type
                                        },
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(snapshot.data!.id)
                                            .update({'address': address});
                                      },
                                      child: const FaIcon(
                                        FontAwesomeIcons.penToSquare,
                                        color: Colors.grey,
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                ),
                                // Other widgets here...
                              ],
                            );
                          })
                    ],
                  ),
                  const Divider(thickness: 1),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Birthday',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w100),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _birthdate != null
                                  ? '${_birthdate!.day}/${_birthdate!.month}/${_birthdate!.year}'
                                  : 'Select Birthday',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: () async {
                                _selectDate(context);
                              },
                              child: const FaIcon(
                                FontAwesomeIcons.penToSquare,
                                color: Colors.grey,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ]),
                  const Divider(thickness: 1),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Phone Number",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w100),
                      ),
                      FutureBuilder(
                          future:
                              getUserData(), // Fetch user data from Firestore
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            // is an instance of the data in the firesote
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(); // Show loading indicator while data is loading
                            }

                            if (snapshot.hasError) {
                              return Text(
                                  'Error: ${snapshot.error}'); // Show error message if any
                            }

                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return const Text(
                                  'No user data found!'); // Show message if no user data is found
                            }

                            // User data exists, extract and display the user's name
                            var userData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            String phoneNumber = userData['phoneNumber'];

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: phoneNumber,
                                        onChanged: (newValue) {
                                          phoneNumber =
                                              newValue; // Update the user's first name as they type
                                        },
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(snapshot.data!.id)
                                            .update(
                                                {'phoneNumber': phoneNumber});
                                      },
                                      child: const FaIcon(
                                        FontAwesomeIcons.penToSquare,
                                        color: Colors.grey,
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                ),
                                // Other widgets here...
                              ],
                            );
                          })
                    ],
                  ),
                  const Divider(thickness: 1),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Email",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w100),
                      ),
                      FutureBuilder(
                          future:
                              getUserData(), // Fetch user data from Firestore
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            // is an instance of the data in the firesote
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(); // Show loading indicator while data is loading
                            }

                            if (snapshot.hasError) {
                              return Text(
                                  'Error: ${snapshot.error}'); // Show error message if any
                            }

                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return const Text(
                                  'No user data found!'); // Show message if no user data is found
                            }

                            // User data exists, extract and display the user's name
                            String? email = user?.email;

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: email,
                                        onChanged: (newValue) {
                                          email =
                                              newValue; // Update the user's first name as they type
                                        },
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        await user
                                            ?.verifyBeforeUpdateEmail(email!);
                                      },
                                      child: const FaIcon(
                                        FontAwesomeIcons.penToSquare,
                                        color: Colors.grey,
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                ),
                                // Other widgets here...
                              ],
                            );
                          })
                    ],
                  ),
                  const Divider(thickness: 1),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Gender",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w100),
                      ),
                      FutureBuilder(
                          future:
                              getUserData(), // Fetch user data from Firestore
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            // is an instance of the data in the firesote
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(); // Show loading indicator while data is loading
                            }

                            if (snapshot.hasError) {
                              return Text(
                                  'Error: ${snapshot.error}'); // Show error message if any
                            }

                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return const Text(
                                  'No user data found!'); // Show message if no user data is found
                            }

                            // User data exists, extract and display the user's name
                            var userData =
                                snapshot.data!.data() as Map<String, dynamic>;

                            String gender = userData['gender'];

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SizedBox(height: 8),
                                DropdownButton<String>(
                                  value: gender,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      gender = newValue!;
                                      _updateUserGender(
                                          newValue); // Update Firestore on change
                                    });
                                  },
                                  items: <String>['male', 'female']
                                      .map<DropdownMenuItem<String>>(
                                    (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                                // Other widgets here...
                              ],
                            );
                          })
                    ],
                  ),
                  const Divider(thickness: 1),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Change Password",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w100),
                      ),
                      Config.extraSpaceSmall,
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text(
                                "**************",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                onTap: () {
                                  dialogBox(context);
                                },
                                child: const FaIcon(
                                  FontAwesomeIcons.penToSquare,
                                  color: Colors.grey,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                          // Other widgets here...
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
      ]),
    ));
  }

  dialogBox(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final newPassConfirmController = TextEditingController();
    bool obsecurePass = false;

    String? validatePasswords(String password) {
      if (password.isEmpty) {
        return "This field cannot be empty";
      } else {
        return null;
      }
    }

    String? validateConfirmPass(String password) {
      if (password.isEmpty) {
        return "This field cannot be empty";
      } else if (password != newPassController.text) {
        return "Passwords do not match";
      } else {
        return null;
      }
    }

    var baseDialog = BaseAlertDialog(
      title: "Change Password",
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        void togglePasswordVisibility() {
          setState(() {
            obsecurePass = !obsecurePass;
          });
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: currentPassController,
              decoration: InputDecoration(
                labelText: "Current password",
                suffixIcon: IconButton(
                  icon: Icon(
                      obsecurePass ? Icons.visibility : Icons.visibility_off),
                  onPressed: togglePasswordVisibility,
                ),
              ),
              validator: (value) => validatePasswords(value!),
              obscureText: !obsecurePass,
            ),
            Config.extraSpaceSmall,
            TextFormField(
              controller: newPassController,
              decoration: InputDecoration(
                labelText: "New password",
                suffixIcon: IconButton(
                  icon: Icon(
                      obsecurePass ? Icons.visibility : Icons.visibility_off),
                  onPressed: togglePasswordVisibility,
                ),
              ),
              validator: (value) => validatePasswords(value!),
              obscureText: !obsecurePass,
            ),
            Config.extraSpaceSmall,
            TextFormField(
              controller: newPassConfirmController,
              decoration: InputDecoration(
                labelText: "Confirm password",
                suffixIcon: IconButton(
                  icon: Icon(
                      obsecurePass ? Icons.visibility : Icons.visibility_off),
                  onPressed: togglePasswordVisibility,
                ),
              ),
              obscureText: !obsecurePass,
              validator: (value) => validateConfirmPass(value!),
            ),
          ],
        );
      }),
      yesOnPressed: () async {
        try {
          await user?.reauthenticateWithCredential(
            EmailAuthProvider.credential(
              email: user.email!,
              password: currentPassController.text,
            ),
          );
          await user?.updatePassword(newPassController.text);
          Navigator.of(context).pop();
        } catch (error) {
          print("Password update failed: $error");
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
