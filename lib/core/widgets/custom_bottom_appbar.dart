import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  const CustomBottomAppBar({
    super.key,
    required this.selectedIndex,
    this.fabLocation = FloatingActionButtonLocation.centerDocked,
    this.shape = const CircularNotchedRectangle(),
    this.showAdminTab = false,
  });

  final ValueNotifier<int> selectedIndex;
  final FloatingActionButtonLocation fabLocation;
  final NotchedShape? shape;
  final bool showAdminTab;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Clientes',
                    icon: Icons.groups,
                    isSelected: activeIndex == 0,
                    onTap: () => selectedIndex.value = 0,
                  ),
                ),
                if (!showAdminTab &&
                    centerLocations.contains(fabLocation))
                  const Spacer(),
                Expanded(
                  child: _TabButton(
                    label: 'Entregas',
                    icon: Icons.local_shipping,
                    isSelected: activeIndex == 1,
                    onTap: () => selectedIndex.value = 1,
                  ),
                ),
                if (showAdminTab)
                  Expanded(
                    child: _TabButton(
                      label: 'Resumo',
                      icon: Icons.bar_chart,
                      isSelected: activeIndex == 2,
                      onTap: () => selectedIndex.value = 2,
                    ),
                  ),
              ],
            ),
          ),
        );
      }
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white70,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
