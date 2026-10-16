import 'package:app_distribuim/core/di/injection_container.dart';
import 'package:app_distribuim/features/auth/domain/entities/usuario.dart';
import 'package:app_distribuim/features/auth/presentation/cubit/session_cubit.dart';
import 'package:app_distribuim/features/auth/presentation/cubit/session_state.dart';
import 'package:app_distribuim/features/deliveries/domain/entities/entrega.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_details_cubit.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_details_state.dart';
import 'package:app_distribuim/features/deliveries/presentation/pages/delivery_details.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDeliveryDetailsCubit extends MockCubit<DeliveryDetailsState>
    implements DeliveryDetailsCubit {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

late MockDeliveryDetailsCubit deliveryDetailsCubit;

Entrega _makeEntrega({
  bool pago = false,
  bool entregue = true,
  String observacao = '',
}) {
  return Entrega(
    id: 'entrega-1',
    dataEntrega: '27/09/2026',
    idMotorista: 'motorista-1',
    nomeMotorista: 'Pedro Dias',
    idCliente: 'cliente-1',
    nomeCliente: 'Joao',
    cidadeCliente: 'Cubatão',
    quantidadeSacos: 3,
    precoUnitario: 90,
    valorPago: 100,
    valorPendente: 170,
    formaPagamento: 'Pix',
    pago: pago,
    entregue: entregue,
    observacao: observacao,
  );
}

Widget _buildPage(Entrega entrega, Usuario usuario) {
  final sessionCubit = MockSessionCubit();
  whenListen(
    sessionCubit,
    const Stream<SessionState>.empty(),
    initialState: SessionAuthenticated(usuario),
  );

  return BlocProvider<SessionCubit>.value(
    value: sessionCubit,
    child: MaterialApp(home: EntregaPage(entrega: entrega)),
  );
}

Usuario _usuario({
  String id = 'motorista-1',
  CargoUsuario cargo = CargoUsuario.motorista,
}) {
  return Usuario(
    id: id,
    nome: 'Usuario',
    email: 'usuario@example.com',
    cargo: cargo,
  );
}

void main() {
  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  void registerCubit(DeliveryDetailsState initialState, Entrega entrega) {
    deliveryDetailsCubit = MockDeliveryDetailsCubit();
    when(() => deliveryDetailsCubit.ouvirEntrega(entrega)).thenReturn(null);
    whenListen(
      deliveryDetailsCubit,
      const Stream<DeliveryDetailsState>.empty(),
      initialState: initialState,
    );
    getIt.registerFactory<DeliveryDetailsCubit>(() => deliveryDetailsCubit);
  }

  testWidgets('exibe os dados da entrega e do pagamento', (tester) async {
    final entrega = _makeEntrega();
    registerCubit(DeliveryDetailsLoaded(entrega), entrega);
    await tester.pumpWidget(_buildPage(entrega, _usuario()));

    for (final texto in [
      'Detalhe da Entrega',
      'Joao',
      'Cubatão',
      '27/09/2026',
      'Pedro Dias',
      '3',
      'R\$90.00',
      'R\$270.00',
      'R\$100.00',
      'R\$170.00',
      'Pix',
      'Pendente',
      'Entregue',
    ]) {
      expect(find.text(texto), findsOneWidget);
    }
    expect(find.text('Observação'), findsNothing);
  });

  testWidgets('exibe o estado pago e não entregue', (tester) async {
    final entrega = _makeEntrega(pago: true, entregue: false);
    registerCubit(DeliveryDetailsLoaded(entrega), entrega);
    await tester.pumpWidget(_buildPage(entrega, _usuario()));

    expect(find.text('Pago'), findsOneWidget);
    expect(find.text('Não entregue'), findsOneWidget);
  });

  testWidgets('omite observação vazia ou só com espaços', (tester) async {
    final entrega = _makeEntrega(observacao: '   \n ');
    registerCubit(DeliveryDetailsLoaded(entrega), entrega);
    await tester.pumpWidget(_buildPage(entrega, _usuario()));

    expect(find.text('Observação'), findsNothing);
  });

  testWidgets('exibe observação preenchida', (tester) async {
    final entrega = _makeEntrega(observacao: 'Entregar no portão lateral');
    registerCubit(DeliveryDetailsLoaded(entrega), entrega);
    await tester.pumpWidget(_buildPage(entrega, _usuario()));

    await tester.scrollUntilVisible(
      find.text('Entregar no portão lateral'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Observação'), findsOneWidget);
    expect(find.text('Entregar no portão lateral'), findsOneWidget);
  });

  testWidgets('exibe mensagem quando a entrega não existe', (tester) async {
    final entrega = _makeEntrega();
    registerCubit(DeliveryDetailsNotFound(), entrega);
    await tester.pumpWidget(_buildPage(entrega, _usuario()));

    expect(find.text('Entrega não encontrada'), findsOneWidget);
    expect(find.byTooltip('Editar entrega'), findsNothing);
  });

  testWidgets('exibe a mensagem de erro do estado', (tester) async {
    final entrega = _makeEntrega();
    registerCubit(
      const DeliveryDetailsError('Falha ao carregar entrega'),
      entrega,
    );
    await tester.pumpWidget(_buildPage(entrega, _usuario()));

    expect(find.text('Falha ao carregar entrega'), findsOneWidget);
    expect(find.byTooltip('Editar entrega'), findsNothing);
  });

  testWidgets('admin pode editar qualquer entrega', (tester) async {
    final entrega = _makeEntrega();
    registerCubit(DeliveryDetailsLoaded(entrega), entrega);
    await tester.pumpWidget(
      _buildPage(entrega, _usuario(id: 'admin-1', cargo: CargoUsuario.admin)),
    );

    expect(find.byTooltip('Editar entrega'), findsOneWidget);
  });

  testWidgets('motorista pode editar a própria entrega', (tester) async {
    final entrega = _makeEntrega();
    registerCubit(DeliveryDetailsLoaded(entrega), entrega);
    await tester.pumpWidget(_buildPage(entrega, _usuario()));

    expect(find.byTooltip('Editar entrega'), findsOneWidget);
  });

  testWidgets('motorista não pode editar entrega de outro motorista', (
    tester,
  ) async {
    final entrega = _makeEntrega();
    registerCubit(DeliveryDetailsLoaded(entrega), entrega);
    await tester.pumpWidget(_buildPage(entrega, _usuario(id: 'outro-1')));

    expect(find.byTooltip('Editar entrega'), findsNothing);
  });
}
