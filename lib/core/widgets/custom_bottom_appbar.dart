import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  const CustomBottomAppBar({
    super.key,
    required this.selectedIndex,
    this.fabLocation = FloatingActionButtonLocation.centerDocked,
    this.shape = const CircularNotchedRectangle(),
  });

  final ValueNotifier<int> selectedIndex;
  final FloatingActionButtonLocation fabLocation;
  final NotchedShape? shape;

  static final List<FloatingActionButtonLocation> centerLocations =
    <FloatingActionButtonLocation>[
      FloatingActionButtonLocation.centerDocked,
      FloatingActionButtonLocation.centerFloat,
    ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndex,
      builder: (context, activeIndex, child) {
        return BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          shape: shape,
          color: Theme.of(context).colorScheme.primary,
          child: IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            child: Row(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      constraints: const BoxConstraints(),
                      tooltip: 'Clientes',
                      icon: const Icon(Icons.groups),
                      color: activeIndex == 0 ? Colors.white : Colors.white70,
                      onPressed: () => selectedIndex.value = 0,
                    ),
                    const Text(
                      "Clientes",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
                if (centerLocations.contains(fabLocation)) const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      constraints: const BoxConstraints(),
                      tooltip: 'Entregas',
                      icon: const Icon(Icons.local_shipping),
                      color: activeIndex == 1 ? Colors.white : Colors.white70,
                      onPressed: () => selectedIndex.value = 1,
                    ),
                    const Text(
                      "Entregas",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }
}