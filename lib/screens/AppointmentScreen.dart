import 'package:drhouse/components/button.dart';
import 'package:drhouse/utils/config.dart';
import 'package:drhouse/utils/main_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class appointmentscreen extends StatefulWidget {
  final String? selectedDoctorId;
  const appointmentscreen({super.key, this.selectedDoctorId});
  @override
  AppointmentScreenState createState() => AppointmentScreenState();
}

class AppointmentScreenState extends State<appointmentscreen> {
  String? selectedDoctorId;
  DateTime? selectedDateTime;

  @override
  void initState() {
    super.initState();
    selectedDoctorId = widget.selectedDoctorId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              'Your Appointments',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ),
          Config.spaceSmall,
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getUserAppointmentsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text(
                    'No appointments found',
                    style: TextStyle(fontSize: 20),
                  ));
                }
                List<DocumentSnapshot> appointments = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> appointmentData =
                        appointments[index].data() as Map<String, dynamic>;
                    String doctorName = appointmentData['doctorName'];
                    DateTime dateTime = appointmentData['dateTime'].toDate();
                    String status = appointmentData['status'];

                    return ListTile(
                      title: Text('Doctor: $doctorName'),
                      subtitle: Text('Date & Time: ${dateTime.toString()}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Status: $status'),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteAppointment(appointments[index].id);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              _markAsComplete(appointments[index].id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Remaining appointment booking UI (Doctor selection, Date & Time selection, Book Appointment button)
          FutureBuilder<List<DropdownMenuItem<String>>>(
            future: _fetchDoctors(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return ListTile(
                title: const Text('Select Doctor:',
                    style: TextStyle(fontSize: 20)),
                trailing: DropdownButton(
                  value: selectedDoctorId,
                  onChanged: (value) {
                    if (mounted) {
                      setState(() {
                        selectedDoctorId = value.toString();
                      });
                    }
                  },
                  items: snapshot.data ?? [],
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Date and Time:', style: TextStyle(fontSize: 20)),
            subtitle: selectedDateTime == null
                ? const Text('Please select date and time',
                    style: TextStyle(fontSize: 20))
                : Text('Selected: ${selectedDateTime.toString()}',
                    style: const TextStyle(fontSize: 20)),
            // trailing:
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Expanded(
                  child: Button(
                    // width: double.infinity,
                    title: 'Select Date',
                    onPressed: () {
                      _selectDate(context);
                    },
                  ),
                ),
              ),
              // Config.spaceSmall,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Expanded(
                  child: Button(
                    // width: double.infinity,
                    title: 'Select Time',
                    onPressed: () {
                      _selectTime(context);
                    },
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Button(
              width: double.infinity,
              title: 'Book Appointment',
              onPressed: () {
                _bookAppointment();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainLayout()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<DropdownMenuItem<String>>> _fetchDoctors() async {
    List<DropdownMenuItem<String>> items = [];

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Doctors').get();
      querySnapshot.docs.forEach((document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        String doctorId = document.id;
        String doctorName = data['Fullname'];

        items.add(
          DropdownMenuItem(
            value: doctorId, // Use doctorId as the value (unique identifier)
            child: Text(doctorName),
          ),
        );
      });
    } catch (e) {
      print('Error fetching doctors: $e');
    }

    return items;
  }

  void _bookAppointment() {
    if (selectedDoctorId == null || selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select doctor and date/time')),
      );
      return;
    }

    // Fetch doctor's name from Firestore based on selectedDoctorId
    FirebaseFirestore.instance
        .collection('Doctors')
        .doc(selectedDoctorId)
        .get()
        .then((doctorSnapshot) {
      if (!doctorSnapshot.exists) {
        // Doctor document not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected doctor not found')),
        );
        return;
      }

      String doctorName = doctorSnapshot['Fullname'];

      // Create appointment document in Firestore
      FirebaseFirestore.instance.collection('Appointments').add({
        'doctorId': selectedDoctorId,
        'doctorName': doctorName, // Include doctor's name in appointment
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'dateTime': selectedDateTime,
        'status': 'pending',
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment booked successfully!')),
        );
      }).catchError((error) {
        print(error);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Failed to book appointment. Please try again later.'),
          ),
        );
      });
    }).catchError((error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Failed to fetch doctor information. Please try again later.'),
        ),
      );
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (pickedDate != null && mounted) {
      setState(() {
        selectedDateTime = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && mounted) {
      final DateTime now = DateTime.now();
      final DateTime selected = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      setState(() {
        selectedDateTime = selected;
      });
    }
  }

  Stream<QuerySnapshot> _getUserAppointmentsStream() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('Appointments')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  void _markAsComplete(String appointmentId) {
    FirebaseFirestore.instance
        .collection('Appointments')
        .doc(appointmentId)
        .update({'status': 'complete'}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment marked as complete')),
      );
    }).catchError((error) {
      print('Failed to mark appointment as complete: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to mark appointment as complete')),
      );
    });
  }

  void _deleteAppointment(String appointmentId) {
    FirebaseFirestore.instance
        .collection('Appointments')
        .doc(appointmentId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment deleted successfully')),
      );
    }).catchError((error) {
      print('Failed to delete appointment: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete appointment')),
      );
    });
  }
}
