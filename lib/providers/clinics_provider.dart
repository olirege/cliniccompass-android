import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

final clinicsProvider = StreamProvider<List<dynamic>>((ref) {
  return FirebaseFirestore.instance.collection('clinics')
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});
final departmentsProvider = StreamProvider.family<List<dynamic>, String>((ref, clinicId) {
  return FirebaseFirestore.instance.collection('clinics')
    .doc(clinicId)
    .collection('departments')
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});
