import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drhouse/screens/personal_info.dart';
import 'package:flutter/material.dart';
import 'package:drhouse/utils/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:drhouse/components/doctor_card.dart';
import 'package:drhouse/utils/firestore_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedCategory;

  List<Map<String, dynamic>> medCat = [
    {
      "icon": FontAwesomeIcons.userDoctor,
      "category": "General",
    },
    {
      "icon": FontAwesomeIcons.heartPulse,
      "category": "Cardiology",
    },
    {
      "icon": FontAwesomeIcons.lungs,
      "category": "Respirations",
    },
    {
      "icon": FontAwesomeIcons.hand,
      "category": "Dermatology",
    },
    {
      "icon": FontAwesomeIcons.personPregnant,
      "category": "Gynecology",
    },
    {
      "icon": FontAwesomeIcons.teeth,
      "category": "Dental",
    },
  ];

  late Future<int> _documentCountFuture;

  @override
  void initState() {
    super.initState();
    _documentCountFuture = getCollectionSize('Doctors', favoriteOnly: false);
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      child: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FutureBuilder(
                      future: getUserData(), // Fetch user data from Firestore
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
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
                        String userName = userData['firstName'];

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Hello, $userName!',
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // Other widgets here...
                          ],
                        );
                      }),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PersonalInfo()),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 40,
                        child: FaIcon(
                          FontAwesomeIcons.user,
                          size: 40,
                        ),
                      ))
                ],
              ),
              Config.spaceMedium,
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Config.spaceSmall,
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: List<Widget>.generate(medCat.length, (index) {
                    return GestureDetector(
                      child: Card(
                        margin: const EdgeInsets.only(right: 20),
                        color: Colors.green,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              FaIcon(
                                medCat[index]['icon'],
                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                medCat[index]['category'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedCategory = medCat[index]['category'];
                          _documentCountFuture = getCollectionSize("Doctors",
                              filterField: "Specialty",
                              filterValue: selectedCategory,
                              favoriteOnly: false);
                        });
                      },
                    );
                  }),
                ),
              ),
              Config.spaceSmall,
              const Text(
                'Top Doctors',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Config.spaceSmall,
              Expanded(
                  child: FutureBuilder<int>(
                      future: _documentCountFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else {
                          final itemCount = (snapshot.data ?? 0);
                          return ListView.builder(
                              itemCount: itemCount,
                              itemBuilder: (context, index) {
                                return DoctorCard(
                                  selectedCategory: selectedCategory,
                                  index: index,
                                  favoriteOnly: false,
                                );
                              });
                        }
                      }))
            ]),
      ),
    ));
  }
}
