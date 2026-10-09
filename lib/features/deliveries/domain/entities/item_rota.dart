import 'ponto_entrega.dart';

class ItemRota {
  final PontoEntrega pontoEntrega;
  final int ordem;
  bool concluida;
  DateTime? horarioConclusao; // Isso é só pro registro depois

  ItemRota({
    required this.pontoEntrega,
    required this.ordem,
    this.concluida = false,
    this.horarioConclusao,
  });

  factory ItemRota.fromMap(Map<String, dynamic> data, PontoEntrega ponto){
    return ItemRota(
      pontoEntrega: ponto,
      ordem: data['ordem'] ?? 0,
      concluida: data['concluida'] ?? false,
      horarioConclusao: data['horarioConclusao'] != null
      ? DateTime.parse(data['horarioConclusao'])
      : null
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'pontoEntregaId': pontoEntrega.id,
      'ordem': ordem,
      'concluida': concluida,
      'horarioConclusao': horarioConclusao?.toIso8601String(),
    };
  }

}