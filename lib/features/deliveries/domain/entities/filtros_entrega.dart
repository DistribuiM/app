import 'package:equatable/equatable.dart';

enum TipoFormularioEntrega { entrega, pagamento }

enum CampoFiltroEntrega {
  periodo,
  motorista,
  cliente,
  formaPagamento,
  tipoFormulario,
  cidade,
  quantidadeSacos,
  valorPago,
}

class FiltrosEntrega extends Equatable {
  const FiltrosEntrega({
    this.dataInicial,
    this.dataFinal,
    this.idMotorista,
    this.idCliente,
    this.formaPagamento,
    this.tipoFormulario,
    this.cidade,
    this.quantidadeMinima,
    this.quantidadeMaxima,
    this.valorPagoMinimo,
    this.valorPagoMaximo,
  });

  final DateTime? dataInicial;
  final DateTime? dataFinal;
  final String? idMotorista;
  final String? idCliente;
  final String? formaPagamento;
  final TipoFormularioEntrega? tipoFormulario;
  final String? cidade;
  final int? quantidadeMinima;
  final int? quantidadeMaxima;
  final double? valorPagoMinimo;
  final double? valorPagoMaximo;

  bool get estaVazio =>
      dataInicial == null &&
      dataFinal == null &&
      idMotorista == null &&
      idCliente == null &&
      formaPagamento == null &&
      tipoFormulario == null &&
      cidade == null &&
      quantidadeMinima == null &&
      quantidadeMaxima == null &&
      valorPagoMinimo == null &&
      valorPagoMaximo == null;

  FiltrosEntrega sem(CampoFiltroEntrega campo) {
    switch (campo) {
      case CampoFiltroEntrega.periodo:
        return FiltrosEntrega(
          idMotorista: idMotorista,
          idCliente: idCliente,
          formaPagamento: formaPagamento,
          tipoFormulario: tipoFormulario,
          cidade: cidade,
          quantidadeMinima: quantidadeMinima,
          quantidadeMaxima: quantidadeMaxima,
          valorPagoMinimo: valorPagoMinimo,
          valorPagoMaximo: valorPagoMaximo,
        );
      case CampoFiltroEntrega.motorista:
        return FiltrosEntrega(
          dataInicial: dataInicial,
          dataFinal: dataFinal,
          idCliente: idCliente,
          formaPagamento: formaPagamento,
          tipoFormulario: tipoFormulario,
          cidade: cidade,
          quantidadeMinima: quantidadeMinima,
          quantidadeMaxima: quantidadeMaxima,
          valorPagoMinimo: valorPagoMinimo,
          valorPagoMaximo: valorPagoMaximo,
        );
      case CampoFiltroEntrega.cliente:
        return FiltrosEntrega(
          dataInicial: dataInicial,
          dataFinal: dataFinal,
          idMotorista: idMotorista,
          formaPagamento: formaPagamento,
          tipoFormulario: tipoFormulario,
          cidade: cidade,
          quantidadeMinima: quantidadeMinima,
          quantidadeMaxima: quantidadeMaxima,
          valorPagoMinimo: valorPagoMinimo,
          valorPagoMaximo: valorPagoMaximo,
        );
      case CampoFiltroEntrega.formaPagamento:
        return FiltrosEntrega(
          dataInicial: dataInicial,
          dataFinal: dataFinal,
          idMotorista: idMotorista,
          idCliente: idCliente,
          tipoFormulario: tipoFormulario,
          cidade: cidade,
          quantidadeMinima: quantidadeMinima,
          quantidadeMaxima: quantidadeMaxima,
          valorPagoMinimo: valorPagoMinimo,
          valorPagoMaximo: valorPagoMaximo,
        );
      case CampoFiltroEntrega.tipoFormulario:
        return FiltrosEntrega(
          dataInicial: dataInicial,
          dataFinal: dataFinal,
          idMotorista: idMotorista,
          idCliente: idCliente,
          formaPagamento: formaPagamento,
          cidade: cidade,
          quantidadeMinima: quantidadeMinima,
          quantidadeMaxima: quantidadeMaxima,
          valorPagoMinimo: valorPagoMinimo,
          valorPagoMaximo: valorPagoMaximo,
        );
      case CampoFiltroEntrega.cidade:
        return FiltrosEntrega(
          dataInicial: dataInicial,
          dataFinal: dataFinal,
          idMotorista: idMotorista,
          idCliente: idCliente,
          formaPagamento: formaPagamento,
          tipoFormulario: tipoFormulario,
          quantidadeMinima: quantidadeMinima,
          quantidadeMaxima: quantidadeMaxima,
          valorPagoMinimo: valorPagoMinimo,
          valorPagoMaximo: valorPagoMaximo,
        );
      case CampoFiltroEntrega.quantidadeSacos:
        return FiltrosEntrega(
          dataInicial: dataInicial,
          dataFinal: dataFinal,
          idMotorista: idMotorista,
          idCliente: idCliente,
          formaPagamento: formaPagamento,
          tipoFormulario: tipoFormulario,
          cidade: cidade,
          valorPagoMinimo: valorPagoMinimo,
          valorPagoMaximo: valorPagoMaximo,
        );
      case CampoFiltroEntrega.valorPago:
        return FiltrosEntrega(
          dataInicial: dataInicial,
          dataFinal: dataFinal,
          idMotorista: idMotorista,
          idCliente: idCliente,
          formaPagamento: formaPagamento,
          tipoFormulario: tipoFormulario,
          cidade: cidade,
          quantidadeMinima: quantidadeMinima,
          quantidadeMaxima: quantidadeMaxima,
        );
    }
  }

  @override
  List<Object?> get props => [
    dataInicial,
    dataFinal,
    idMotorista,
    idCliente,
    formaPagamento,
    tipoFormulario,
    cidade,
    quantidadeMinima,
    quantidadeMaxima,
    valorPagoMinimo,
    valorPagoMaximo,
  ];
}
