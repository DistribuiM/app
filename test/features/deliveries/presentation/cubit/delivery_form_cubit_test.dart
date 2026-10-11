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
    'emite Loading e LoadError quando buscarClientes lança ServerFailure',
    build: () {
      when(
        () => usuarioRepository.buscarMotoristas(),
      ).thenAnswer((_) async => motoristas);
      when(
        () => clientRepository.buscarClientes(),
      ).thenThrow(const ServerFailure('msg'));
      return DeliveryFormCubit(
        deliveryRepository,
        clientRepository,
        usuarioRepository,
      );
    },
    act: (cubit) => cubit.carregarDados(),
    expect: () => [
      DeliveryFormLoading(),
      const DeliveryFormLoadError('msg'),
    ],
    verify: (_) {
      verify(() => usuarioRepository.buscarMotoristas()).called(1);
      verify(() => clientRepository.buscarClientes()).called(1);
    },
  );

  blocTest<DeliveryFormCubit, DeliveryFormState>(
    'emite Loading e LoadError quando buscarMotoristas lança ServerFailure',
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
    act: (cubit) => cubit.carregarDados(),
    expect: () => [
      DeliveryFormLoading(),
      const DeliveryFormLoadError('msg'),
    ],
    verify: (_) {
      verify(() => usuarioRepository.buscarMotoristas()).called(1);
      verifyNever(() => clientRepository.buscarClientes());
    },
  );

  blocTest<DeliveryFormCubit, DeliveryFormState>(
    'emite Loading e Loaded com motoristas e clientes ao carregar dados',
    build: () {
      when(
        () => usuarioRepository.buscarMotoristas(),
      ).thenAnswer((_) async => motoristas);
      when(
        () => clientRepository.buscarClientes(),
      ).thenAnswer((_) async => clientes);
      return DeliveryFormCubit(
        deliveryRepository,
        clientRepository,
        usuarioRepository,
      );
    },
    act: (cubit) => cubit.carregarDados(),
    expect: () => [
      DeliveryFormLoading(),
      DeliveryFormLoaded(motoristas: motoristas, clientes: clientes),
    ],
    verify: (_) {
      verify(() => usuarioRepository.buscarMotoristas()).called(1);
      verify(() => clientRepository.buscarClientes()).called(1);
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
}
