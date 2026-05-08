import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static String get _uid => _auth.currentUser!.uid;
  static String? get currentUid => _auth.currentUser?.uid;

  // Kullanıcıyı eşleşme havuzuna ekle
  static Future<void> joinPool(String topic) async {
    await _db.collection('pool').doc(_uid).set({
      'uid': _uid,
      'topic': topic,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  // Eşleşme havuzundan çık
  static Future<void> leavePool() async {
    await _db.collection('pool').doc(_uid).delete();
  }

  // Eşleşme ara ve bekle
  static Stream<DocumentSnapshot> listenForMatch() {
    return _db.collection('matches').doc(_uid).snapshots();
  }

  // Eşleşme kaydını temizle
  static Future<void> clearMatch() async {
    await _db.collection('matches').doc(_uid).delete();
  }

  // Havuzdaki başka bir kullanıcıyı bul ve eşleştir
  static Future<String?> findAndMatch(String topic) async {
    final snapshot = await _db
        .collection('pool')
        .where('uid', isNotEqualTo: _uid)
        .limit(10)
        .get();

    if (snapshot.docs.isEmpty) return null;

    // Önce aynı konudaki kullanıcıyı dene
    final sameTopic = snapshot.docs.where(
      (d) => (d['topic'] as String).toLowerCase() == topic.toLowerCase(),
    );

    final match = sameTopic.isNotEmpty
        ? sameTopic.first
        : snapshot.docs.first;

    final matchedUid = match['uid'] as String;
    final channelId = _generateChannelId(_uid, matchedUid);

    // Her iki kullanıcıya da eşleşmeyi bildir
    final batch = _db.batch();
    batch.set(_db.collection('matches').doc(_uid), {
      'matchedUid': matchedUid,
      'channelId': channelId,
      'topic': topic,
      'matchedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_db.collection('matches').doc(matchedUid), {
      'matchedUid': _uid,
      'channelId': channelId,
      'topic': match['topic'],
      'matchedAt': FieldValue.serverTimestamp(),
    });

    // Her ikisini de havuzdan çıkar
    batch.delete(_db.collection('pool').doc(_uid));
    batch.delete(_db.collection('pool').doc(matchedUid));

    await batch.commit();

    return channelId;
  }

  static String _generateChannelId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0].substring(0, 8)}_${sorted[1].substring(0, 8)}';
  }
}
