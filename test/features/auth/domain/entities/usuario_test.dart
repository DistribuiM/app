import 'package:app_distribuim/features/auth/domain/entities/usuario.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Usuario.fromMap', () {
    test('usa motorista quando cargo está ausente', () {
      final usuario = Usuario.fromMap({'nome': 'Pessoa'}, 'pessoa-1');

      expect(usuario.cargo, CargoUsuario.motorista);
    });

    test('interpreta cargo admin', () {
      final usuario = Usuario.fromMap({
        'nome': 'Admin',
        'cargo': 'admin',
      }, 'admin-1');

      expect(usuario.cargo, CargoUsuario.admin);
    });

    test('interpreta cargo motorista', () {
      final usuario = Usuario.fromMap({
        'nome': 'Motorista',
        'cargo': 'motorista',
      }, 'motorista-1');

      expect(usuario.cargo, CargoUsuario.motorista);
    });
  });

  group('isAdmin', () {
    test('é verdadeiro apenas para admin', () {
      final admin = Usuario(
        id: 'admin-1',
        nome: 'Admin',
        email: 'admin@example.com',
        cargo: CargoUsuario.admin,
      );
      final motorista = Usuario(
        id: 'motorista-1',
        nome: 'Motorista',
        email: 'motorista@example.com',
        cargo: CargoUsuario.motorista,
      );

      expect(admin.isAdmin, isTrue);
      expect(motorista.isAdmin, isFalse);
    });
  });
}
