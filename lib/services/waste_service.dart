import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WasteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initializeUserStats() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'totalPoints': 0,
          'totalItems': 0,
          'lastUpdated': DateTime.now(),
        });
      }
    }
  }

  Stream<Map<String, dynamic>> getWasteStats() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value({'totalPoints': 0, 'totalItems': 0});
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return {'totalPoints': 0, 'totalItems': 0};
      }
      return {
        'totalPoints': doc.data()?['totalPoints'] ?? 0,
        'totalItems': doc.data()?['totalItems'] ?? 0,
      };
    });
  }
} 