import 'package:app_distribuim/core/di/injection_container.dart';
import 'package:app_distribuim/features/auth/domain/entities/usuario.dart';
import 'package:app_distribuim/features/auth/presentation/cubit/session_cubit.dart';
import 'package:app_distribuim/features/auth/presentation/cubit/session_state.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_form_cubit.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_form_state.dart';
import 'package:app_distribuim/features/deliveries/presentation/pages/delivery_form.dart';
import 'package:app_distribuim/features/payments/domain/entities/pagamento.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

class MockDeliveryFormCubit extends MockCubit<DeliveryFormState>
    implements DeliveryFormCubit {}

void main() {
  final motorista = Usuario(
    id: 'motorista-1',
    nome: 'Motorista',
    email: 'motorista@example.com',
    cargo: CargoUsuario.motorista,
  );
  final pagamento = Pagamento(
    id: 'pagamento-1',
    data: '25/11/2026',
    idMotorista: motorista.id,
    nomeMotorista: motorista.nome,
    idCliente: 'cliente-1',
    nomeCliente: 'Cliente',
    cidadeCliente: 'Santos',
    valor: 35,
    formaPagamento: 'Pix',
  );

  late MockDeliveryFormCubit formCubit;

  setUp(() async {
    await getIt.reset();
    formCubit = MockDeliveryFormCubit();
    whenListen(
      formCubit,
      const Stream<DeliveryFormState>.empty(),
      initialState: const DeliveryFormLoaded(motoristas: [], clientes: []),
    );
    when(
      () => formCubit.carregarDados(motorista, incluirClientes: false),
    ).thenAnswer((_) async {});
    getIt.registerFactory<DeliveryFormCubit>(() => formCubit);
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('edita pagamento mantendo cliente e valores iniciais', (
    tester,
  ) async {
    final sessionCubit = MockSessionCubit();
    whenListen(
      sessionCubit,
      const Stream<SessionState>.empty(),
      initialState: SessionAuthenticated(motorista),
    );
    when(
      () => formCubit.atualizarPagamento(
        id: pagamento.id,
        data: pagamento.data,
        idMotorista: motorista.id,
        nomeMotorista: motorista.nome,
        valor: pagamento.valor,
        formaPagamento: pagamento.formaPagamento,
      ),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      BlocProvider<SessionCubit>.value(
        value: sessionCubit,
        child: MaterialApp(
          home: Scaffold(body: DeliveryForm(pagamento: pagamento)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Editar Pagamento'), findsOneWidget);
    expect(find.text('Cliente - Santos'), findsOneWidget);
    expect(find.text('Entrega de Milho'), findsNothing);
    expect(find.byType(DropdownMenu<String>), findsNothing);
    expect(
      tester
          .widgetList<TextField>(find.byType(TextField))
          .map((field) => field.controller?.text),
      containsAll([pagamento.data, '35']),
    );

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    verify(
      () => formCubit.atualizarPagamento(
        id: pagamento.id,
        data: pagamento.data,
        idMotorista: motorista.id,
        nomeMotorista: motorista.nome,
        valor: pagamento.valor,
        formaPagamento: pagamento.formaPagamento,
      ),
    ).called(1);
  });
}
