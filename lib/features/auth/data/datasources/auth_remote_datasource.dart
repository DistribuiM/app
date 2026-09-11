import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../config/app_config.dart';

class AuthRemoteDataSource {
  String getGoogleSignInClientId() {
    if (kIsWeb) {
      return AppConfig.webClientId;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AppConfig.androidClientId;

      case TargetPlatform.iOS:
        return AppConfig.iosClientId;

      default:
        throw UnsupportedError(
          'Google Sign-In not supported on this platform',
        );
    }
  }

  Future<String> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        userCredential = await FirebaseAuth.instance.signInWithPopup(
          GoogleAuthProvider(),
        );
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn.instance;

        await googleSignIn.initialize(
          clientId: getGoogleSignInClientId(),
          serverClientId: AppConfig.webClientId,
        );

        final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();

        if (googleUser == null) {
          throw Exception('Login cancelado pelo usuário.');
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final user = userCredential.user;

      if (user != null && user.email != null) {
        return user.email!;
      }

      throw Exception('Erro ao obter o e-mail do usuário autenticado.');
    } catch (e) {
      throw Exception(
        'Erro ao fazer login com Google: $e',
      );
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn.instance.signOut();
  }
}
