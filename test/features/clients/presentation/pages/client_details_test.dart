import 'package:app_distribuim/core/di/injection_container.dart';
import 'package:app_distribuim/features/auth/domain/entities/usuario.dart';
import 'package:app_distribuim/features/auth/presentation/cubit/session_cubit.dart';
import 'package:app_distribuim/features/auth/presentation/cubit/session_state.dart';
import 'package:app_distribuim/features/clients/domain/entities/cliente.dart';
import 'package:app_distribuim/features/clients/domain/entities/endereco.dart';
import 'package:app_distribuim/features/clients/presentation/cubit/client_delete_cubit.dart';
import 'package:app_distribuim/features/clients/presentation/cubit/client_delete_state.dart';
import 'package:app_distribuim/features/clients/presentation/pages/client_details.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/client_deliveries_cubit.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_list_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockClientDeleteCubit extends MockCubit<ClientDeleteState>
    implements ClientDeleteCubit {}

class MockClientDeliveriesCubit extends MockCubit<DeliveryListState>
    implements ClientDeliveriesCubit {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  final cliente = Cliente(
    id: 'cliente-1',
    nome: 'Cliente',
    telefone: '11999999999',
    endereco: Endereco(rua: 'Rua A', complemento: '', cidade: 'Cidade'),
    saldoPendente: 0,
    idMotoristaResp: 'motorista-1',
    nomeMotoristaResp: 'Motorista',
  );

  Usuario usuario(CargoUsuario cargo) => Usuario(
    id: 'usuario@example.com',
    nome: 'Usuario',
    email: 'usuario@example.com',
    cargo: cargo,
  );

  Future<void> renderPage(
    WidgetTester tester, {
    required CargoUsuario cargo,
  }) async {
    final sessionCubit = MockSessionCubit();
    whenListen(
      sessionCubit,
      const Stream<SessionState>.empty(),
      initialState: SessionAuthenticated(usuario(cargo)),
    );

    final deleteCubit = MockClientDeleteCubit();
    whenListen(
      deleteCubit,
      const Stream<ClientDeleteState>.empty(),
      initialState: ClientDeleteInitial(),
    );
    getIt.registerFactory<ClientDeleteCubit>(() => deleteCubit);

    final deliveriesCubit = MockClientDeliveriesCubit();
    when(
      () => deliveriesCubit.ouvirEntregasDoCliente('cliente-1'),
    ).thenReturn(null);
    whenListen(
      deliveriesCubit,
      const Stream<DeliveryListState>.empty(),
      initialState: const DeliveryListLoaded([]),
    );
    getIt.registerFactory<ClientDeliveriesCubit>(() => deliveriesCubit);

    await tester.pumpWidget(
      BlocProvider<SessionCubit>.value(
        value: sessionCubit,
        child: MaterialApp(home: ClientePage(cliente: cliente)),
      ),
    );
  }

  testWidgets('exibe opção de exclusão para admin', (tester) async {
    await renderPage(tester, cargo: CargoUsuario.admin);

    expect(find.byTooltip('Opções do cliente'), findsOneWidget);
    expect(find.byTooltip('Sair'), findsOneWidget);
  });

  testWidgets('admin precisa confirmar a exclusão do cliente', (tester) async {
    await renderPage(tester, cargo: CargoUsuario.admin);

    await tester.tap(find.byTooltip('Opções do cliente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir cliente'));
    await tester.pumpAndSettle();

    expect(find.text('Excluir cliente?'), findsOneWidget);
  });

  testWidgets('oculta opção de exclusão para motorista', (tester) async {
    await renderPage(tester, cargo: CargoUsuario.motorista);

    expect(find.byTooltip('Opções do cliente'), findsNothing);
    expect(find.byTooltip('Sair'), findsOneWidget);
  });
}
