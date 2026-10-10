import '../entities/usuario.dart';

abstract class AuthRepository {
  Stream<Usuario?> get sessionChanges;
  Future<Usuario> signInWithGoogle();
  Future<void> signOut();
}
