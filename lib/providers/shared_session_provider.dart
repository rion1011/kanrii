import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/occasion.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';

final sharedOccasionProvider =
    StreamProvider.family<Occasion?, ({String shareCode, String occasionId})>(
        (ref, params) {
  final service = ref.watch(firestoreServiceProvider);
  return service.occasionStream(params.shareCode, params.occasionId);
});

final sharedItemsProvider =
    StreamProvider.family<List<Item>, ({String shareCode, String occasionId})>(
        (ref, params) {
  final service = ref.watch(firestoreServiceProvider);
  return service.itemsStream(params.shareCode, params.occasionId);
});
