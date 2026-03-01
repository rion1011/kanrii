import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/occasion.dart';
import '../models/item.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService(this._db);

  CollectionReference<Map<String, dynamic>> _occasionsCol(String shareCode) =>
      _db.collection('shared_sessions').doc(shareCode).collection('occasions');

  CollectionReference<Map<String, dynamic>> _itemsCol(
          String shareCode, String occasionId) =>
      _occasionsCol(shareCode).doc(occasionId).collection('items');

  Future<void> createSession(
      String shareCode, Occasion occasion, List<Item> items) async {
    final batch = _db.batch();

    batch.set(
      _db.collection('shared_sessions').doc(shareCode),
      {'createdAt': FieldValue.serverTimestamp()},
    );

    batch.set(
      _occasionsCol(shareCode).doc(occasion.id),
      occasion.toJson(),
    );

    for (final item in items) {
      batch.set(
        _itemsCol(shareCode, occasion.id).doc(item.id),
        item.toJson(),
      );
    }

    await batch.commit();
  }

  Stream<Occasion?> occasionStream(String shareCode, String occasionId) {
    return _occasionsCol(shareCode).doc(occasionId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return Occasion.fromJson(snap.data()!);
    });
  }

  Stream<List<Item>> itemsStream(String shareCode, String occasionId) {
    return _itemsCol(shareCode, occasionId)
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Item.fromJson(d.data())).toList());
  }

  Future<void> saveItem(
      String shareCode, String occasionId, Item item) async {
    await _itemsCol(shareCode, occasionId)
        .doc(item.id)
        .set(item.toJson());
  }

  Future<void> deleteItem(
      String shareCode, String occasionId, String itemId) async {
    await _itemsCol(shareCode, occasionId).doc(itemId).delete();
  }

  Future<void> updateOccasion(String shareCode, Occasion occasion) async {
    await _occasionsCol(shareCode).doc(occasion.id).set(occasion.toJson());
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(FirebaseFirestore.instance);
});
