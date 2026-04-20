import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/widgets/buttons/app_badge.dart';
import '../../../../shared/widgets/inputs/app_search_input.dart';
import '../../../../shared/widgets/layout/app_screen_header.dart';
import '../widgets/process_card.dart';

class ClientProcessListScreen extends StatefulWidget {
  const ClientProcessListScreen({super.key});

  @override
  State<ClientProcessListScreen> createState() => _ClientProcessListScreenState();
}

class _ClientProcessListScreenState extends State<ClientProcessListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppScreenHeader(title: 'Meus Processos'),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: AppSearchInput(hintText: 'Buscar pelo nome ou número...'),
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        ProcessCard(
          icon: Icons.gavel_outlined,
          title: 'Ação Indenizatória',
          processNumber: '0001234-56.2026',
          statusLabel: 'Em Análise',
          statusType: BadgeType.warning,
          statusMessage: 'Aguardando documentação',
          progressPercentage: 30,
          onTap: () => Navigator.pushNamed(context, '/process-timeline'),
        ),
        const SizedBox(height: 16),
        ProcessCard(
          icon: Icons.people_outline,
          title: 'Ação de Divórcio',
          processNumber: '0005678-12.2025',
          statusLabel: 'Concluído',
          statusType: BadgeType.success,
          statusMessage: 'Processo Arquivado',
          progressPercentage: 100,
          onTap: () {},
        ),
        const SizedBox(height: 16),
        ProcessCard(
          icon: Icons.work_outline,
          title: 'Reclamatória Trabalhista',
          processNumber: '0009876-90.2024',
          statusLabel: 'Andamento',
          statusType: BadgeType.primary,
          statusMessage: 'Audiência marcada: 15/05',
          progressPercentage: 65,
          onTap: () {},
        ),
      ],
    );
  }
}
