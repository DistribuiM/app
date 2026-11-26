import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/report_repository.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  ReportCubit(this._repository) : super(ReportLoading());

  final ReportRepository _repository;
  StreamSubscription? _subscription;

  void ouvirResumo() {
    _subscription?.cancel();
    emit(ReportLoading());
    _subscription = _repository.ouvirResumo().listen(
      (resumo) => emit(ReportLoaded(resumo)),
      onError: (Object error) {
        if (error is Failure) {
          emit(ReportError(error.message));
        } else {
          emit(const ReportError('Erro inesperado. Tente novamente.'));
        }
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
