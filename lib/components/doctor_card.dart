import 'package:drhouse/utils/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:drhouse/screens/doctor_details.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorCard extends StatefulWidget {
  final String? selectedCategory;
  final int? index;
  final bool? favoriteOnly;
  const DoctorCard(
      {super.key, this.selectedCategory, this.index, this.favoriteOnly});

  @override
  State<DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends State<DoctorCard> {
  bool isFavorite = false;
  late List<String?> doctorNames;
  late List<String?> specialties;
  late List<double?> ratings;
  late List<int?> reviewCounts;
  late List<int?> experiences;
  late List<int?> ages;
  late int numOfDoc;
  bool isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    loadFavoriteStatus();
  }

  Future<void> loadFavoriteStatus() async {
    try {
      await fetchDoctorData();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doctorName = doctorNames[widget.index!];
        final doctorId = await getDoctorUid(doctorName);

        // Check if the current doctor is in the user's favorites
        final favoriteDoctorsRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favoriteDoctors')
            .doc(doctorId);

        final favoriteDoc = await favoriteDoctorsRef.get();
        if (favoriteDoc.exists && mounted) {
          setState(() {
            isFavorite = true; // Update favorite status based on Firestore data
          });
        }
      }
    } catch (error) {
      print('Error loading favorite status: $error');
    }
  }

  Future<String?> getDoctorUid(String? name) async {
    try {
      // Assuming you have a Firestore collection named 'Doctors'
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Doctors')
          .where('Fullname', isEqualTo: name) // Filter by doctor's full name
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Retrieve the UID of the first matching doctor document
        String doctorUid = querySnapshot.docs.first.id;
        return doctorUid; // Return the doctor UID as a String
      } else {
        print('No doctor found with name: $name');
        return null; // Return null if no doctor is found
      }
    } catch (error) {
      print('Error fetching doctors: $error');
      return null; // Return null in case of an error
    }
  }

  Future<void> toggleFavoriteDoctor() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        final doctorName = doctorNames[widget.index!];
        final doctorId = await getDoctorUid(doctorName);
        final favoriteDoctorsRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('favoriteDoctors')
            .doc(doctorId);

        if (isFavorite) {
          // Doctor is already a favorite, remove from favorites
          await favoriteDoctorsRef.delete();
        } else {
          // Doctor is not a favorite, add to favorites
          await favoriteDoctorsRef.set({'doctorId': doctorId});
        }

        if (mounted) {
          setState(() {
            isFavorite = !isFavorite; // Toggle the favorite state
          });
        }
      }
    } catch (error) {
      print('Error toggling favorite doctor: $error');
    }
  }

  Future<void> fetchDoctorData() async {
    try {
      QuerySnapshot? doctorSnapshot;

      // Check if favoriteOnly is true
      if (widget.favoriteOnly == true) {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          final favoriteDoctorsRef = FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('favoriteDoctors');

          final favoriteDoctorIds = await favoriteDoctorsRef.get();

          doctorSnapshot = await FirebaseFirestore.instance
              .collection('Doctors')
              .where(FieldPath.documentId,
                  whereIn: favoriteDoctorIds.docs.map((doc) => doc.id).toList())
              .get();
        }
      } else {
        if (widget.selectedCategory == "General") {
          doctorSnapshot =
              await FirebaseFirestore.instance.collection('Doctors').get();
        } else {
          doctorSnapshot = await FirebaseFirestore.instance
              .collection('Doctors')
              .where('Specialty', isEqualTo: widget.selectedCategory)
              .get();
        }
      }

      List<String?> names = [];
      List<String?> specialities = [];
      List<double?> doctorRatings = [];
      List<int?> doctorReviewCounts = [];
      List<int?> doctorexperiences = [];
      List<int?> doctorages = [];

      doctorSnapshot!.docs.forEach((doctorDoc) {
        var doctorData = doctorDoc.data() as Map<String, dynamic>;
        names.add(doctorData['Fullname']);
        specialities.add(doctorData['Specialty']);
        doctorRatings.add(doctorData['Rating']);
        doctorReviewCounts.add(doctorData['Patients']);
        doctorexperiences.add(doctorData['Experience']);
        doctorages.add(doctorData['Age']);
      });

      if (mounted) {
        setState(() {
          doctorNames = names;
          specialties = specialities;
          ratings = doctorRatings;
          reviewCounts = doctorReviewCounts;
          experiences = doctorexperiences;
          ages = doctorages;
          numOfDoc = names.length;
          isDataLoaded = true;
        });
      }
    } catch (error) {
      print('Error fetching doctor data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);

    if (!isDataLoaded) {
      return const Center(
        child: CircularProgressIndicator(), // Show a loading indicator
      );
    }

    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Card(
          elevation: 5,
          child: Row(
            children: [
              Flexible(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        doctorNames[widget.index!] ?? 'Doctor Name Loading...',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            specialties[widget.index!] ??
                                'Specialty Loading...',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              toggleFavoriteDoctor();
                            },
                            child: FaIcon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_outline,
                              color: Colors.red,
                              size: 35,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Icon(
                            Icons.star_border,
                            color: Colors.yellow,
                            size: 16,
                          ),
                          const Spacer(
                            flex: 1,
                          ),
                          Text(ratings[widget.index!] != null
                              ? ratings[widget.index!]!.toString()
                              : 'Loading...'),
                          const Spacer(
                            flex: 1,
                          ),
                          const Text('Reviews'),
                          const Spacer(
                            flex: 1,
                          ),
                          Text(reviewCounts[widget.index!] != null
                              ? '(${reviewCounts[widget.index!]})'
                              : 'Loading...'),
                          const Spacer(
                            flex: 7,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DoctorDetails(
                    doctorName: doctorNames[widget.index!],
                    specialty: specialties[widget.index!],
                    rating: ratings[widget.index!]!.toString(),
                    reviewCount: reviewCounts[widget.index!]!.toString(),
                    experience: experiences[widget.index!]!.toString(),
                    age: ages[widget.index!]!.toString(),
                  )),
        );
      },
    );
  }
}
