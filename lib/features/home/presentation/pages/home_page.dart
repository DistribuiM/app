import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/domain/entities/usuario.dart';
import '../../../clients/presentation/pages/client_list.dart';
import '../../../../core/widgets/custom_appbar.dart';
import '../../../../core/widgets/custom_bottom_appbar.dart';
import '../../../deliveries/presentation/pages/delivery_list.dart';

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
        body: ClientList(searchQuery: _consultaNomeCliente),
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
    ];

    return ValueListenableBuilder<int>(
      valueListenable: _selectedIndex,
      builder: (context, index, child) {
        final currentTab = destinations[index];

        return Scaffold(
          appBar: currentTab.appBar,
          body: currentTab.body,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (index == 0) {
                context.push('/clients/new');
              } else {
                context.push('/deliveries/new');
              }
            },
            tooltip: index == 0 ? 'Novo cliente' : 'Nova entrega ou pagamento',
            child: Icon(
              index == 0 ? Icons.person_add_alt_1 : Icons.add_shopping_cart,
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: CustomBottomAppBar(
            selectedIndex: _selectedIndex,
            fabLocation: FloatingActionButtonLocation.endFloat,
            shape: null,
          ),
        );
      },
    );
  }
}

class TabDestination {
  final PreferredSizeWidget appBar;
  final Widget body;

  const TabDestination({required this.appBar, required this.body});
}
