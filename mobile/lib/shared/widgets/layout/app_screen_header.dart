import 'package:flutter/material.dart';

import '../../constants/app_text_styles.dart';

class AppScreenHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  const AppScreenHeader({
    super.key,
    required this.title,
    this.action,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 0),
  });

  @override
  Widget build(BuildContext context) {
    final actionWidget = action;
    return Container(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.h1.copyWith(fontSize: 24),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          actionWidget ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
