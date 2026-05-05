import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class NavItem {
  final IconData icon;
  final String label;
  final double? size;
  final double? offsetY;

  const NavItem({
    required this.icon,
    required this.label,
    this.size,
    this.offsetY,
  });
}

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem>? items;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items,
  });

  @override
  Widget build(BuildContext context) {
    final navItems =
        items ??
        const [
          NavItem(icon: Icons.grid_view_rounded, label: 'Início', size: 28),
          NavItem(
            icon: Icons.folder_rounded,
            label: 'Processos',
            size: 30,
            offsetY: -1.0,
          ),
          NavItem(
            icon: Icons.description_rounded,
            label: 'Documentos',
            size: 28,
          ),
          NavItem(
            icon: Icons.chat_rounded,
            label: 'Chat',
            size: 28,
            offsetY: 1.0,
          ),
          NavItem(icon: Icons.person_rounded, label: 'Perfil', size: 28),
        ];

    return Container(
      height: 98,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.line2, width: 1)),
      ),
      child: Padding(
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(navItems.length, (index) {
            final isSelected = currentIndex == index;
            return Expanded(
              child: _NavBarItemWidget(
                item: navItems[index],
                isSelected: isSelected,
                onTap: () => onTap(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavBarItemWidget extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textCaption;
    final iconSize = (item.size ?? 28).clamp(24, 30).toDouble();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 76,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.yellow : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 4),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 200),
              tween: Tween(begin: 1.0, end: 1.0),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Transform.translate(
                    offset: Offset(0, item.offsetY ?? 0),
                    child: Icon(item.icon, color: color, size: iconSize),
                  ),
                );
              },
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 16,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          item.label,
                          softWrap: false,
                          maxLines: 1,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
