import 'package:drhouse/components/button.dart';
import 'package:drhouse/screens/AppointmentScreen.dart';
import 'package:drhouse/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:drhouse/components/dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorDetails extends StatefulWidget {
  const DoctorDetails({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.age,
    required this.experience,
  });

  final String? doctorName;
  final String? specialty;

  final String? rating;
  final String? reviewCount;
  final String? age;

  final String? experience;

  // final Future<void>? isFavoriteFun;

  @override
  State<DoctorDetails> createState() => _DoctorDetailsState();
}

class _DoctorDetailsState extends State<DoctorDetails> {
  String? doctorName;
  late String _docID;
  String? specialty;
  String? rating;
  String? reviewCount;
  String? experience;

  String? age;
  bool isFavorite = false;

  // Future<void>? isFavoriteFun;

  @override
  void initState() {
    super.initState();
    doctorName = widget.doctorName;
    specialty = widget.specialty;
    rating = widget.rating;
    reviewCount = widget.reviewCount;
    experience = widget.experience;
    age = widget.age;
    isFavorite = isFavorite;
    _getDoctorUid(widget.doctorName);
  }

  Future<void> _getDoctorUid(String? name) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Doctors')
          .where('Fullname', isEqualTo: name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _docID = querySnapshot.docs.first.id;
      } else {
        print('No doctor found with name: $name');
        _docID = ''; // Handle case where no doctor is found
      }
    } catch (error) {
      print('Error fetching doctors: $error');
      _docID = ''; // Handle error
    }
    setState(() {});
  }

  void _confirmRegister(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => BaseAlertDialog(
      //  title: "Confirmation",
      //  content: const Text("Are you sure you want to book?"),
        yes: "Yes",
        no: "No",
        yesOnPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => appointmentscreen(
                selectedDoctorId: _docID,
              ),
            ),
          );
        },
        noOnPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Align(
                        alignment: Alignment(-0.86, -0.3),
                        child: FaIcon(
                          FontAwesomeIcons.arrowLeft,
                          size: 35,
                          color: Color.fromARGB(255, 95, 233, 54),
                        ),
                      ),
                    ),
                    const Text(
                      'Doctor Details',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 20,)
                  ],
                ),
                AboutDoctor(
                  docName: doctorName,
                  specialty: specialty,
                ),
                DetailBody(
                  docName: doctorName,
                  reviewCount: reviewCount,
                  rating: rating,
                  experience: experience,
                  age: age,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Button(
                    width: double.infinity,
                    title: 'Book Appointment',
                    onPressed: () {
                      // Navigator.of(context).pushNamed('booking_page',
                      //     arguments: {"doctor_id": doctor['doc_id']});
                      _confirmRegister(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AboutDoctor extends StatelessWidget {
  const AboutDoctor(
      {super.key, required this.docName, required this.specialty});

  final String? docName;
  final String? specialty;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          const CircleAvatar(
            radius: 65.0,
            backgroundImage: AssetImage("assets/images/doctor_8.jpg"),
          ),
          Config.spaceMedium,
          Text(
            "Dr. $docName",
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Config.spaceSmall,
          SizedBox(
            width: Config.widthSize * 0.75,
            child: const Text(
              'MBBS (International Medical University, Malaysia), MRCP (Royal College of Physicians, United Kingdom)',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
          Config.spaceSmall,
          SizedBox(
            width: Config.widthSize * 0.75,
            child: Text(
              '$specialty',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class DetailBody extends StatelessWidget {
  const DetailBody(
      {super.key,
      required this.docName,
      required this.rating,
      required this.reviewCount,
      required this.experience,
      required this.age});
  final String? docName;
  final String? rating;
  final String? reviewCount;
  final String? experience;

  final String? age;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Config.spaceSmall,
          DoctorInfo(
            reviewCount: reviewCount,
            exp: experience,
            rating: rating,
            age: age,
          ),
          Config.spaceSmall,
          const Text(
            'About Doctor',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          Config.spaceSmall,
          Text(
            'Dr. $docName Specialist at Sarawak, graduated since 2008, and completed his/her training at Sungai Buloh General Hospital.',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            softWrap: true,
            textAlign: TextAlign.justify,
          )
        ],
      ),
    );
  }
}

class DoctorInfo extends StatelessWidget {
  const DoctorInfo(
      {super.key,
      required this.reviewCount,
      required this.exp,
      required this.rating,
      required this.age});

  final String? reviewCount;
  final String? exp;
  final String? rating;
  final String? age;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Expanded(
                child: InfoCard(
                  label: 'Patients',
                  value: '$reviewCount',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Expanded(
                child: InfoCard(
                  label: 'Rating',
                  value: '$rating',
                ),
              ),
            ),
          ],
        ),
        Config.spaceSmall,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Expanded(
                child: InfoCard(
                  label: 'Age',
                  value: '$age',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Expanded(
                child: InfoCard(
                  label: 'Experiences',
                  value: '$exp years',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.green,
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
