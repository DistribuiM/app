import '../entities/usuario.dart';

abstract class AuthRepository {
  Future<Usuario> signInWithGoogle();
  Future<void> signOut();
}
