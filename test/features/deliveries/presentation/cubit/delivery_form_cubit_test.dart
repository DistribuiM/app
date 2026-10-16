import 'package:app_distribuim/core/error/failures.dart';
import 'package:app_distribuim/features/auth/domain/entities/usuario.dart';
import 'package:app_distribuim/features/auth/domain/repositories/usuario_repository.dart';
import 'package:app_distribuim/features/clients/domain/entities/cliente.dart';
import 'package:app_distribuim/features/clients/domain/entities/endereco.dart';
import 'package:app_distribuim/features/clients/domain/repositories/client_repository.dart';
import 'package:app_distribuim/features/deliveries/domain/repositories/delivery_repository.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_form_cubit.dart';
import 'package:app_distribuim/features/deliveries/presentation/cubit/delivery_form_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDeliveryRepository extends Mock implements DeliveryRepository {}

class MockClientRepository extends Mock implements ClientRepository {}

class MockUsuarioRepository extends Mock implements UsuarioRepository {}

void main() {
  late MockDeliveryRepository deliveryRepository;
  late MockClientRepository clientRepository;
  late MockUsuarioRepository usuarioRepository;

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
  final motoristas = [
    Usuario(
      id: 'motorista-1',
      nome: 'Motorista',
      email: 'motorista@example.com',
      cargo: CargoUsuario.motorista,
    ),
  ];
  final clientes = [
    Cliente(
      id: 'cliente-1',
      nome: 'Cliente',
      telefone: '11999999999',
      endereco: Endereco(rua: 'Rua A', complemento: '', cidade: 'Cidade'),
      saldoPendente: 0,
      idMotoristaResp: 'motorista-1',
      nomeMotoristaResp: 'Motorista',
    ),
  ];

  setUp(() {
    deliveryRepository = MockDeliveryRepository();
    clientRepository = MockClientRepository();
    usuarioRepository = MockUsuarioRepository();
  });

  blocTest<DeliveryFormCubit, DeliveryFormState>(
    'admin carrega todos os clientes e todos os motoristas após si',
    build: () {
      when(
        () => usuarioRepository.buscarMotoristas(),
      ).thenAnswer((_) async => motoristas);
      when(
        () => clientRepository.buscarClientes(idMotorista: null),
      ).thenAnswer((_) async => clientes);
      return DeliveryFormCubit(
        deliveryRepository,
        clientRepository,
        usuarioRepository,
      );
    },
    act: (cubit) => cubit.carregarDados(admin),
    expect: () => [
      DeliveryFormLoading(),
      DeliveryFormLoaded(
        motoristas: [admin, ...motoristas],
        clientes: clientes,
      ),
    ],
    verify: (_) {
      verifyInOrder([
        () => usuarioRepository.buscarMotoristas(),
        () => clientRepository.buscarClientes(idMotorista: null),
      ]);
    },
  );

  blocTest<DeliveryFormCubit, DeliveryFormState>(
    'motorista carrega somente seus clientes sem buscar motoristas',
    build: () {
      when(
        () => clientRepository.buscarClientes(idMotorista: 'motorista-1'),
      ).thenAnswer((_) async => clientes);
      return DeliveryFormCubit(
        deliveryRepository,
        clientRepository,
        usuarioRepository,
      );
    },
    act: (cubit) => cubit.carregarDados(motorista),
    expect: () => [
      DeliveryFormLoading(),
      DeliveryFormLoaded(motoristas: const [], clientes: clientes),
    ],
    verify: (_) {
      verifyNever(() => usuarioRepository.buscarMotoristas());
      verify(
        () => clientRepository.buscarClientes(idMotorista: 'motorista-1'),
      ).called(1);
    },
  );

  blocTest<DeliveryFormCubit, DeliveryFormState>(
    'admin não busca clientes quando incluirClientes é false',
    build: () {
      when(
        () => usuarioRepository.buscarMotoristas(),
      ).thenAnswer((_) async => motoristas);
      return DeliveryFormCubit(
        deliveryRepository,
        clientRepository,
        usuarioRepository,
      );
    },
    act: (cubit) => cubit.carregarDados(admin, incluirClientes: false),
    expect: () => [
      DeliveryFormLoading(),
      DeliveryFormLoaded(
        motoristas: [admin, ...motoristas],
        clientes: const [],
      ),
    ],
    verify: (_) {
      verify(() => usuarioRepository.buscarMotoristas()).called(1);
      verifyNever(() => clientRepository.buscarClientes(idMotorista: null));
    },
  );

  blocTest<DeliveryFormCubit, DeliveryFormState>(
    'motorista não busca listas quando incluirClientes é false',
    build: () => DeliveryFormCubit(
      deliveryRepository,
      clientRepository,
      usuarioRepository,
    ),
    act: (cubit) => cubit.carregarDados(motorista, incluirClientes: false),
    expect: () => [
      DeliveryFormLoading(),
      DeliveryFormLoaded(motoristas: const [], clientes: const []),
    ],
    verify: (_) {
      verifyNever(() => usuarioRepository.buscarMotoristas());
      verifyNever(
        () => clientRepository.buscarClientes(idMotorista: 'motorista-1'),
      );
    },
  );

  blocTest<DeliveryFormCubit, DeliveryFormState>(
    'admin não busca clientes quando buscarMotoristas falha',
    build: () {
      when(
        () => usuarioRepository.buscarMotoristas(),
      ).thenThrow(const ServerFailure('msg'));
      return DeliveryFormCubit(
        deliveryRepository,
        clientRepository,
        usuarioRepository,
      );
    },
    act: (cubit) => cubit.carregarDados(admin),
    expect: () => [DeliveryFormLoading(), const DeliveryFormLoadError('msg')],
    verify: (_) {
      verify(() => usuarioRepository.buscarMotoristas()).called(1);
      verifyNever(() => clientRepository.buscarClientes(idMotorista: null));
    },
  );

  blocTest<DeliveryFormCubit, DeliveryFormState>(
    'admin emite LoadError quando buscarClientes falha',
    build: () {
      when(
        () => usuarioRepository.buscarMotoristas(),
      ).thenAnswer((_) async => motoristas);
      when(
        () => clientRepository.buscarClientes(idMotorista: null),
      ).thenThrow(const ServerFailure('msg'));
      return DeliveryFormCubit(
        deliveryRepository,
        clientRepository,
        usuarioRepository,
      );
    },
    act: (cubit) => cubit.carregarDados(admin),
    expect: () => [DeliveryFormLoading(), const DeliveryFormLoadError('msg')],
    verify: (_) {
      verify(() => usuarioRepository.buscarMotoristas()).called(1);
      verify(
        () => clientRepository.buscarClientes(idMotorista: null),
      ).called(1);
    },
  );

  blocTest<DeliveryFormCubit, DeliveryFormState>(
    'motorista emite LoadError quando buscarClientes falha',
    build: () {
      when(
        () => clientRepository.buscarClientes(idMotorista: 'motorista-1'),
      ).thenThrow(const ServerFailure('msg'));
      return DeliveryFormCubit(
        deliveryRepository,
        clientRepository,
        usuarioRepository,
      );
    },
    act: (cubit) => cubit.carregarDados(motorista),
    expect: () => [DeliveryFormLoading(), const DeliveryFormLoadError('msg')],
    verify: (_) {
      verifyNever(() => usuarioRepository.buscarMotoristas());
      verify(
        () => clientRepository.buscarClientes(idMotorista: 'motorista-1'),
      ).called(1);
    },
  );

  blocTest<DeliveryFormCubit, DeliveryFormState>(
    'emite mensagem genérica quando buscarClientes lança Exception',
    build: () {
      when(
        () => clientRepository.buscarClientes(idMotorista: 'motorista-1'),
      ).thenThrow(Exception('Falha'));
      return DeliveryFormCubit(
        deliveryRepository,
        clientRepository,
        usuarioRepository,
      );
    },
    act: (cubit) => cubit.carregarDados(motorista),
    expect: () => [
      DeliveryFormLoading(),
      const DeliveryFormLoadError('Erro inesperado. Tente novamente.'),
    ],
    verify: (_) {
      verifyNever(() => usuarioRepository.buscarMotoristas());
      verify(
        () => clientRepository.buscarClientes(idMotorista: 'motorista-1'),
      ).called(1);
    },
  );

  blocTest<DeliveryFormCubit, DeliveryFormState>(
    'emite Error com a mensagem e volta a Loaded após falha ao registrar entrega',
    build: () {
      when(
        () => deliveryRepository.registrarEntrega(
          dataEntrega: '2026-10-11',
          idMotorista: 'motorista-1',
          nomeMotorista: 'Motorista',
          idCliente: 'cliente-1',
          nomeCliente: 'Cliente',
          cidadeCliente: 'Cidade',
          quantidadeSacos: 1,
          precoUnitario: 80,
          valorPago: 0,
          valorPendente: 80,
          formaPagamento: 'Dinheiro',
          pago: false,
          entregue: true,
          observacao: '',
        ),
      ).thenThrow(const ServerFailure('msg'));
      return DeliveryFormCubit(
        deliveryRepository,
        clientRepository,
        usuarioRepository,
      );
    },
    seed: () => DeliveryFormLoaded(motoristas: motoristas, clientes: clientes),
    act: (cubit) => cubit.registrarEntrega(
      dataEntrega: '2026-10-11',
      idMotorista: 'motorista-1',
      nomeMotorista: 'Motorista',
      idCliente: 'cliente-1',
      nomeCliente: 'Cliente',
      cidadeCliente: 'Cidade',
      quantidadeSacos: 1,
      precoUnitario: 80,
      valorPago: 0,
      valorPendente: 80,
      formaPagamento: 'Dinheiro',
      pago: false,
      entregue: true,
      observacao: '',
    ),
    expect: () => [
      DeliveryFormSubmitting(motoristas: motoristas, clientes: clientes),
      const DeliveryFormError('msg'),
      DeliveryFormLoaded(motoristas: motoristas, clientes: clientes),
    ],
    verify: (_) => verify(
      () => deliveryRepository.registrarEntrega(
        dataEntrega: '2026-10-11',
        idMotorista: 'motorista-1',
        nomeMotorista: 'Motorista',
        idCliente: 'cliente-1',
        nomeCliente: 'Cliente',
        cidadeCliente: 'Cidade',
        quantidadeSacos: 1,
        precoUnitario: 80,
        valorPago: 0,
        valorPendente: 80,
        formaPagamento: 'Dinheiro',
        pago: false,
        entregue: true,
        observacao: '',
      ),
    ).called(1),
  );

  blocTest<DeliveryFormCubit, DeliveryFormState>(
    'atualizarEntrega emite Submitting e Success',
    build: () {
      when(
        () => deliveryRepository.atualizarEntrega(
          id: 'entrega-1',
          dataEntrega: '2026-10-15',
          idMotorista: 'motorista-1',
          nomeMotorista: 'Motorista',
          quantidadeSacos: 2,
          precoUnitario: 90,
          valorPago: 50,
          valorPendente: 130,
          formaPagamento: 'Pix',
          pago: false,
          observacao: 'Revisada',
        ),
      ).thenAnswer((_) async {});
      return DeliveryFormCubit(
        deliveryRepository,
        clientRepository,
        usuarioRepository,
      );
    },
    seed: () => DeliveryFormLoaded(motoristas: motoristas, clientes: clientes),
    act: _atualizarEntrega,
    expect: () => [
      DeliveryFormSubmitting(motoristas: motoristas, clientes: clientes),
      DeliveryFormSuccess(),
    ],
    verify: (_) => verify(
      () => deliveryRepository.atualizarEntrega(
        id: 'entrega-1',
        dataEntrega: '2026-10-15',
        idMotorista: 'motorista-1',
        nomeMotorista: 'Motorista',
        quantidadeSacos: 2,
        precoUnitario: 90,
        valorPago: 50,
        valorPendente: 130,
        formaPagamento: 'Pix',
        pago: false,
        observacao: 'Revisada',
      ),
    ).called(1),
  );

  blocTest<DeliveryFormCubit, DeliveryFormState>(
    'atualizarEntrega preserva Failure e retorna a Loaded',
    build: () {
      when(
        () => deliveryRepository.atualizarEntrega(
          id: 'entrega-1',
          dataEntrega: '2026-10-15',
          idMotorista: 'motorista-1',
          nomeMotorista: 'Motorista',
          quantidadeSacos: 2,
          precoUnitario: 90,
          valorPago: 50,
          valorPendente: 130,
          formaPagamento: 'Pix',
          pago: false,
          observacao: 'Revisada',
        ),
      ).thenThrow(const ServerFailure('msg'));
      return DeliveryFormCubit(
        deliveryRepository,
        clientRepository,
        usuarioRepository,
      );
    },
    seed: () => DeliveryFormLoaded(motoristas: motoristas, clientes: clientes),
    act: _atualizarEntrega,
    expect: () => [
      DeliveryFormSubmitting(motoristas: motoristas, clientes: clientes),
      const DeliveryFormError('msg'),
      DeliveryFormLoaded(motoristas: motoristas, clientes: clientes),
    ],
  );

  blocTest<DeliveryFormCubit, DeliveryFormState>(
    'atualizarEntrega usa mensagem genérica para Exception',
    build: () {
      when(
        () => deliveryRepository.atualizarEntrega(
          id: 'entrega-1',
          dataEntrega: '2026-10-15',
          idMotorista: 'motorista-1',
          nomeMotorista: 'Motorista',
          quantidadeSacos: 2,
          precoUnitario: 90,
          valorPago: 50,
          valorPendente: 130,
          formaPagamento: 'Pix',
          pago: false,
          observacao: 'Revisada',
        ),
      ).thenThrow(Exception('falha'));
      return DeliveryFormCubit(
        deliveryRepository,
        clientRepository,
        usuarioRepository,
      );
    },
    seed: () => DeliveryFormLoaded(motoristas: motoristas, clientes: clientes),
    act: _atualizarEntrega,
    expect: () => [
      DeliveryFormSubmitting(motoristas: motoristas, clientes: clientes),
      const DeliveryFormError('Erro inesperado. Tente novamente.'),
      DeliveryFormLoaded(motoristas: motoristas, clientes: clientes),
    ],
  );

  blocTest<DeliveryFormCubit, DeliveryFormState>(
    'atualizarEntrega ignora estados diferentes de Loaded',
    build: () => DeliveryFormCubit(
      deliveryRepository,
      clientRepository,
      usuarioRepository,
    ),
    act: _atualizarEntrega,
    expect: () => <DeliveryFormState>[],
    verify: (_) => verifyNever(
      () => deliveryRepository.atualizarEntrega(
        id: 'entrega-1',
        dataEntrega: '2026-10-15',
        idMotorista: 'motorista-1',
        nomeMotorista: 'Motorista',
        quantidadeSacos: 2,
        precoUnitario: 90,
        valorPago: 50,
        valorPendente: 130,
        formaPagamento: 'Pix',
        pago: false,
        observacao: 'Revisada',
      ),
    ),
  );
}

Future<void> _atualizarEntrega(DeliveryFormCubit cubit) {
  return cubit.atualizarEntrega(
    id: 'entrega-1',
    dataEntrega: '2026-10-15',
    idMotorista: 'motorista-1',
    nomeMotorista: 'Motorista',
    quantidadeSacos: 2,
    precoUnitario: 90,
    valorPago: 50,
    valorPendente: 130,
    formaPagamento: 'Pix',
    pago: false,
    observacao: 'Revisada',
  );
}
