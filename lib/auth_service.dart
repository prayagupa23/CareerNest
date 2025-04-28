import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<String?> signUp({
    required String email,
    required String password,
    required String role,
    String? name,
  }) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final uid = userCred.user?.uid;
      if (uid != null) {
        await _db.collection('users').doc(uid).set({
          'email': email,
          'role': role,
          'name': name ?? '',
        });
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unknown error occurred.';
    }
  }

  static Future<String?> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final uid = userCred.user?.uid;
      if (uid != null) {
        final doc = await _db.collection('users').doc(uid).get();
        if (!doc.exists) {
          await _auth.signOut();
          return 'User data not found.';
        }
        final userRole = doc.data()!['role'];
        if (userRole != role) {
          await _auth.signOut();
          return 'This account is registered as $userRole. Please login as $userRole.';
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unknown error occurred.';
    }
  }
} 