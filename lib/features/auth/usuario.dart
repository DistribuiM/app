enum CargoUsuario { motorista, admin }

class Usuario{
  final String id;
  final String nome;
  final String email;
  final CargoUsuario cargo;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.cargo,
  });

  factory Usuario.fromMap(Map<String, dynamic> data, String id){
    String cargoString = data['cargo'] ?? 'motorista';

    CargoUsuario cargoMapeado;
    if (cargoString == 'admin'){
      cargoMapeado = CargoUsuario.admin; 
    }
    else {
      cargoMapeado = CargoUsuario.motorista;
    }

    return Usuario(
      id: id,
      nome: data['nome'] ?? '',
      email: data['email'] ?? '',
      cargo: cargoMapeado,
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'nome': nome,
      'email': email,
      'cargo': cargo.name,
    };
  }

}