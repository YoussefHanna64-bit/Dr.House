import 'package:drhouse/utils/config.dart';
import 'package:drhouse/utils/firestore_util.dart';
import 'package:flutter/material.dart';
import 'package:drhouse/components/doctor_card.dart';

class Favo extends StatefulWidget {
  const Favo({super.key});

  @override
  State<Favo> createState() => _FavoState();
}

class _FavoState extends State<Favo> {
  late Future<int> _documentCountFuture;

  @override
  void initState() {
    super.initState();
    _documentCountFuture = getCollectionSize('Doctors', favoriteOnly: true);
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Center(
                child: Text(
                  'Favorite Doctors',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
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
                                  index: index,
                                  favoriteOnly: true,
                                );
                              });
                        }
                      }))
            ],
          ),
        ),
      ),
    );
  }
}
