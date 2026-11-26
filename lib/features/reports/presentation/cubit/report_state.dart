import 'package:equatable/equatable.dart';

import '../../domain/entities/report_summary.dart';

sealed class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  const ReportLoaded(this.resumo);

  final ReportSummary resumo;

  @override
  List<Object?> get props => [resumo];
}

class ReportError extends ReportState {
  const ReportError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
