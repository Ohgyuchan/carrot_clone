import 'package:carrot_clone/screens/app_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  static late LoginType _loginType = LoginType.Google;
  static Future<FirebaseApp> initializeFirebase({
    required BuildContext context,
  }) async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AppScreen(
            loginType: _loginType,
            user: user,
          ),
        ),
      );
    }

    return firebaseApp;
  }

  static Future<User?> signInWithFacebook() async {
    _loginType = LoginType.Facebook;
    final LoginResult result = await FacebookAuth.instance.login();

    final AccessToken accessToken = result.accessToken!;

    final facebookAuthCredential =
        FacebookAuthProvider.credential(accessToken.token);

    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential);

    final User? user = userCredential.user;

    return user;
  }

  static Future<void> signOutWithFacebook(
      {required BuildContext context}) async {
    try {
      await FacebookAuth.instance.logOut();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      Get.snackbar('', 'Error signing out. Try again.');
    }
  }

  static Future<User?> signInWithGoogle() async {
    _loginType = LoginType.Google;
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
            await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);

          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            Get.snackbar(
              'account-exists-with-different-credential',
              'The account already exists with a different credential.',
            );
          } else if (e.code == 'invalid-credential') {
            Get.snackbar(
              'invalid-credential',
              'Error occurred while accessing credentials. Try again.',
            );
          }
        } catch (e) {
          Get.snackbar(
            'Error',
            'Error occurred using Google Sign-In. Try again.',
          );
        }
      }
      return user;
    }
  }

  static Future<void> signOutWithGoogle({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      Get.snackbar('', 'Error signing out. Try again.');
    }
  }
}

enum LoginType { Google, Facebook, Kakao, Naver }
