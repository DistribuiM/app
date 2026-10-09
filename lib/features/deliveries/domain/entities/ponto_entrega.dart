class PontoEntrega {
  final String id;
  final String nomeCliente;
  final String endereco;
  final double latitude;
  final double longitude;

  PontoEntrega({
    required this.id,
    required this.nomeCliente,
    required this.endereco,
    required this.latitude,
    required this.longitude,
  });

  factory PontoEntrega.fromMap(Map<String, dynamic> data, String id){
    return PontoEntrega(
      id: id,
      nomeCliente: data['nomeCliente'] ?? '',
      endereco: data['endereco'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'nomeCliente': nomeCliente,
      'endereco': endereco,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

}