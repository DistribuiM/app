// endereco.dart
class Endereco {
  final String rua;
  final String complemento;
  final String cidade;

  Endereco({
    required this.rua,
    required this.complemento,
    required this.cidade,
  });

  factory Endereco.fromMap(Map<String, dynamic> map) {
    return Endereco(
      rua: map['rua'] ?? '',
      complemento: map['complemento'] ?? '',
      cidade: map['cidade'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rua': rua,
      'complemento': complemento,
      'cidade': cidade,
    };
  }
}