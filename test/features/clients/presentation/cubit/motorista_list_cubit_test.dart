import 'package:app_distribuim/core/error/failures.dart';
import 'package:app_distribuim/features/auth/domain/entities/usuario.dart';
import 'package:app_distribuim/features/auth/domain/repositories/usuario_repository.dart';
import 'package:app_distribuim/features/clients/presentation/cubit/motorista_list_cubit.dart';
import 'package:app_distribuim/features/clients/presentation/cubit/motorista_list_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUsuarioRepository extends Mock implements UsuarioRepository {}

void main() {
  late MockUsuarioRepository usuarioRepository;
  final motoristas = [
    Usuario(
      id: 'motorista-1',
      nome: 'Motorista',
      email: 'motorista@example.com',
      cargo: CargoUsuario.motorista,
    ),
  ];

  setUp(() {
    usuarioRepository = MockUsuarioRepository();
  });

  blocTest<MotoristaListCubit, MotoristaListState>(
    'emite loading e motoristas carregados quando a busca tem sucesso',
    build: () {
      when(
        () => usuarioRepository.buscarMotoristas(),
      ).thenAnswer((_) async => motoristas);
      return MotoristaListCubit(usuarioRepository);
    },
    act: (cubit) => cubit.carregarMotoristas(),
    expect: () => [MotoristaListLoading(), MotoristaListLoaded(motoristas)],
    verify: (_) => verify(() => usuarioRepository.buscarMotoristas()).called(1),
  );

  blocTest<MotoristaListCubit, MotoristaListState>(
    'emite a mensagem da Failure',
    build: () {
      when(
        () => usuarioRepository.buscarMotoristas(),
      ).thenThrow(const ServerFailure('Falha ao buscar motoristas'));
      return MotoristaListCubit(usuarioRepository);
    },
    act: (cubit) => cubit.carregarMotoristas(),
    expect: () => [
      MotoristaListLoading(),
      const MotoristaListError('Falha ao buscar motoristas'),
    ],
  );

  blocTest<MotoristaListCubit, MotoristaListState>(
    'emite mensagem genérica para Exception comum',
    build: () {
      when(
        () => usuarioRepository.buscarMotoristas(),
      ).thenThrow(Exception('falha'));
      return MotoristaListCubit(usuarioRepository);
    },
    act: (cubit) => cubit.carregarMotoristas(),
    expect: () => [
      MotoristaListLoading(),
      const MotoristaListError('Erro inesperado. Tente novamente.'),
    ],
  );

  blocTest<MotoristaListCubit, MotoristaListState>(
    'permite tentar novamente após erro',
    build: () {
      var chamadas = 0;
      when(() => usuarioRepository.buscarMotoristas()).thenAnswer((_) async {
        if (chamadas++ == 0) {
          throw const ServerFailure('Falha ao buscar motoristas');
        }
        return motoristas;
      });
      return MotoristaListCubit(usuarioRepository);
    },
    act: (cubit) async {
      await cubit.carregarMotoristas();
      await cubit.carregarMotoristas();
    },
    expect: () => [
      MotoristaListLoading(),
      const MotoristaListError('Falha ao buscar motoristas'),
      MotoristaListLoading(),
      MotoristaListLoaded(motoristas),
    ],
  );
}
