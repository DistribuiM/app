import 'package:app_distribuim/features/clients/domain/entities/cliente.dart';
import 'package:app_distribuim/features/clients/domain/entities/endereco.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final endereco = Endereco(rua: 'Rua A', complemento: '', cidade: 'Santos');

  test('usa true para documentos antigos sem a permissão de venda a prazo', () {
    final cliente = Cliente.fromMap({
      'nome': 'Cliente',
      'telefone': '11999999999',
      'endereco': endereco.toMap(),
    }, 'cliente-1');

    expect(cliente.permiteVendasAPrazo, isTrue);
  });

  test('lê e serializa a permissão de venda a prazo', () {
    final cliente = Cliente.fromMap({
      'nome': 'Cliente',
      'telefone': '11999999999',
      'endereco': endereco.toMap(),
      'permiteVendasAPrazo': false,
    }, 'cliente-1');

    expect(cliente.permiteVendasAPrazo, isFalse);
    expect(cliente.toMap()['permiteVendasAPrazo'], isFalse);
  });
}
