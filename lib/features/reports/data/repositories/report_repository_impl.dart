import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._dataSource);

  final ReportRemoteDataSource _dataSource;

  @override
  Stream<ReportSummary> ouvirResumo() async* {
    try {
      await for (final dados in _dataSource.ouvirDados()) {
        yield ReportSummary.fromData(dados);
      }
    } on Failure {
      rethrow;
    } catch (error) {
      debugPrint('Erro ao carregar o resumo: $error');
      throw const ServerFailure(
        'Não foi possível carregar o resumo. Tente novamente.',
      );
    }
  }
}
