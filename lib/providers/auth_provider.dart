import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zenith_coffee_shop/models/profile.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('profiles');

  User? _currentUser;
  String? _error;
  String? get error => _error;

  // Sign in method
  Future<User> signIn(Profile profile) async {
    return await _signInWithEmailAndPassword(profile.email, profile.password!);
  }

  Future<User> _signInWithEmailAndPassword(
      String email, String password) async {
    final UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);

    if (userCredential.user == null) {
      throw FirebaseAuthException(
        code: 'null-user',
        message: 'Failed to sign in: User is null',
      );
    }

    return userCredential.user!;
  }

  // Sign up method
  Future<User> signUp(Profile profile) async {
    debugPrint("melakukan registrasi");
    if (profile.password == null || profile.password!.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-password',
        message: 'Password cannot be null or empty',
      );
    }

    try {
      final UserCredential userCredential =
          await _createUserWithEmailAndPassword(
              profile.email, profile.password!);
      final dbRef = FirebaseDatabase.instance.ref();

      final User? user = userCredential.user;

      await dbRef.child("profiles").child(user!.uid).set({
        "username": profile.username,
        "email": profile.email,
        "fullname": profile.fullname,
        "phone_number": profile.phoneNumber,
        "role": profile.role
      });

      if (user == null) {
        throw FirebaseAuthException(
          code: 'null-user',
          message: 'Failed to sign up: User is null',
        );
      }

      print(
          'User UID after sign-up: ${user.uid}'); // Ensure UID is printed here

      // await _createUserProfile(
      //     user, profile); // Save user profile to Realtime Database

      notifyListeners(); // Notify listeners about current user change
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign up error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during sign up: $e');
      rethrow;
    }
  }

  Future<UserCredential> _createUserWithEmailAndPassword(
      String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  // Sign out method
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign out error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during sign out: $e');
      rethrow;
    }
  }

  // Get current user
  User? get currentUser => _currentUser;

  String? get userId => _currentUser?.uid;

  // Stream to listen for auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  AuthProvider() {
    authStateChanges.listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  // Public _dbRef
  DatabaseReference get dbRef => _dbRef;
}
