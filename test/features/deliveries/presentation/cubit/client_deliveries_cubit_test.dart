import 'package:app_distribuim/core/error/failures.dart';
import 'package:app_distribuim/features/deliveries/domain/entities/entrega.dart';
import 'package:app_distribuim/features/deliveries/domain/repositories/delivery_repository.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/client_deliveries_cubit.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_list_state.dart';
import 'package:app_distribuim/features/payments/domain/entities/pagamento.dart';
import 'package:app_distribuim/features/payments/domain/repositories/payment_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDeliveryRepository extends Mock implements DeliveryRepository {}

class MockPaymentRepository extends Mock implements PaymentRepository {}

void main() {
  late MockDeliveryRepository deliveryRepository;
  late MockPaymentRepository paymentRepository;

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
  final pagamento = Pagamento(
    id: 'pagamento-1',
    data: '24/11/2026',
    idMotorista: 'motorista-1',
    nomeMotorista: 'Motorista',
    idCliente: 'cliente-1',
    nomeCliente: 'Cliente',
    cidadeCliente: 'Santos',
    valor: 35,
    formaPagamento: 'Dinheiro',
  );

  setUp(() {
    deliveryRepository = MockDeliveryRepository();
    paymentRepository = MockPaymentRepository();
  });

  blocTest<ClientDeliveriesCubit, DeliveryListState>(
    'combina entregas e pagamentos do cliente',
    build: () {
      when(
        () => deliveryRepository.ouvirEntregasDoCliente('cliente-1'),
      ).thenAnswer((_) => Stream.value([entrega]));
      when(
        () => paymentRepository.ouvirPagamentosDoCliente('cliente-1'),
      ).thenAnswer((_) => Stream.value([pagamento]));
      return ClientDeliveriesCubit(deliveryRepository, paymentRepository);
    },
    act: (cubit) => cubit.ouvirEntregasDoCliente('cliente-1'),
    expect: () => [
      DeliveryListLoaded([entrega], pagamentos: [pagamento]),
    ],
    verify: (_) {
      verify(
        () => deliveryRepository.ouvirEntregasDoCliente('cliente-1'),
      ).called(1);
      verify(
        () => paymentRepository.ouvirPagamentosDoCliente('cliente-1'),
      ).called(1);
    },
  );

  blocTest<ClientDeliveriesCubit, DeliveryListState>(
    'emite erro quando o stream de pagamentos falha',
    build: () {
      when(
        () => deliveryRepository.ouvirEntregasDoCliente('cliente-1'),
      ).thenAnswer((_) => Stream.value([entrega]));
      when(
        () => paymentRepository.ouvirPagamentosDoCliente('cliente-1'),
      ).thenAnswer(
        (_) => Stream.error(const ServerFailure('Falha nos pagamentos')),
      );
      return ClientDeliveriesCubit(deliveryRepository, paymentRepository);
    },
    act: (cubit) => cubit.ouvirEntregasDoCliente('cliente-1'),
    expect: () => [const DeliveryListError('Falha nos pagamentos')],
  );
}
