import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _clans =>
      _firestore.collection('clans');

  Future<String?> createClan({
    required String name,
    required String emoji,
    String description = '',
  }) async {
    if (_uid.isEmpty) return null;

    final cleanName = name.trim();
    if (cleanName.isEmpty) return null;

    final userSnap =
        await _firestore.collection('users').doc(_uid).get();

    final userData = userSnap.data() ?? {};

    final displayName =
        (userData['name'] is String &&
                (userData['name'] as String).trim().isNotEmpty)
            ? (userData['name'] as String).trim()
            : (_auth.currentUser?.displayName ?? 'Student');

    final clanRef = _clans.doc();

    final batch = _firestore.batch();

    batch.set(clanRef, {
      'name': cleanName,
      'emoji': emoji,
      'description': description.trim(),
      'ownerId': _uid,
      'clanXp': 0,
      'weeklyXp': 0,
      'isPublic': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(clanRef.collection('members').doc(_uid), {
      'uid': _uid,
      'name': displayName,
      'role': 'owner',
      'weeklyXp': 0,
      'totalXp': 0,
      'joinedAt': FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    return clanRef.id;
  }

  Future<void> joinClan(String clanId) async {
    if (_uid.isEmpty || clanId.trim().isEmpty) {
      throw StateError('You must be signed in to join a clan.');
    }

    final clanRef = _clans.doc(clanId);
    final memberRef = clanRef.collection('members').doc(_uid);

    final userSnap =
        await _firestore.collection('users').doc(_uid).get();

    final userData = userSnap.data() ?? {};

    final displayName =
        (userData['name'] is String &&
                (userData['name'] as String).trim().isNotEmpty)
            ? (userData['name'] as String).trim()
            : (_auth.currentUser?.displayName ?? 'Student');

    await _firestore.runTransaction((transaction) async {
      // We are allowed to read the public clan.
      final clanSnap = await transaction.get(clanRef);

      if (!clanSnap.exists) {
        throw StateError('Clan not found.');
      }

      final data = clanSnap.data() ?? {};

      if (data['isPublic'] != true) {
        throw StateError('This clan is private.');
      }

      // IMPORTANT:
      // Do not read the member document here.
      // A non-member does not have permission to read it.
      //
      // Do not update the clan document here either.
      // Only the owner is allowed to update the clan.
      //
      // We simply create/update this user's membership document.
      transaction.set(memberRef, {
        'uid': _uid,
        'name': displayName,
        'role': 'member',
        'weeklyXp': 0,
        'totalXp': 0,
        'joinedAt': FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> leaveClan(String clanId) async {
    if (_uid.isEmpty || clanId.trim().isEmpty) return;

    final clanRef = _clans.doc(clanId);
    final memberRef = clanRef.collection('members').doc(_uid);

    await _firestore.runTransaction((transaction) async {
      final clanSnap = await transaction.get(clanRef);
      final memberSnap = await transaction.get(memberRef);

      if (!clanSnap.exists || !memberSnap.exists) return;

      final data = clanSnap.data() ?? {};

      if (data['ownerId'] == _uid) {
        throw StateError(
          'The clan owner cannot leave the clan yet.',
        );
      }

      transaction.delete(memberRef);
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyClans() {
    if (_uid.isEmpty) {
      return const Stream.empty();
    }

    return _clans
        .where('memberIds', arrayContains: _uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamDiscoverClans() {
    return _clans
        .where('isPublic', isEqualTo: true)
        .limit(30)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamClan(
    String clanId,
  ) {
    return _clans.doc(clanId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMembers(
    String clanId,
  ) {
    return _clans
        .doc(clanId)
        .collection('members')
        .orderBy('weeklyXp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMessages(
    String clanId,
  ) {
    return _clans
        .doc(clanId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();
  }

  Future<void> sendMessage({
    required String clanId,
    required String text,
  }) async {
    if (_uid.isEmpty) return;

    final cleanText = text.trim();

    if (cleanText.isEmpty || cleanText.length > 500) {
      return;
    }

    final userSnap =
        await _firestore.collection('users').doc(_uid).get();

    final userData = userSnap.data() ?? {};

    final displayName =
        (userData['name'] is String &&
                (userData['name'] as String).trim().isNotEmpty)
            ? (userData['name'] as String).trim()
            : (_auth.currentUser?.displayName ?? 'Student');

    await _clans
        .doc(clanId)
        .collection('messages')
        .add({
      'senderId': _uid,
      'senderName': displayName,
      'text': cleanText,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _clans
        .doc(clanId)
        .collection('members')
        .doc(_uid)
        .set({
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteMessage({
    required String clanId,
    required String messageId,
  }) async {
    if (_uid.isEmpty) return;

    await _clans
        .doc(clanId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }
}