import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/pagamento.dart';

class PaymentRemoteDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Pagamento>> ouvirPagamentos({String? idMotorista}) {
    final pagamentos = _db.collection('pagamentos');
    final query = idMotorista == null
        ? pagamentos
        : pagamentos.where('motorista.id', isEqualTo: idMotorista);

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Pagamento.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  Future<void> registrarPagamento({
    required String data,
    required String idMotorista,
    required String nomeMotorista,
    required String idCliente,
    required String nomeCliente,
    required String cidadeCliente,
    required double valor,
    required String formaPagamento,
  }) async {
    final docRef = _db.collection('pagamentos').doc();
    final batch = _db.batch();

    batch.set(docRef, {
      'id': docRef.id,
      'data': data,
      'motorista': {'id': idMotorista, 'nome': nomeMotorista},
      'cliente': {
        'id': idCliente,
        'nome': nomeCliente,
        'cidade': cidadeCliente,
      },
      'valor': valor,
      'formaPagamento': formaPagamento,
    });
    batch.update(_db.collection('clientes').doc(idCliente), {
      'financeiro.saldoPendente': FieldValue.increment(-valor),
    });
    await batch.commit();

    debugPrint('SUCESSO: Novo pagamento registrado perfeitamente!');
  }
}
