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
          NavItem(icon: Icons.grid_view_rounded, label: 'Início', size: 25),
          NavItem(
            icon: Icons.business_center_rounded,
            label: 'Trâmites',
            size: 27,
            offsetY: -1.0,
          ),
          NavItem(icon: Icons.description_rounded, label: 'Arquivos', size: 24),
          NavItem(
            icon: Icons.chat_rounded,
            label: 'Chat',
            size: 24,
            offsetY: 1.0,
          ),
          NavItem(icon: Icons.person_rounded, label: 'Perfil', size: 25),
        ];

    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        13,
      ), // Reduzido de 18 para 13 (-5px para descer)
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
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

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(
          vertical: 2,
          horizontal: 4,
        ), // Pequeno respiro na bolha ativa

        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 200),
              tween: Tween(begin: 1.0, end: isSelected ? 1.2 : 1.0),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Transform.translate(
                    offset: Offset(0, item.offsetY ?? 0),
                    child: Icon(item.icon, color: color, size: item.size ?? 24),
                  ),
                );
              },
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: isSelected
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 14,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Text(
                                item.label,
                                softWrap: false,
                                maxLines: 1,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
