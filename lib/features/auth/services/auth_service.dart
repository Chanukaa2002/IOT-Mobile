import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //signup with email
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required int weight,
    required int height,
    required int age,
  }) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // 1. Create the user in Firebase Authentication
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      // 2. If user creation is successful, store additional info in Firestore
      if (user != null) {
        // Use the instance we just created
        await firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'weight': weight,
          'height': height,
          'age': age,
          'createdAt': Timestamp.now(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.message}");
      return null;
    } catch (e) {
      print("An unexpected error occurred: $e");
      return null;
    }
  }

  //signin with email
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;

      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.message}");
      throw e; // Pass the error up to the UI
    } catch (e) {
      print("An unexpected error occurred: $e");
      throw Exception('An unexpected error occurred.');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
      // Optionally re-throw the exception to be handled in the UI
      throw Exception('Could not sign out. Please try again.');
    }
  }
}
