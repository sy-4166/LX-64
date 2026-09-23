import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/interview_profile.dart';

class InterviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveProfile({
    required String uid,
    required InterviewProfile profile,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('interview')
        .set(
      {
        ...profile.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<InterviewProfile?> loadProfile({
    required String uid,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('interview')
        .get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return InterviewProfile.fromJson(snapshot.data()!);
  }

  Future<void> clearProfile({
    required String uid,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('interview')
        .delete();
  }
}
