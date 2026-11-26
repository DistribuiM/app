import 'package:app_distribuim/core/di/injection_container.dart';
import 'package:app_distribuim/features/auth/domain/entities/usuario.dart';
import 'package:app_distribuim/features/auth/presentation/cubit/session_cubit.dart';
import 'package:app_distribuim/features/auth/presentation/cubit/session_state.dart';
import 'package:app_distribuim/features/payments/domain/entities/pagamento.dart';
import 'package:app_distribuim/features/payments/presentation/cubit/payment_delete_cubit.dart';
import 'package:app_distribuim/features/payments/presentation/cubit/payment_delete_state.dart';
import 'package:app_distribuim/features/payments/presentation/cubit/payment_details_cubit.dart';
import 'package:app_distribuim/features/payments/presentation/cubit/payment_details_state.dart';
import 'package:app_distribuim/features/payments/presentation/pages/payment_details.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

class MockPaymentDetailsCubit extends MockCubit<PaymentDetailsState>
    implements PaymentDetailsCubit {}

class MockPaymentDeleteCubit extends MockCubit<PaymentDeleteState>
    implements PaymentDeleteCubit {}

void main() {
  final pagamento = Pagamento(
    id: 'pagamento-1',
    data: '25/11/2026',
    idMotorista: 'motorista-1',
    nomeMotorista: 'Motorista',
    idCliente: 'cliente-1',
    nomeCliente: 'Cliente',
    cidadeCliente: 'Santos',
    valor: 35,
    formaPagamento: 'Pix',
  );
  final admin = Usuario(
    id: 'admin-1',
    nome: 'Admin',
    email: 'admin@example.com',
    cargo: CargoUsuario.admin,
  );
  final motoristaResponsavel = Usuario(
    id: 'motorista-1',
    nome: 'Motorista',
    email: 'motorista@example.com',
    cargo: CargoUsuario.motorista,
  );
  final outroMotorista = Usuario(
    id: 'motorista-2',
    nome: 'Outro motorista',
    email: 'outro@example.com',
    cargo: CargoUsuario.motorista,
  );

  late MockPaymentDetailsCubit detailsCubit;
  late MockPaymentDeleteCubit deleteCubit;

  setUp(() async {
    await getIt.reset();
    detailsCubit = MockPaymentDetailsCubit();
    deleteCubit = MockPaymentDeleteCubit();
    whenListen(
      detailsCubit,
      const Stream<PaymentDetailsState>.empty(),
      initialState: PaymentDetailsLoaded(pagamento),
    );
    when(() => detailsCubit.ouvirPagamento(pagamento)).thenReturn(null);
    whenListen(
      deleteCubit,
      const Stream<PaymentDeleteState>.empty(),
      initialState: PaymentDeleteInitial(),
    );
    getIt
      ..registerFactory<PaymentDetailsCubit>(() => detailsCubit)
      ..registerFactory<PaymentDeleteCubit>(() => deleteCubit);
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('admin pode editar e excluir pagamento', (tester) async {
    await _pumpDetails(tester, admin, pagamento);

    expect(find.byTooltip('Editar pagamento'), findsOneWidget);
    expect(find.byTooltip('Opções do pagamento'), findsOneWidget);
  });

  testWidgets('motorista responsável pode editar, mas não excluir', (
    tester,
  ) async {
    await _pumpDetails(tester, motoristaResponsavel, pagamento);

    expect(find.byTooltip('Editar pagamento'), findsOneWidget);
    expect(find.byTooltip('Opções do pagamento'), findsNothing);
  });

  testWidgets('outro motorista não pode editar nem excluir', (tester) async {
    await _pumpDetails(tester, outroMotorista, pagamento);

    expect(find.byTooltip('Editar pagamento'), findsNothing);
    expect(find.byTooltip('Opções do pagamento'), findsNothing);
  });

  testWidgets('admin confirma exclusão do pagamento', (tester) async {
    when(
      () => deleteCubit.excluirPagamento(admin, pagamento.id),
    ).thenAnswer((_) async {});
    await _pumpDetails(tester, admin, pagamento);

    await tester.tap(find.byTooltip('Opções do pagamento'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir pagamento'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
    await tester.pumpAndSettle();

    verify(() => deleteCubit.excluirPagamento(admin, pagamento.id)).called(1);
  });
}

Future<void> _pumpDetails(
  WidgetTester tester,
  Usuario usuario,
  Pagamento pagamento,
) async {
  final sessionCubit = MockSessionCubit();
  whenListen(
    sessionCubit,
    const Stream<SessionState>.empty(),
    initialState: SessionAuthenticated(usuario),
  );
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => PagamentoPage(pagamento: pagamento),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    BlocProvider<SessionCubit>.value(
      value: sessionCubit,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}
