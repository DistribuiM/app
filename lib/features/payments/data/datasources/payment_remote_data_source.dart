import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
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

  Stream<List<Pagamento>> ouvirPagamentosDoCliente(String idCliente) {
    return _db
        .collection('pagamentos')
        .where('cliente.id', isEqualTo: idCliente)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Pagamento.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<Pagamento?> ouvirPagamento(String idPagamento) {
    return _db
        .collection('pagamentos')
        .doc(idPagamento)
        .snapshots()
        .map(
          (snapshot) => snapshot.exists
              ? Pagamento.fromMap(snapshot.data()!, snapshot.id)
              : null,
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

  Future<void> atualizarPagamento({
    required String id,
    required String data,
    required String idMotorista,
    required String nomeMotorista,
    required double valor,
    required String formaPagamento,
  }) async {
    final pagamentoRef = _db.collection('pagamentos').doc(id);
    await _db.runTransaction<void>((transaction) async {
      final pagamentoDoc = await transaction.get(pagamentoRef);
      if (!pagamentoDoc.exists) {
        throw const ValidationFailure(
          'Este pagamento não foi encontrado. Ele pode ter sido removido.',
        );
      }

      final dados = pagamentoDoc.data()!;
      final cliente = dados['cliente'];
      final valorAntigo = dados['valor'];
      if (cliente is! Map ||
          cliente['id'] is! String ||
          (cliente['id'] as String).isEmpty ||
          valorAntigo is! num ||
          !valorAntigo.toDouble().isFinite ||
          valorAntigo <= 0) {
        throw const ValidationFailure(
          'Não foi possível editar o pagamento porque seus dados financeiros estão inválidos.',
        );
      }

      final clienteRef = _db
          .collection('clientes')
          .doc(cliente['id'] as String);
      final clienteDoc = await transaction.get(clienteRef);
      if (!clienteDoc.exists) {
        throw const ValidationFailure(
          'Não foi possível editar o pagamento porque o cliente não foi encontrado.',
        );
      }
      _validarDadosFinanceirosCliente(clienteDoc.data());

      transaction.update(pagamentoRef, {
        'data': data,
        'motorista.id': idMotorista,
        'motorista.nome': nomeMotorista,
        'valor': valor,
        'formaPagamento': formaPagamento,
      });

      final diferenca = valorAntigo.toDouble() - valor;
      if (diferenca != 0) {
        transaction.update(clienteRef, {
          'financeiro.saldoPendente': FieldValue.increment(diferenca),
        });
      }
    });

    debugPrint('SUCESSO: Pagamento atualizado perfeitamente!');
  }

  Future<void> excluirPagamento(String id) async {
    final pagamentoRef = _db.collection('pagamentos').doc(id);
    await _db.runTransaction<void>((transaction) async {
      final pagamentoDoc = await transaction.get(pagamentoRef);
      if (!pagamentoDoc.exists) {
        throw const ValidationFailure('Pagamento não encontrado.');
      }

      final dados = pagamentoDoc.data()!;
      final cliente = dados['cliente'];
      final valor = dados['valor'];
      if (cliente is! Map ||
          cliente['id'] is! String ||
          (cliente['id'] as String).isEmpty ||
          valor is! num ||
          !valor.toDouble().isFinite ||
          valor <= 0) {
        throw const ValidationFailure(
          'Não foi possível excluir o pagamento porque seus dados financeiros estão inválidos.',
        );
      }

      final clienteRef = _db
          .collection('clientes')
          .doc(cliente['id'] as String);
      final clienteDoc = await transaction.get(clienteRef);
      if (!clienteDoc.exists) {
        throw const ValidationFailure(
          'Não foi possível excluir o pagamento porque o cliente não foi encontrado.',
        );
      }
      _validarDadosFinanceirosCliente(clienteDoc.data());

      transaction.update(clienteRef, {
        'financeiro.saldoPendente': FieldValue.increment(valor.toDouble()),
      });
      transaction.delete(pagamentoRef);
    });

    debugPrint('SUCESSO: Pagamento excluído perfeitamente!');
  }

  void _validarDadosFinanceirosCliente(Map<String, dynamic>? dados) {
    final financeiro = dados?['financeiro'];
    final saldoPendente = financeiro is Map
        ? financeiro['saldoPendente']
        : null;
    if (saldoPendente is! num || !saldoPendente.toDouble().isFinite) {
      throw const ValidationFailure(
        'Não foi possível atualizar o saldo porque os dados financeiros do cliente estão inválidos.',
      );
    }
  }
}
