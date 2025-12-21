import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email & password
  Future<User> signIn(String email, String password) async {
    final UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user!;
  }

  // Get user data by email (use this because your documents use random doc IDs)
  Future<Map<String, dynamic>?> getUserDataByEmail(String email) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return query.docs.first.data() as Map<String, dynamic>;
  }

  // Optional: register (saves to users collection with uid as doc id)
  Future<User> register(String email, String password, String role) async {
    final UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user!;
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email,
      'role': role,
    });
    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
