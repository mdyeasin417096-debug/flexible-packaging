import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<UserCredential> register(String email, String password) {
    return auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> login(String email, String password) {
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordReset(String email) {
    return auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() async {
    final user = auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> logout() => auth.signOut();

  Future<void> saveUserProfile(String uid, Map<String, dynamic> data) {
    return db.collection('users').doc(uid).set(
      <String, dynamic>{
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) {
    return db.collection('users').doc(uid).get();
  }

  Future<String> uploadFile({required String uid, required File file, required String folder}) async {
    final name = file.uri.pathSegments.isEmpty ? 'file' : file.uri.pathSegments.last;
    final reference = storage.ref('$folder/$uid/${DateTime.now().millisecondsSinceEpoch}_$name');
    await reference.putFile(file);
    return reference.getDownloadURL();
  }

  Future<void> registerMessagingToken(String uid) async {
    await messaging.requestPermission();
    final token = await messaging.getToken();
    if (token == null || token.isEmpty) return;

    await db.collection('users').doc(uid).collection('devices').doc(token).set(
      <String, dynamic>{
        'token': token,
        'platform': Platform.isAndroid ? 'android' : 'other',
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> jobsStream() {
    return db.collection('jobs').where('active', isEqualTo: true).orderBy('postedAt', descending: true).snapshots();
  }

  Future<void> saveJob(String uid, String jobId) {
    return db.collection('users').doc(uid).collection('savedJobs').doc(jobId).set(<String, dynamic>{
      'jobId': jobId,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unsaveJob(String uid, String jobId) {
    return db.collection('users').doc(uid).collection('savedJobs').doc(jobId).delete();
  }

  Future<void> applyJob(String uid, String jobId, Map<String, dynamic> data) {
    return db.collection('applications').add(<String, dynamic>{
      ...data,
      'uid': uid,
      'jobId': jobId,
      'status': 'Under Review',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
