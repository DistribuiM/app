import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../clients/domain/entities/cliente.dart';
import '../../domain/entities/entrega.dart';

sealed class DeliveryDetailsState extends Equatable {
  const DeliveryDetailsState();

  @override
  List<Object?> get props => [];
}

class DeliveryDetailsInitial extends DeliveryDetailsState {}

class DeliveryDetailsLoaded extends DeliveryDetailsState {
  const DeliveryDetailsLoaded(
    this.entrega, {
    this.cliente,
    this.comprovanteBytes,
    this.comprovanteErro,
  });

  final Entrega entrega;
  final Cliente? cliente;
  final Uint8List? comprovanteBytes;
  final String? comprovanteErro;

  @override
  List<Object?> get props => [entrega, cliente, comprovanteBytes, comprovanteErro];
}

class DeliveryDetailsNotFound extends DeliveryDetailsState {}

class DeliveryDetailsError extends DeliveryDetailsState {
  const DeliveryDetailsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}