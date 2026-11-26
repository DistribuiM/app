import 'dart:async';

import 'package:app_distribuim/features/auth/domain/entities/usuario.dart';
import 'package:app_distribuim/features/clients/domain/entities/cliente.dart';
import 'package:app_distribuim/features/clients/domain/entities/endereco.dart';
import 'package:app_distribuim/features/clients/domain/repositories/client_repository.dart';
import 'package:app_distribuim/features/deliveries/domain/entities/entrega.dart';
import 'package:app_distribuim/features/deliveries/domain/entities/filtros_entrega.dart';
import 'package:app_distribuim/features/deliveries/domain/repositories/delivery_repository.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_list_cubit.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_list_state.dart';
import 'package:app_distribuim/features/payments/domain/entities/pagamento.dart';
import 'package:app_distribuim/features/payments/domain/repositories/payment_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDeliveryRepository extends Mock implements DeliveryRepository {}

class MockClientRepository extends Mock implements ClientRepository {}

class MockPaymentRepository extends Mock implements PaymentRepository {}

void main() {
  late MockDeliveryRepository deliveryRepository;
  late MockClientRepository clientRepository;
  late MockPaymentRepository paymentRepository;
  late StreamController<List<Entrega>> controller;
  late StreamController<List<Cliente>> clientController;
  late StreamController<List<Pagamento>> paymentController;
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
  final entrega = Entrega(
    id: 'entrega-1',
    dataEntrega: '2026-10-11',
    idMotorista: 'motorista-1',
    nomeMotorista: 'Motorista',
    idCliente: 'cliente-1',
    nomeCliente: 'Cliente',
    cidadeCliente: 'Cidade',
    quantidadeSacos: 1,
    precoUnitario: 80,
    valorPago: 80,
    valorPendente: 0,
    formaPagamento: 'Dinheiro',
    pago: true,
    entregue: true,
    observacao: '',
  );
  final pagamento = Pagamento(
    id: 'pagamento-1',
    data: '11/10/2026',
    idMotorista: 'motorista-1',
    nomeMotorista: 'Motorista',
    idCliente: 'cliente-1',
    nomeCliente: 'Cliente',
    cidadeCliente: 'Cidade',
    valor: 35,
    formaPagamento: 'Pix',
  );

  setUp(() {
    deliveryRepository = MockDeliveryRepository();
    clientRepository = MockClientRepository();
    paymentRepository = MockPaymentRepository();
    controller = StreamController<List<Entrega>>();
    clientController = StreamController<List<Cliente>>();
    paymentController = StreamController<List<Pagamento>>();
    when(
      () => clientRepository.ouvirClientes(idMotorista: null),
    ).thenAnswer((_) => clientController.stream);
    when(
      () => clientRepository.ouvirClientes(idMotorista: 'motorista-1'),
    ).thenAnswer((_) => clientController.stream);
  });

  tearDown(() async {
    if (!controller.isClosed) {
      await controller.close();
    }
    if (!clientController.isClosed) {
      await clientController.close();
    }
    if (!paymentController.isClosed) {
      await paymentController.close();
    }
  });

  blocTest<DeliveryListCubit, DeliveryListState>(
    'admin ouve todas as entregas e emite dados recebidos',
    build: () {
      when(
        () => deliveryRepository.ouvirEntregas(idMotorista: null),
      ).thenAnswer((_) => controller.stream);
      when(
        () => paymentRepository.ouvirPagamentos(idMotorista: null),
      ).thenAnswer((_) => paymentController.stream);
      return DeliveryListCubit(
        deliveryRepository,
        clientRepository,
        paymentRepository,
      );
    },
    act: (cubit) async {
      cubit.ouvirEntregas(admin);
      controller.add([entrega]);
      clientController.add([]);
      paymentController.add([]);
      await controller.close();
      await clientController.close();
      await paymentController.close();
    },
    expect: () => [
      isA<DeliveryListLoading>(),
      DeliveryListLoaded([entrega], pagamentos: []),
    ],
    verify: (_) {
      verify(
        () => deliveryRepository.ouvirEntregas(idMotorista: null),
      ).called(1);
      verify(
        () => paymentRepository.ouvirPagamentos(idMotorista: null),
      ).called(1);
    },
  );

  blocTest<DeliveryListCubit, DeliveryListState>(
    'motorista ouve somente suas entregas',
    build: () {
      when(
        () => deliveryRepository.ouvirEntregas(idMotorista: 'motorista-1'),
      ).thenAnswer((_) => controller.stream);
      when(
        () => paymentRepository.ouvirPagamentos(idMotorista: 'motorista-1'),
      ).thenAnswer((_) => paymentController.stream);
      return DeliveryListCubit(
        deliveryRepository,
        clientRepository,
        paymentRepository,
      );
    },
    act: (cubit) async {
      cubit.ouvirEntregas(motorista);
      controller.add([entrega]);
      clientController.add([]);
      paymentController.add([pagamento]);
      await controller.close();
      await clientController.close();
      await paymentController.close();
    },
    expect: () => [
      isA<DeliveryListLoading>(),
      DeliveryListLoaded([entrega], pagamentos: [pagamento]),
    ],
    verify: (_) {
      verify(
        () => deliveryRepository.ouvirEntregas(idMotorista: 'motorista-1'),
      ).called(1);
      verify(
        () => paymentRepository.ouvirPagamentos(idMotorista: 'motorista-1'),
      ).called(1);
    },
  );

  blocTest<DeliveryListCubit, DeliveryListState>(
    'emite erro quando o stream falha',
    build: () {
      when(
        () => deliveryRepository.ouvirEntregas(idMotorista: null),
      ).thenAnswer((_) => controller.stream);
      when(
        () => paymentRepository.ouvirPagamentos(idMotorista: null),
      ).thenAnswer((_) => paymentController.stream);
      return DeliveryListCubit(
        deliveryRepository,
        clientRepository,
        paymentRepository,
      );
    },
    act: (cubit) async {
      cubit.ouvirEntregas(admin);
      controller.addError(Exception('Falha no stream'));
      await controller.close();
    },
    expect: () => [
      isA<DeliveryListLoading>(),
      const DeliveryListError(
        'Não foi possível carregar entregas e pagamentos. Tente novamente.',
      ),
    ],
  );

  test('combina filtros e remove apenas o campo selecionado', () async {
    final outraEntrega = Entrega(
      id: 'entrega-2',
      dataEntrega: '2026-10-12',
      idMotorista: 'motorista-2',
      nomeMotorista: 'Outro Motorista',
      idCliente: 'cliente-2',
      nomeCliente: 'Outro Cliente',
      cidadeCliente: 'Outra Cidade',
      quantidadeSacos: 4,
      precoUnitario: 100,
      valorPago: 200,
      valorPendente: 200,
      formaPagamento: 'Pix',
      pago: false,
      entregue: true,
      observacao: '',
    );
    when(
      () => deliveryRepository.ouvirEntregas(idMotorista: null),
    ).thenAnswer((_) => controller.stream);
    when(
      () => paymentRepository.ouvirPagamentos(idMotorista: null),
    ).thenAnswer((_) => paymentController.stream);
    final cubit = DeliveryListCubit(
      deliveryRepository,
      clientRepository,
      paymentRepository,
    );
    cubit.ouvirEntregas(admin);
    final carregado = cubit.stream.firstWhere(
      (state) =>
          state is DeliveryListLoaded &&
          state.clientes.containsKey('cliente-1'),
    );
    clientController.add([
      Cliente(
        id: 'cliente-1',
        nome: 'Cliente atualizado',
        telefone: '111',
        endereco: Endereco(rua: 'Rua', complemento: '', cidade: 'Cidade atual'),
        saldoPendente: 0,
        idMotoristaResp: 'motorista-1',
        nomeMotoristaResp: 'Motorista',
      ),
    ]);
    controller.add([entrega, outraEntrega]);
    paymentController.add([pagamento]);
    await carregado;

    cubit.aplicarFiltros(
      FiltrosEntrega(
        dataInicial: DateTime(2026, 10, 11),
        dataFinal: DateTime(2026, 10, 11),
        idMotorista: 'motorista-1',
        idCliente: 'cliente-1',
        formaPagamento: 'Dinheiro',
        tipoFormulario: TipoFormularioEntrega.entrega,
        cidade: 'Cidade atual',
        quantidadeMinima: 1,
        quantidadeMaxima: 1,
        valorPagoMinimo: 80,
        valorPagoMaximo: 80,
      ),
    );

    var state = cubit.state as DeliveryListLoaded;
    expect(state.entregas, [entrega]);
    expect(state.entregasSemFiltro, [entrega, outraEntrega]);

    cubit.removerFiltro(CampoFiltroEntrega.motorista);
    state = cubit.state as DeliveryListLoaded;
    expect(state.entregas, [entrega]);
    expect(state.filtros.idMotorista, isNull);
    expect(state.filtros.idCliente, 'cliente-1');

    cubit.aplicarFiltros(
      const FiltrosEntrega(
        tipoFormulario: TipoFormularioEntrega.pagamento,
        valorPagoMinimo: 35,
        valorPagoMaximo: 35,
      ),
    );
    state = cubit.state as DeliveryListLoaded;
    expect(state.entregas, isEmpty);
    expect(state.pagamentos, [pagamento]);

    cubit.aplicarFiltros(
      const FiltrosEntrega(
        tipoFormulario: TipoFormularioEntrega.pagamento,
        quantidadeMinima: 1,
      ),
    );
    state = cubit.state as DeliveryListLoaded;
    expect(state.pagamentos, isEmpty);

    await cubit.close();
    await controller.close();
    await clientController.close();
    await paymentController.close();
  });
}
