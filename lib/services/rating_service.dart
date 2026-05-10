import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatingService {
  final _db = FirebaseFirestore.instance;

  Future<void> submitRating({
    required String channelId,
    required String toUid,
    required int politeness,     // 1 (olumsuz) veya 5 (olumlu), 0 = verilmedi
    required int topicKnowledge, // 0–5
    required int relevance,      // 0–5
    required String feedback,
    required int earnedPoints, // ← YENİ parametre
  }) async {
    final fromUid = FirebaseAuth.instance.currentUser?.uid;
    if (fromUid == null) return;

    // Verilen puanların ortalamasını hesapla
    final scores = <int>[];
    if (politeness > 0) scores.add(politeness);
    if (topicKnowledge > 0) scores.add(topicKnowledge);
    if (relevance > 0) scores.add(relevance);

    final avgScore = scores.isEmpty
        ? 0.0
        : scores.reduce((a, b) => a + b) / scores.length;

    final batch = _db.batch();

    // /ratings koleksiyonuna kayıt
    final ratingRef = _db.collection('ratings').doc();
    batch.set(ratingRef, {
      'fromUid': fromUid,
      'toUid': toUid,
      'channelId': channelId,
      'politeness': politeness,
      'topicKnowledge': topicKnowledge,
      'relevance': relevance,
      'avgScore': double.parse(avgScore.toStringAsFixed(1)),
      'feedback': feedback,
      'earnedPoints': earnedPoints,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // /sessions/{channelId} → ratedBy listesine ekle
    final sessionRef = _db.collection('sessions').doc(channelId);
    batch.update(sessionRef, {
      'ratedBy': FieldValue.arrayUnion([fromUid]),
    });


Future<void> submitRating({
  required String channelId,
  required String toUid,
  required int politeness,
  required int topicKnowledge,
  required int relevance,
  required String feedback,
  required int earnedPoints, // ← YENİ parametre
}) async {
  final fromUid = FirebaseAuth.instance.currentUser?.uid;
  if (fromUid == null) return;

  final scores = <int>[];
  if (politeness > 0) scores.add(politeness);
  if (topicKnowledge > 0) scores.add(topicKnowledge);
  if (relevance > 0) scores.add(relevance);

  final avgScore = scores.isEmpty
      ? 0.0
      : scores.reduce((a, b) => a + b) / scores.length;

  final batch = _db.batch();

  final ratingRef = _db.collection('ratings').doc();
  batch.set(ratingRef, {
    'fromUid': fromUid,
    'toUid': toUid,
    'channelId': channelId,
    'politeness': politeness,
    'topicKnowledge': topicKnowledge,
    'relevance': relevance,
    'avgScore': double.parse(avgScore.toStringAsFixed(1)),
    'feedback': feedback,
    'earnedPoints': earnedPoints, // ← YENİ
    'createdAt': FieldValue.serverTimestamp(),
  });

  final sessionRef = _db.collection('sessions').doc(channelId);
  batch.update(sessionRef, {
    'ratedBy': FieldValue.arrayUnion([fromUid]),
  });

  // Puan verenin engagement puanını artır ← YENİ
  if (earnedPoints > 0) {
    final fromUserRef = _db.collection('users').doc(fromUid);
    batch.set(fromUserRef, {
      'engagementPoints': FieldValue.increment(earnedPoints),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  await batch.commit();

  if (avgScore > 0) await _updateReputation(toUid);
}

    await batch.commit();

    // /users/{toUid} itibar puanını güncelle
    if (avgScore > 0) await _updateReputation(toUid);
  }



  Future<void> _updateReputation(String uid) async {
    final snap = await _db
        .collection('ratings')
        .where('toUid', isEqualTo: uid)
       // .where('avgScore', isGreaterThan: 0) ← tek where, index gerekmez
        .get();

    if (snap.docs.isEmpty) return;

    final scores = snap.docs
        .map((d) => (d.data()['avgScore'] as num).toDouble())
        .where((s) => s > 0) // ← Dart tarafında filtrele, Firestore'da değil
        .toList();

     if (scores.isEmpty) return;

    final average = scores.reduce((a, b) => a + b) / scores.length;

    await _db.collection('users').doc(uid).set({
      'reputationScore': double.parse(average.toStringAsFixed(1)),
      'totalRatings': scores.length,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}