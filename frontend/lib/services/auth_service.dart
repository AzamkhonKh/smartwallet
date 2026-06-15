import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  String? _userName;
  String? _userEmail;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  final fb_auth.FirebaseAuth _fbAuth = fb_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService() {
    _fbAuth.authStateChanges().listen((fb_auth.User? user) async {
      if (user != null) {
        final idToken = await user.getIdToken();
        _isAuthenticated = true;
        _token = idToken;
        _userName = user.displayName ?? 'User';
        _userEmail = user.email;
        notifyListeners();
      } else {
        if (_token != null && !_token!.startsWith('mock-token-')) {
          _clearAuth();
        }
      }
    });
  }

  void _clearAuth() {
    _isAuthenticated = false;
    _token = null;
    _userName = null;
    _userEmail = null;
    notifyListeners();
  }

  // Google Sign-in using Firebase (Mobile & Web)
  Future<bool> loginWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web uses signInWithPopup
        final googleProvider = fb_auth.GoogleAuthProvider();
        await _fbAuth.signInWithPopup(googleProvider);
        return true;
      } else {
        // Mobile uses google_sign_in package
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return false; // user canceled

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final fb_auth.AuthCredential credential = fb_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _fbAuth.signInWithCredential(credential);
        return true;
      }
    } catch (e) {
      debugPrint("Firebase Google Sign-In failed: $e");
      rethrow;
    }
  }

  // Email/Password Login
  Future<bool> loginWithEmail(String email, String password) async {
    try {
      await _fbAuth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      debugPrint("Firebase Email Sign-In failed: $e");
      rethrow;
    }
  }

  // Email/Password Registration
  Future<bool> registerWithEmail(String email, String password, String name) async {
    try {
      final userCredential = await _fbAuth.createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user?.updateDisplayName(name);
      return true;
    } catch (e) {
      debugPrint("Firebase Email Registration failed: $e");
      rethrow;
    }
  }

  Future<bool> loginMock(String userId) async {
    await _fbAuth.signOut();
    if (!kIsWeb) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }
    _isAuthenticated = true;
    _token = 'mock-token-$userId';
    _userName = userId == 'google_user' ? 'Google User' : userId.toUpperCase();
    _userEmail = '$userId@example.com';
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await _fbAuth.signOut();
    if (!kIsWeb) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }
    _clearAuth();
  }
}
