import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';

class NicheChart extends StatefulWidget {
  const NicheChart({super.key});

  @override
  State<NicheChart> createState() => _NicheChartState();
}

class _NicheChartState extends State<NicheChart> {
  int _selectedIndex = -1;

  final List<Map<String, dynamic>> _data = [
    {'label': 'Cível', 'percentage': 0.85, 'count': 42, 'color': AppColors.primary},
    {'label': 'Trab.', 'percentage': 0.65, 'count': 28, 'color': AppColors.secondaryLight},
    {'label': 'Fam.', 'percentage': 0.45, 'count': 15, 'color': AppColors.secondaryDark},
    {'label': 'Cons.', 'percentage': 0.35, 'count': 12, 'color': const Color(0xFF9E9E9E)},
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Casos por Nicho',
                style: AppTextStyles.h2.copyWith(fontSize: 16),
              ),
              if (_selectedIndex != -1)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _data[_selectedIndex]['color'].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_data[_selectedIndex]['count']} processos',
                      style: TextStyle(
                        color: _data[_selectedIndex]['color'],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_data.length, (index) {
                return _buildBar(index);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(int index) {
    final item = _data[index];
    final isSelected = _selectedIndex == index;
    final color = item['color'] as Color;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = isSelected ? -1 : index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            width: 44,
            height: 120 * (item['percentage'] as double),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  isSelected ? color : color.withValues(alpha: 0.9),
                  color.withValues(alpha: 0.6),
                ],
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
          const SizedBox(height: 12),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: AppTextStyles.caption.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? color : AppColors.textCaption,
              fontSize: 12,
            ),
            child: Text(item['label']),
          ),
        ],
      ),
    );
  }
}
