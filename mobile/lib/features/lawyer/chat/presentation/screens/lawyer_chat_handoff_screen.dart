import 'package:flutter/material.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';

class LawyerChatHandoffScreen extends StatefulWidget {
  final String clientName;
  const LawyerChatHandoffScreen({super.key, required this.clientName});

  @override
  State<LawyerChatHandoffScreen> createState() => _LawyerChatHandoffScreenState();
}

class _LawyerChatHandoffScreenState extends State<LawyerChatHandoffScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'sender': 'CLIENT', 'text': 'Olá, gostaria de saber o status do meu processo.', 'time': '10:00'},
    {'sender': 'BOT', 'text': 'Olá! Sou o assistente jurídico. Vou verificar para você. Qual o seu CPF?', 'time': '10:00'},
    {'sender': 'CLIENT', 'text': '123.456.789-00', 'time': '10:01'},
    {'sender': 'BOT', 'text': 'Obrigado. Seu processo está em fase de citação. Deseja falar com um advogado?', 'time': '10:01'},
    {'sender': 'CLIENT', 'text': 'Sim, por favor. Tenho uma dúvida sobre a última petição.', 'time': '10:02'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: widget.clientName,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHandoffBanner(),
          Expanded(child: _buildChatList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHandoffBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: AppColors.warningOverlay,
      child: Row(
        children: [
          const Icon(Icons.pause_circle_outline_rounded, color: AppColors.warning, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Você assumiu esta conversa. O Bot está em pausa.',
              style: TextStyle(color: AppColors.warning, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: AppColors.warning.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Reativar Bot', 
              style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final m = _messages[index];
        return _buildChatBubble(m);
      },
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> m) {
    final isClient = m['sender'] == 'CLIENT';
    final isBot = m['sender'] == 'BOT';
    final isLawyer = m['sender'] == 'LAWYER';

    return Align(
      alignment: isClient ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isClient 
              ? AppColors.surface 
              : (isBot ? AppColors.primaryOverlay : AppColors.primary),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isClient ? 0 : 16),
            bottomRight: Radius.circular(isClient ? 16 : 0),
          ),
          boxShadow: isClient ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : null,
          border: isClient ? Border.all(color: AppColors.divider) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isBot)
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'ASSISTENTE IA', 
                  style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.w800, 
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            Text(
              m['text'],
              style: TextStyle(
                color: (isLawyer) ? Colors.white : AppColors.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                m['time'],
                style: TextStyle(
                  color: isLawyer ? Colors.white.withValues(alpha: 0.7) : AppColors.textCaption,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary)),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Escreva uma mensagem...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  setState(() {
                    _messages.add({
                      'sender': 'LAWYER',
                      'text': _messageController.text,
                      'time': 'Agora',
                    });
                    _messageController.clear();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
