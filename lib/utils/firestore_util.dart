import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Method to get user document from Firestore
Future<Map<String, dynamic>> getUserData1(String uid) async {
  try {
    // Reference to the users collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Get the document snapshot for the user with specified UID
    DocumentSnapshot userData = await users.doc(uid).get();

    if (userData.exists) {
      // Convert Firestore data to a map and return
      return userData.data() as Map<String, dynamic>;
    } else {
      // Document does not exist
      return {}; // or throw an error, handle as needed
    }
  } catch (e) {
    // Handle errors
    print('Error fetching user data: $e');
    return {}; // Return an empty map or handle error appropriately
  }
}

Future<DocumentSnapshot> getUserData() async {
  // Get the current user from FirebaseAuth
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // Reference to the users collection in Firestore
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Get the user document from Firestore using user's uid
    return await users.doc(user.uid).get();
  } else {
    throw Exception("User not found");
  }
}

Future<List<String>> getDoctorsByCategory(String category) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('Doctors')
      .where('Specialty', isEqualTo: category)
      .get();

  return querySnapshot.docs.map((doc) => doc as String).toList();
}

Future<int> getCollectionSize(
  String collectionPath, {
  String? filterField,
  dynamic filterValue,
  bool favoriteOnly = false,
}) async {
  try {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection(collectionPath);

    Query query = collectionRef;

    // Apply optional filters based on the provided parameters
    if (filterField != null &&
        filterValue != null &&
        filterValue != "General") {
      query = query.where(filterField, isEqualTo: filterValue);
    }

    if (favoriteOnly) {
      // If favoriteOnly is true, target the 'favoriteDoctors' subcollection under the user
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        query = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favoriteDoctors');
      }
    }

    QuerySnapshot querySnapshot = await query.get();

    // Return the number of documents in the collection
    return querySnapshot.size;
  } catch (e) {
    print('Error getting collection size: $e');
    return 0; // Return 0 in case of an error
  }
}
