import 'item_rota.dart';

class Rota{
  final String id;
  final String motoristaId;
  final DateTime data;
  List<ItemRota> paradas;

  Rota({
    required this.id,
    required this.motoristaId,
    required this.data,
    required this.paradas,
  });

  void ordenarParadas(){
    paradas.sort((a, b) => a.ordem.compareTo(b.ordem));
  }
}