import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';

import '../../config/app_config.dart';

class AuthService {
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

  Future<UserCredential> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      // web
      if (kIsWeb) {
        userCredential = await FirebaseAuth.instance.signInWithPopup(
          GoogleAuthProvider(),
        );
      } else {
        // mobile
        final GoogleSignIn googleSignIn = GoogleSignIn.instance;

        await googleSignIn.initialize(
          clientId: getGoogleSignInClientId(),
          serverClientId: AppConfig.webClientId
        );

        // O '?' garante que não quebre se o usuário fechar o pop-up de login
        final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
        
        if (googleUser == null) {
          throw Exception('Login cancelado pelo usuário.');
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final user = userCredential.user;
      
      if (user != null && user.email != null) {
        final email = user.email!;

        // Verifica se o email existe
        final docSnap = await FirebaseFirestore.instance
            .collection('motoristas')
            .doc(email)
            .get();

        if (!docSnap.exists) {
          // Se o email não foi registrado, mostra que o acesso foi negado
          await signOut();
          throw Exception('Acesso Negado: O e-mail $email não está cadastrado como motorista.');
        }
      }

      // Se passou pela verificação, retorna o login com sucesso
      return userCredential; 
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