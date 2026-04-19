import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';

class DocumentFilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const DocumentFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['Todos', 'Solicitados', 'Enviados'];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return ChoiceChip(
            label: Text(
              filter,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textCaption,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => onFilterChanged(filter),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
