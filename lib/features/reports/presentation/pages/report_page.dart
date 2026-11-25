import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../domain/entities/report_summary.dart';
import '../cubit/report_cubit.dart';
import '../cubit/report_state.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key, required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    if (!usuario.isAdmin) return const SizedBox.shrink();

    return BlocProvider(
      create: (_) => getIt<ReportCubit>()..ouvirResumo(),
      child: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, state) {
          return switch (state) {
            ReportLoading() => const Center(child: CircularProgressIndicator()),
            ReportError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.read<ReportCubit>().ouvirResumo(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
            ReportLoaded(:final resumo) => _ReportContent(resumo: resumo),
          };
        },
      ),
    );
  }
}

class _ReportContent extends StatelessWidget {
  _ReportContent({required this.resumo});

  final ReportSummary resumo;
  final NumberFormat _moeda = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.sizeOf(context).width;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _SectionTitle('Informações Gerais'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _MetricCard(
              width: (largura - 42) / 2,
              label: 'Valor total pendente',
              value: _moeda.format(resumo.totalPendente),
              icon: Icons.pending_actions,
            ),
            _MetricCard(
              width: (largura - 42) / 2,
              label: 'Valor total pago',
              value: _moeda.format(resumo.totalPago),
              icon: Icons.payments_outlined,
            ),
            _MetricCard(
              width: (largura - 42) / 2,
              label: 'Sacos entregues',
              value: resumo.sacosEntregues.toString(),
              icon: Icons.inventory_2_outlined,
            ),
            _MetricCard(
              width: (largura - 42) / 2,
              label: 'Total de clientes',
              value: resumo.totalClientes.toString(),
              icon: Icons.groups_outlined,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionTitle('Valor Pendente por Motorista'),
        const SizedBox(height: 10),
        _PendingChart(
          values: resumo.pendentesPorMotorista,
          formatCurrency: _moeda.format,
        ),
        const SizedBox(height: 24),
        _SectionTitle(
          'Resumo de Hoje (${DateFormat('dd/MM').format(DateTime.now())})',
        ),
        const SizedBox(height: 10),
        _TodayTable(rows: resumo.resumoDeHoje, formatCurrency: _moeda.format),
        const SizedBox(height: 24),
        const _SectionTitle('Clientes com dívidas'),
        const SizedBox(height: 10),
        _DebtList(
          clientes: resumo.clientesComDividas,
          formatCurrency: _moeda.format,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
  });

  final double width;
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingChart extends StatelessWidget {
  const _PendingChart({
    required this.values,
    required this.formatCurrency,
  });

  final List<ValorPendenteMotorista> values;
  final String Function(num) formatCurrency;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const _EmptySection('Nenhum valor pendente.');

    final maiorValor = values.fold<double>(
      0,
      (maior, item) => item.valor > maior ? item.valor : maior,
    );
    const alturaGrafico = 150.0;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final larguraConteudo = values.length * 82.0;
            final larguraGrafico = larguraConteudo > constraints.maxWidth
                ? larguraConteudo
                : constraints.maxWidth;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 58,
                  height: alturaGrafico,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      4,
                      (index) => Text(
                        formatCurrency(maiorValor * (3 - index) / 3),
                        style: Theme.of(context).textTheme.labelSmall,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: larguraGrafico,
                      child: Column(
                        children: [
                          SizedBox(
                            height: alturaGrafico,
                            child: Stack(
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    4,
                                    (_) => const Divider(height: 1),
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: values.map((item) {
                                    final altura = maiorValor == 0
                                        ? 0.0
                                        : (item.valor / maiorValor) *
                                              (alturaGrafico - 20);
                                    return SizedBox(
                                      width: 82,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            formatCurrency(item.valor),
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            height: altura,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                    top: Radius.circular(4),
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 38,
                            child: Row(
                              children: values
                                  .map(
                                    (item) => SizedBox(
                                      width: 82,
                                      child: Text(
                                        item.nomeMotorista,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelSmall,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TodayTable extends StatelessWidget {
  const _TodayTable({
    required this.rows,
    required this.formatCurrency,
  });

  final List<ResumoMotoristaHoje> rows;
  final String Function(num) formatCurrency;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const _EmptySection('Nenhuma movimentação hoje.');

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Motorista')),
            DataColumn(label: Text('Entregas'), numeric: true),
            DataColumn(label: Text('Dinheiro (R\$)'), numeric: true),
            DataColumn(label: Text('PIX (R\$)'), numeric: true),
            DataColumn(label: Text('Cartão (R\$)'), numeric: true),
            DataColumn(label: Text('Total (R\$)'), numeric: true),
          ],
          rows: rows
              .map(
                (row) => DataRow(
                  cells: [
                    DataCell(Text(row.nomeMotorista)),
                    DataCell(Text(row.entregas.toString())),
                    DataCell(Text(formatCurrency(row.dinheiro))),
                    DataCell(Text(formatCurrency(row.pix))),
                    DataCell(Text(formatCurrency(row.cartao))),
                    DataCell(Text(formatCurrency(row.total))),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _DebtList extends StatelessWidget {
  const _DebtList({
    required this.clientes,
    required this.formatCurrency,
  });

  final List<ClienteComDivida> clientes;
  final String Function(num) formatCurrency;

  @override
  Widget build(BuildContext context) {
    if (clientes.isEmpty) return const _EmptySection('Nenhum cliente com dívida.');

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: clientes
            .map(
              (cliente) => ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(cliente.nome),
                subtitle: cliente.cidade.isEmpty ? null : Text(cliente.cidade),
                trailing: Text(
                  formatCurrency(cliente.valor),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(child: Text(message)),
      ),
    );
  }
}
