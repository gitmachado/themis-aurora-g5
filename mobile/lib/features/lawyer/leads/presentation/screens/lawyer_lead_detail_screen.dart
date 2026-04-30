import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../features/lawyer/leads/domain/entities/lead.dart';
import '../../../../../../features/lawyer/leads/presentation/lead_display.dart';
import '../../../../../../features/lawyer/leads/presentation/providers/lead_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/buttons/app_badge.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';

class LawyerLeadDetailScreen extends ConsumerStatefulWidget {
  final String? leadId;
  final String name;
  final String caseType;
  final String urgency;

  const LawyerLeadDetailScreen({
    super.key,
    this.leadId,
    required this.name,
    required this.caseType,
    required this.urgency,
  });

  @override
  ConsumerState<LawyerLeadDetailScreen> createState() =>
      _LawyerLeadDetailScreenState();
}

class _LawyerLeadDetailScreenState extends ConsumerState<LawyerLeadDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leadAsync = widget.leadId == null
        ? null
        : ref.watch(leadDetailsProvider(widget.leadId!));
    final lead = leadAsync?.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false, // SliverAppBar handles top safe area
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(lead),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (leadAsync?.isLoading ?? false) ...[
                          const LoadingSkeleton(height: 4, borderRadius: 2),
                          const SizedBox(height: 16),
                        ],
                        _buildInfoSection(
                          title: 'Dados do Lead',
                          icon: Icons.person_search_outlined,
                          children: [
                            _buildDetailItem(
                              'Nome Completo',
                              lead?.displayName ?? widget.name,
                            ),
                            _buildDetailItem(
                              'WhatsApp',
                              lead?.whatsappNumber ?? '--',
                            ),
                            _buildDetailItem('CPF', lead?.cpf ?? '--'),
                            _buildDetailItem(
                              'Tipo de Caso',
                              lead?.caseTypeLabel ?? widget.caseType,
                            ),
                            _buildDetailItem(
                              'Urgencia',
                              lead?.urgencyLabel ?? widget.urgency,
                              isBadge: true,
                            ),
                            _buildDetailItem(
                              'Disponibilidade',
                              lead?.availabilityLabel ?? '--',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildInfoSection(
                          title: 'Relato do Caso',
                          icon: Icons.description_outlined,
                          children: [
                            Text(
                              lead?.caseDescription?.isNotEmpty == true
                                  ? lead!.caseDescription!
                                  : 'Relato ainda nao informado pelo bot.',
                              style: AppTextStyles.body.copyWith(height: 1.5),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 120,
                        ), // Bottom padding for sticky button
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildStickyFooter(lead),
    );
  }

  Widget _buildSliverAppBar(Lead? lead) {
    final name = lead?.displayName ?? widget.name;

    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 22,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary, Color(0xFF3949AB)],
            ),
          ),
          child: Center(
            child: Hero(
              tag: 'avatar_${widget.name}',
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.h2.copyWith(
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isBadge = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 14)),
          if (isBadge)
            AppBadge(
              label: value.toUpperCase(),
              type: value.toUpperCase() == 'ALTA'
                  ? BadgeType.error
                  : BadgeType.primary,
            )
          else
            Text(
              value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter(Lead? lead) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border(
          top: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _discardLead(lead),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Arquivar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showConversionDialog(lead),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Converter',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _discardLead(Lead? lead) async {
    final leadId = lead?.id ?? widget.leadId;
    if (leadId == null || leadId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel arquivar: lead sem ID real.'),
        ),
      );
      return;
    }

    await ref
        .read(leadActionsProvider)
        .discard(leadId, reason: 'Arquivado no app mobile');
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _showConversionDialog(Lead? lead) {
    final leadId = lead?.id ?? widget.leadId;
    if (leadId == null || leadId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel converter: lead sem ID real.'),
        ),
      );
      return;
    }

    final name = lead?.displayName ?? widget.name;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.success,
                  size: 64,
                ),
                const SizedBox(height: 24),
                const Text('Confirmar Conversão', style: AppTextStyles.h1),
                const SizedBox(height: 16),
                Text(
                  'Ao converter $name, um novo usuario sera criado. O cliente recebera os dados de acesso via WhatsApp.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textCaption,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context); // Close sheet
                    await ref.read(leadActionsProvider).convert(leadId);
                    if (!mounted) return;
                    _showSuccessAnimation();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sim, Converter Agora',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.textCaption),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 80,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Cliente Convertido!', style: AppTextStyles.h1),
            const SizedBox(height: 12),
            const Text(
              'O processo foi criado com sucesso.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to list
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Voltar à Fila',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
