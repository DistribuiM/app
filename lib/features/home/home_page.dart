import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../clients/client_list.dart';
import '../../core/widgets/custom_appbar.dart';
import '../../core/widgets/custom_bottom_appbar.dart';
import '../deliveries/delivery_list.dart';
import '../clients/client_form.dart';
import '../deliveries/delivery_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.user});

  final User user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _selectedIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<TabDestination> destinations = [
      TabDestination(
        appBar: CustomAppBar(title: 'Clientes'),
        body: ClientList(),
      ),
      TabDestination(
        appBar: CustomAppBar(title: 'Entregas'),
        body: DeliveryList(),
      )
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
              if (_selectedIndex.value == 0) { // Ta na aba de clientes
                // _clientKey.currentState?.adicionarCliente();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClientForm(),
                  ),
                );
                
              } else if (_selectedIndex.value == 1) { // Aba de entregas
                // _deliveryKey.currentState?.adicionarEntrega();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeliveryForm(),
                  ),
                );
              }
            },
            tooltip: 'Formulário',
            shape: const CircleBorder(),
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: CustomBottomAppBar(
            selectedIndex: _selectedIndex,
            fabLocation: FloatingActionButtonLocation.centerDocked,
            shape:  const CircularNotchedRectangle(),
          ),
        );
      }
    );
  }
}

class TabDestination {
  final PreferredSizeWidget appBar;
  final Widget body;

  const TabDestination({
    required this.appBar,
    required this.body,
  });
}