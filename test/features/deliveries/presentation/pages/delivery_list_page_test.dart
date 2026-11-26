import 'package:app_distribuim/core/di/injection_container.dart';
import 'package:app_distribuim/core/router/app_router.dart';
import 'package:app_distribuim/features/auth/domain/entities/usuario.dart';
import 'package:app_distribuim/features/auth/presentation/cubit/session_cubit.dart';
import 'package:app_distribuim/features/auth/presentation/cubit/session_state.dart';
import 'package:app_distribuim/features/clients/presentation/cubit/client_list_cubit.dart';
import 'package:app_distribuim/features/clients/presentation/cubit/client_list_state.dart';
import 'package:app_distribuim/features/deliveries/domain/entities/entrega.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_list_cubit.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_list_state.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_form_cubit.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_form_state.dart';
import 'package:app_distribuim/features/deliveries/presentation/pages/delivery_list.dart';
import 'package:app_distribuim/features/payments/domain/entities/pagamento.dart';
import 'package:app_distribuim/features/payments/presentation/cubit/payment_delete_cubit.dart';
import 'package:app_distribuim/features/payments/presentation/cubit/payment_delete_state.dart';
import 'package:app_distribuim/features/payments/presentation/cubit/payment_details_cubit.dart';
import 'package:app_distribuim/features/payments/presentation/cubit/payment_details_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDeliveryListCubit extends MockCubit<DeliveryListState>
    implements DeliveryListCubit {}

class MockClientListCubit extends MockCubit<ClientListState>
    implements ClientListCubit {}

class MockPaymentDetailsCubit extends MockCubit<PaymentDetailsState>
    implements PaymentDetailsCubit {}

class MockPaymentDeleteCubit extends MockCubit<PaymentDeleteState>
    implements PaymentDeleteCubit {}

class MockDeliveryFormCubit extends MockCubit<DeliveryFormState>
    implements DeliveryFormCubit {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('AppBar action opens delivery filters', (tester) async {
    final usuario = Usuario(
      id: 'admin@example.com',
      nome: 'Admin',
      email: 'admin@example.com',
      cargo: CargoUsuario.admin,
    );
    final sessionCubit = MockSessionCubit();
    whenListen(
      sessionCubit,
      const Stream<SessionState>.empty(),
      initialState: SessionAuthenticated(usuario),
    );

    final entrega = Entrega(
      id: 'entrega-1',
      dataEntrega: '25/11/2026',
      idMotorista: 'motorista-1',
      nomeMotorista: 'Motorista',
      idCliente: 'cliente-1',
      nomeCliente: 'Cliente',
      cidadeCliente: 'Santos',
      quantidadeSacos: 2,
      precoUnitario: 80,
      valorPago: 100,
      valorPendente: 60,
      formaPagamento: 'Pix',
      pago: false,
      entregue: true,
      observacao: '',
    );
    final deliveryListCubit = MockDeliveryListCubit();
    when(() => deliveryListCubit.ouvirEntregas(usuario)).thenReturn(null);
    whenListen(
      deliveryListCubit,
      const Stream<DeliveryListState>.empty(),
      initialState: DeliveryListLoaded([entrega]),
    );
    getIt.registerFactory<DeliveryListCubit>(() => deliveryListCubit);

    final deliveryListKey = GlobalKey<DeliveryListPageState>();
    await tester.pumpWidget(
      BlocProvider<SessionCubit>.value(
        value: sessionCubit,
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  tooltip: 'Filtrar entregas',
                  onPressed: () => deliveryListKey.currentState?.abrirFiltros(),
                  icon: const Icon(Icons.filter_list),
                ),
              ],
            ),
            body: DeliveryList(key: deliveryListKey),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Filtrar entregas'));
    await tester.pumpAndSettle();

    expect(find.text('Filtrar entregas'), findsOneWidget);
    expect(find.text('Tipo de formulário'), findsOneWidget);
  });

  testWidgets('lists standalone payments alongside deliveries', (tester) async {
    final usuario = Usuario(
      id: 'admin@example.com',
      nome: 'Admin',
      email: 'admin@example.com',
      cargo: CargoUsuario.admin,
    );
    final sessionCubit = MockSessionCubit();
    whenListen(
      sessionCubit,
      const Stream<SessionState>.empty(),
      initialState: SessionAuthenticated(usuario),
    );

    final entrega = Entrega(
      id: 'entrega-1',
      dataEntrega: '25/11/2026',
      idMotorista: 'motorista-1',
      nomeMotorista: 'Motorista',
      idCliente: 'Cliente',
      nomeCliente: 'Cliente',
      cidadeCliente: 'Santos',
      quantidadeSacos: 2,
      precoUnitario: 80,
      valorPago: 100,
      valorPendente: 60,
      formaPagamento: 'Pix',
      pago: false,
      entregue: true,
      observacao: '',
    );
    final pagamento = Pagamento(
      id: 'pagamento-1',
      data: '25/11/2026',
      idMotorista: 'motorista-1',
      nomeMotorista: 'Motorista',
      idCliente: 'cliente-2',
      nomeCliente: 'Outro cliente',
      cidadeCliente: 'Guarujá',
      valor: 35,
      formaPagamento: 'Dinheiro',
    );
    final deliveryListCubit = MockDeliveryListCubit();
    when(() => deliveryListCubit.ouvirEntregas(usuario)).thenReturn(null);
    whenListen(
      deliveryListCubit,
      const Stream<DeliveryListState>.empty(),
      initialState: DeliveryListLoaded([entrega], pagamentos: [pagamento]),
    );
    getIt.registerFactory<DeliveryListCubit>(() => deliveryListCubit);

    await tester.pumpWidget(
      BlocProvider<SessionCubit>.value(
        value: sessionCubit,
        child: const MaterialApp(home: Scaffold(body: DeliveryList())),
      ),
    );
    await tester.tap(find.text('25/11/2026'));
    await tester.pumpAndSettle();

    expect(find.text('Entrega'), findsOneWidget);
    expect(find.text('Pagamento'), findsNWidgets(2));
    expect(find.text('R\$35.00'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('opens payment details when its table row is tapped', (
    tester,
  ) async {
    final usuario = Usuario(
      id: 'admin@example.com',
      nome: 'Admin',
      email: 'admin@example.com',
      cargo: CargoUsuario.admin,
    );
    final sessionCubit = MockSessionCubit();
    whenListen(
      sessionCubit,
      const Stream<SessionState>.empty(),
      initialState: SessionAuthenticated(usuario),
    );

    final pagamento = Pagamento(
      id: 'pagamento-1',
      data: '25/11/2026',
      idMotorista: 'motorista-1',
      nomeMotorista: 'Motorista',
      idCliente: 'cliente-2',
      nomeCliente: 'Outro cliente',
      cidadeCliente: 'Guarujá',
      valor: 35,
      formaPagamento: 'Dinheiro',
    );
    final deliveryListCubit = MockDeliveryListCubit();
    when(() => deliveryListCubit.ouvirEntregas(usuario)).thenReturn(null);
    whenListen(
      deliveryListCubit,
      const Stream<DeliveryListState>.empty(),
      initialState: DeliveryListLoaded([], pagamentos: [pagamento]),
    );
    getIt.registerFactory<DeliveryListCubit>(() => deliveryListCubit);

    final clientListCubit = MockClientListCubit();
    when(() => clientListCubit.ouvirClientes(usuario)).thenReturn(null);
    whenListen(
      clientListCubit,
      const Stream<ClientListState>.empty(),
      initialState: ClientListLoaded([]),
    );
    getIt.registerFactory<ClientListCubit>(() => clientListCubit);

    final paymentDetailsCubit = MockPaymentDetailsCubit();
    when(() => paymentDetailsCubit.ouvirPagamento(pagamento)).thenReturn(null);
    whenListen(
      paymentDetailsCubit,
      const Stream<PaymentDetailsState>.empty(),
      initialState: PaymentDetailsLoaded(pagamento),
    );
    getIt.registerFactory<PaymentDetailsCubit>(() => paymentDetailsCubit);

    final paymentDeleteCubit = MockPaymentDeleteCubit();
    whenListen(
      paymentDeleteCubit,
      const Stream<PaymentDeleteState>.empty(),
      initialState: PaymentDeleteInitial(),
    );
    getIt.registerFactory<PaymentDeleteCubit>(() => paymentDeleteCubit);

    final deliveryFormCubit = MockDeliveryFormCubit();
    whenListen(
      deliveryFormCubit,
      const Stream<DeliveryFormState>.empty(),
      initialState: const DeliveryFormLoaded(motoristas: [], clientes: []),
    );
    when(
      () => deliveryFormCubit.carregarDados(usuario, incluirClientes: false),
    ).thenAnswer((_) async {});
    getIt.registerFactory<DeliveryFormCubit>(() => deliveryFormCubit);

    final router = createAppRouter(sessionCubit);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<SessionCubit>.value(
        value: sessionCubit,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Entregas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('25/11/2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Outro cliente'));
    await tester.pumpAndSettle();

    expect(find.text('Detalhe do Pagamento'), findsOneWidget);
    expect(find.text('Outro cliente'), findsOneWidget);
    expect(find.text('Guarujá'), findsOneWidget);
    expect(find.text('Motorista'), findsNWidgets(2));
    expect(find.text('Dinheiro'), findsOneWidget);
    expect(find.text('R\$35.00'), findsOneWidget);
    verify(() => paymentDetailsCubit.ouvirPagamento(pagamento)).called(1);

    await tester.tap(find.byTooltip('Editar pagamento'));
    await tester.pumpAndSettle();

    expect(find.text('Editar Pagamento'), findsOneWidget);
    expect(find.text('Outro cliente - Guarujá'), findsOneWidget);
    verify(
      () => deliveryFormCubit.carregarDados(usuario, incluirClientes: false),
    ).called(1);
  });
}
