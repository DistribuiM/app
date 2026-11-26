import '../../../clients/domain/entities/cliente.dart';
import '../../../deliveries/domain/entities/entrega.dart';
import '../../../payments/domain/entities/pagamento.dart';

class DashboardData {
  const DashboardData({
    required this.clientes,
    required this.entregas,
    required this.pagamentos,
  });

  final List<Cliente> clientes;
  final List<Entrega> entregas;
  final List<Pagamento> pagamentos;
}
