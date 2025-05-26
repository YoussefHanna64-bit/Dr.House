import "package:cloud_firestore/cloud_firestore.dart";
import "package:drhouse/main.dart";
import "package:drhouse/screens/personal_info.dart";
import "package:drhouse/screens/login.dart";
import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:url_launcher/url_launcher_string.dart";
import 'package:drhouse/components/dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<DocumentSnapshot> getUserData() async {
    // Get the current user from FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Reference to the users collection in Firestore
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      // Get the user document from Firestore using user's uid
      return await users.doc(user.uid).get();
    } else {
      throw Exception("User not found");
    }
  }

  confirmAccountDeletion(BuildContext context) {
    var baseDialog = BaseAlertDialog(
      title: "Delete Account?",
      content: const Text(
          "Are you sure you want to delete your account? This action cannot be undone."),
      yesOnPressed: () async {
        await deleteAccount();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        ); // Close the dialog
      },
      noOnPressed: () {
        Navigator.of(context).pop();
      },
      yes: "DELETE",
      no: "Cancel",
      yesColor: Colors.red,
      noColor: Colors.grey,
    );
    showDialog(context: context, builder: (BuildContext context) => baseDialog);
  }

  Future<void> deleteAccount() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete(); // Delete the user account
      }
    } catch (e) {
      print("Error deleting account: $e");
      // Handle any errors that occur during account deletion
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to delete account. Please try again later."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('assets/images/background11.jpg'),
                fit: BoxFit.cover,
              )),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      'Settings',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        const CircleAvatar(
                          radius: 60,

                          child: FaIcon(
                            FontAwesomeIcons.user,
                            size: 60,
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hello,',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            FutureBuilder(
                                future:
                                    getUserData(), 
                                builder: (BuildContext context,
                                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator(); 
                                  }

                                  if (snapshot.hasError) {
                                    return Text(
                                        'Error: ${snapshot.error}'); 
                                  }

                                  if (!snapshot.hasData ||
                                      !snapshot.data!.exists) {
                                    return const Text(
                                        'No user data found!'); 
                                  }

                                  var userData = snapshot.data!.data()
                                      as Map<String, dynamic>;
                                  String userFName = userData['firstName'];
                                  String userLName = userData['lastName'];

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            '$userFName $userLName',
                                            style: const TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                })
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const PersonalInfo()),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.person,
                                size: 35,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "Profile",
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info,
                              size: 35,
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  "Policy",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  'Tearms and Conditons',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.restart_alt_sharp,
                              size: 35,
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Version",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  "V 1.0.12",
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(children: [
                              FaIcon(
                                FontAwesomeIcons.solidMoon,
                                size: 35,
                              ),
                              SizedBox(
                                width: 26,
                              ),
                              Text(
                                "Dark Mode",
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ]),
                            Switch(
                              value: SwitchValue.getsalue(),
                              onChanged: (value) {
                                setState(() {
                                  SwitchValue.svalue = !SwitchValue.getsalue();

                                  MyApp.of(context).changeTheme(
                                    SwitchValue.getsalue()
                                        ? ThemeMode.dark
                                        : ThemeMode.light,
                                  );
                                });
                              },
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                confirmAccountDeletion(
                                    context); // Display confirmation dialog for account deletion
                              },
                              child: const Icon(
                                Icons.delete,
                                size: 35,
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            GestureDetector(
                              onTap: () {
                                confirmAccountDeletion(
                                    context); // Display confirmation dialog for account deletion
                              },
                              child: Text(
                                "Delete Account",
                                style: TextStyle(
                                  color: Colors.redAccent.shade700,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            confirmRegister(context);
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.logout_outlined,
                                size: 35,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "Logout",
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                        ),
                        const Divider(thickness: 1),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Contact Us",
                              style: TextStyle(
                                fontSize: 25,
                              ),
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 35,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Hot Line",
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      "19991",
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Text(
                              "Or",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _launchURL("https://www.facebook.com/");
                                    },
                                    child: const FaIcon(
                                      FontAwesomeIcons.facebook,
                                      color: Color.fromARGB(255, 20, 5, 232),
                                      size: 40,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _launchURL("https://www.instagram.com/");
                                    },
                                    child: const FaIcon(
                                      FontAwesomeIcons.instagram,
                                      color: Color.fromARGB(255, 188, 42, 141),
                                      size: 40,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _launchURL(
                                          "https://twitter.com/?lang=ar");
                                    },
                                    child: const FaIcon(
                                      FontAwesomeIcons.twitter,
                                      color: Color.fromARGB(255, 29, 161, 242),
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

_launchURL(url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    throw 'Could not launch $url';
  }
}

class SwitchValue extends ChangeNotifier {
  static bool? svalue = false;

  static bool getsalue() {
    return svalue!;
  }

  void init(BuildContext context) {
    svalue = false;
  }

  void updateValue(BuildContext context) {
    if (svalue!) {
      //MyApp.of(context).changeTheme(ThemeMode.dark);
    } // Notify listeners when the value changes
  }
}

confirmRegister(BuildContext context) {
  var baseDialog = BaseAlertDialog(
    title: "Logout?",
    content: Text("Are you sure you want to logout?"),
    yesOnPressed: () async {
      await FirebaseAuth.instance.signOut();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    },
    noOnPressed: () {
      Navigator.of(context).pop();
    }
  );
  showDialog(context: context, builder: (BuildContext context) => baseDialog);
}
