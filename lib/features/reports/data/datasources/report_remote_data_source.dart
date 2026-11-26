import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../clients/domain/entities/cliente.dart';
import '../../../deliveries/domain/entities/entrega.dart';
import '../../../payments/domain/entities/pagamento.dart';
import '../../domain/entities/dashboard_data.dart';

class ReportRemoteDataSource {
  ReportRemoteDataSource(this._db);

  final FirebaseFirestore _db;

  Stream<DashboardData> ouvirDados() {
    late final StreamController<DashboardData> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
    clientesSubscription;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
    entregasSubscription;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
    pagamentosSubscription;
    List<Cliente>? clientes;
    List<Entrega>? entregas;
    List<Pagamento>? pagamentos;

    void emitirSeCompleto() {
      if (clientes == null || entregas == null || pagamentos == null) return;
      controller.add(
        DashboardData(
          clientes: clientes!,
          entregas: entregas!,
          pagamentos: pagamentos!,
        ),
      );
    }

    controller = StreamController<DashboardData>(
      onListen: () {
        clientesSubscription = _db.collection('clientes').snapshots().listen((
          snapshot,
        ) {
          clientes = snapshot.docs
              .map((doc) => Cliente.fromMap(doc.data(), doc.id))
              .toList();
          emitirSeCompleto();
        }, onError: controller.addError);
        entregasSubscription = _db.collection('entregas').snapshots().listen((
          snapshot,
        ) {
          entregas = snapshot.docs
              .map((doc) => Entrega.fromMap(doc.data(), doc.id))
              .toList();
          emitirSeCompleto();
        }, onError: controller.addError);
        pagamentosSubscription = _db
            .collection('pagamentos')
            .snapshots()
            .listen((snapshot) {
              pagamentos = snapshot.docs
                  .map((doc) => Pagamento.fromMap(doc.data(), doc.id))
                  .toList();
              emitirSeCompleto();
            }, onError: controller.addError);
      },
      onCancel: () async {
        await clientesSubscription?.cancel();
        await entregasSubscription?.cancel();
        await pagamentosSubscription?.cancel();
      },
    );
    return controller.stream;
  }
}
