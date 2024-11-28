import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getRecyclingRequests() {
    return _firestore
        .collection('recycling_requests')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> approveRequest(String requestId, String userId, int points) async {
    final batch = _firestore.batch();

    try {
      // Get the request document
      final requestDoc = await _firestore
          .collection('recycling_requests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        throw 'Request not found';
      }

      // Update request status
      final requestRef = _firestore.collection('recycling_requests').doc(requestId);
      batch.update(requestRef, {
        'status': 'approved',
        'pointsAwarded': points,
        'approvedAt': FieldValue.serverTimestamp(),
      });

      // Update user's points
      final userRef = _firestore.collection('users').doc(userId);
      batch.set(userRef, {
        'totalPoints': FieldValue.increment(points),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Commit the batch
      await batch.commit();
    } catch (e) {
      throw 'Failed to approve request: $e';
    }
  }

  Future<void> deleteRequest(String requestId) async {
    try {
      // Get the request document first to check if it exists
      final requestDoc = await _firestore
          .collection('recycling_requests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        throw 'Request not found';
      }

      // Delete the request
      await _firestore
          .collection('recycling_requests')
          .doc(requestId)
          .delete();
          
    } catch (e) {
      throw 'Failed to delete request: $e';
    }
  }

  Future<Map<String, int>> getTotalRecyclingStats() async {
    Map<String, int> totals = {
      'plastic': 0,
      'glass': 0,
      'metal': 0,
      'electronics': 0,
    };

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('recycling_requests')
          .where('status', isEqualTo: 'approved')
          .get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final materialType = data['materialType']?.toString().toLowerCase() ?? '';
        final quantity = data['quantity'] as int? ?? 0;

        if (totals.containsKey(materialType)) {
          totals[materialType] = (totals[materialType] ?? 0) + quantity;
        }
      }

      return totals;
    } catch (e) {
      throw 'Failed to get recycling stats: $e';
    }
  }
}
