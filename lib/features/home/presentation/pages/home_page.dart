import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../clients/domain/entities/cliente.dart';
import '../../../clients/presentation/cubit/client_list_cubit.dart';
import '../../../clients/presentation/cubit/client_list_state.dart';
import '../../../clients/presentation/models/cliente_filtro.dart';
import '../../../clients/presentation/widgets/filtro_clientes_sheet.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../clients/presentation/pages/client_list.dart';
import '../../../../core/widgets/custom_appbar.dart';
import '../../../../core/widgets/custom_bottom_appbar.dart';
import '../../../deliveries/presentation/pages/delivery_list.dart';
import '../../../reports/presentation/pages/report_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  final GlobalKey<DeliveryListPageState> _deliveryListKey =
      GlobalKey<DeliveryListPageState>();
  final TextEditingController _buscaClientesController =
      TextEditingController();
  bool _buscaClientesAberta = false;
  String _consultaNomeCliente = '';
  ClienteFiltro _filtroClientes = const ClienteFiltro();

  @override
  void dispose() {
    _selectedIndex.dispose();
    _buscaClientesController.dispose();
    super.dispose();
  }

  void _alternarBuscaClientes() {
    if (_buscaClientesAberta) {
      FocusScope.of(context).unfocus();
    }
    setState(() {
      _buscaClientesAberta = !_buscaClientesAberta;
      if (!_buscaClientesAberta) {
        _buscaClientesController.clear();
        _consultaNomeCliente = '';
      }
    });
  }

  Future<void> _abrirFiltros(BuildContext context) async {
    final estado = context.read<ClientListCubit>().state;
    final clientes = estado is ClientListLoaded ? estado.clientes : <Cliente>[];

    final cidades =
        clientes
            .map((cliente) => cliente.endereco.cidade)
            .where((cidade) => cidade.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    final motoristas = <String, String>{};
    for (final cliente in clientes) {
      motoristas[cliente.idMotoristaResp] = cliente.nomeMotoristaResp;
    }

    final resultado = await showModalBottomSheet<ClienteFiltro>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FiltroClientesSheet(
        filtroAtual: _filtroClientes,
        cidades: cidades,
        // Só o admin filtra por motorista
        motoristas: widget.usuario.isAdmin ? motoristas : const {},
      ),
    );

    if (resultado != null && mounted) {
      setState(() => _filtroClientes = resultado);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<TabDestination> destinations = [
      TabDestination(
        appBar: CustomAppBar(
          title: 'Clientes',
          titleContent: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: _buscaClientesAberta
                ? TextField(
                    key: const ValueKey('busca-clientes'),
                    controller: _buscaClientesController,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      hintText: 'Buscar cliente',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (consulta) {
                      setState(() => _consultaNomeCliente = consulta);
                    },
                  )
                : const Text(
                    'Clientes',
                    key: ValueKey('titulo-clientes'),
                    style: TextStyle(color: Colors.white),
                  ),
          ),
          actions: [
            Builder(
              builder: (contexto) => IconButton(
                tooltip: 'Filtros',
                icon: Badge(
                  isLabelVisible: _filtroClientes.quantidadeAtivos > 0,
                  label: Text('${_filtroClientes.quantidadeAtivos}'),
                  child: const Icon(Icons.filter_list, color: Colors.white),
                ),
                onPressed: () => _abrirFiltros(contexto),
              ),
            ),
            IconButton(
              tooltip: _buscaClientesAberta ? 'Fechar busca' : 'Buscar cliente',
              icon: Icon(
                _buscaClientesAberta ? Icons.close : Icons.search,
                color: Colors.white,
              ),
              onPressed: _alternarBuscaClientes,
            ),
          ],
        ),
        body: ClientList(
          usuario: widget.usuario,
          searchQuery: _consultaNomeCliente,
          filtro: _filtroClientes,
        ),
      ),
      TabDestination(
        appBar: CustomAppBar(
          title: 'Entregas',
          actions: [
            IconButton(
              tooltip: 'Filtrar entregas',
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () => _deliveryListKey.currentState?.abrirFiltros(),
            ),
          ],
        ),
        body: DeliveryList(key: _deliveryListKey),
      ),
      if (widget.usuario.isAdmin)
        TabDestination(
          appBar: CustomAppBar(title: 'Resumo'),
          body: ReportPage(usuario: widget.usuario),
        ),
    ];

    return BlocProvider<ClientListCubit>(
      create: (_) => getIt<ClientListCubit>()..ouvirClientes(widget.usuario),
      child: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, index, child) {
          final currentTab = destinations[index];

          return Scaffold(
            appBar: currentTab.appBar,
            body: currentTab.body,
            floatingActionButton: index == 2
                ? null
                : FloatingActionButton(
                    onPressed: () {
                      if (index == 0) {
                        context.push('/clients/new');
                      } else {
                        context.push('/deliveries/new');
                      }
                    },
                    tooltip: index == 0
                        ? 'Novo cliente'
                        : 'Nova entrega ou pagamento',
                    child: Icon(
                      index == 0
                          ? Icons.person_add_alt_1
                          : Icons.add_shopping_cart,
                    ),
                  ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            bottomNavigationBar: CustomBottomAppBar(
              selectedIndex: _selectedIndex,
              fabLocation: FloatingActionButtonLocation.endFloat,
              shape: null,
              showAdminTab: widget.usuario.isAdmin,
            ),
          );
        },
      ),
    );
  }
}

class TabDestination {
  final PreferredSizeWidget appBar;
  final Widget body;

  const TabDestination({required this.appBar, required this.body});
}
