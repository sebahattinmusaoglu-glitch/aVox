import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitRating({
    required String channelId,
    required String toUid,
    required int score, // 1–5
  }) async {
    final fromUid = FirebaseAuth.instance.currentUser?.uid;
    if (fromUid == null) return;

    final batch = _firestore.batch();

    // 1. /ratings koleksiyonuna yeni kayıt
    final ratingRef = _firestore.collection('ratings').doc();
    batch.set(ratingRef, {
      'fromUid': fromUid,
      'toUid': toUid,
      'channelId': channelId,
      'score': score,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. /sessions/{channelId} → ratedBy listesine ekle
    final sessionRef = _firestore.collection('sessions').doc(channelId);
    batch.update(sessionRef, {
      'ratedBy': FieldValue.arrayUnion([fromUid]),
    });

    await batch.commit();

    // 3. /users/{toUid} itibar puanını güncelle
    await _updateReputation(toUid);
  }

  Future<void> _updateReputation(String uid) async {
    final ratingsSnap = await _firestore
        .collection('ratings')
        .where('toUid', isEqualTo: uid)
        .get();

    if (ratingsSnap.docs.isEmpty) return;

    final scores = ratingsSnap.docs
        .map((d) => (d.data()['score'] as num).toDouble())
        .toList();

    final average = scores.reduce((a, b) => a + b) / scores.length;
    final total = scores.length;

    await _firestore.collection('users').doc(uid).set({
      'reputationScore': double.parse(average.toStringAsFixed(1)),
      'totalRatings': total,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Kendi itibar puanını çek (profil veya ana sayfa için)
  Future<Map<String, dynamic>?> getReputation(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }
}