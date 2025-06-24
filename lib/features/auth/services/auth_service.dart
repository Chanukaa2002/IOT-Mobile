import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cw_app/main.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
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

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        final bool isNewUser =
            userCredential.additionalUserInfo?.isNewUser ?? false;

        if (isNewUser) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': user.displayName ?? 'No Name',
            'email': user.email,
            'weight': 0, // Default value
            'height': 0, // Default value
            'age': 0, // Default value
            'createdAt': Timestamp.now(),
          });
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print("Google Sign-In Firebase Error: ${e.message}");
      throw e;
    } catch (e) {
      print("An unexpected error occurred during Google Sign-In: $e");
      throw Exception('Could not sign in with Google. Please try again.');
    }
  }

  Future<void> signOut() async {
    try {
      goalMonitorService.stopMonitoring();
      tempMonitorService.stopMonitoring();

      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
      throw Exception('Could not sign out. Please try again.');
    }
  }
}
