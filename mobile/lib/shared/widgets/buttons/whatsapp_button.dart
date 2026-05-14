import 'package:flutter/material.dart';

import '../../constants/app_text_styles.dart';

/// CTA padrao para acoes que abrem conversa no WhatsApp.
///
/// Verde solido (0xFF25D366), pill arredondado, icone de bolha + texto branco.
/// Mantem identidade visual unificada entre cliente e advogado.
class WhatsAppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  const WhatsAppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.chat_bubble_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: const Color(0xFF25D366),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
