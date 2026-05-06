import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../app/routes/app_router.dart';
import '../../../../../../features/lawyer/leads/domain/entities/lead.dart';
import '../../../../../../features/lawyer/leads/presentation/lead_display.dart';
import '../../../../../../features/lawyer/leads/presentation/providers/lead_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/buttons/app_badge.dart';
import '../../../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';
import '../../../../../../shared/widgets/themis/themis_widgets.dart';

class LawyerLeadDetailScreen extends ConsumerStatefulWidget {
  final String? leadId;
  final String name;
  final String caseType;
  final String urgency;
  final bool isModal;

  const LawyerLeadDetailScreen({
    super.key,
    this.leadId,
    required this.name,
    required this.caseType,
    required this.urgency,
    this.isModal = false,
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
      body: Stack(
        children: [
          SafeArea(
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
                                  'Descrição',
                                  lead?.caseDescription?.isNotEmpty == true
                                      ? lead!.caseDescription!
                                      : 'Relato ainda não informado pelo bot.',
                                  isBold: false,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: widget.isModal
                                  ? 32
                                  : 140, // Padding reduzido em modal
                            ),
                          ],
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
      floatingActionButton: widget.isModal ? null : _buildFloatingActions(lead),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSliverAppBar(Lead? lead) {
    final rawName = lead?.displayName ?? widget.name;
    final name = _formatDisplayName(rawName);

    return SliverAppBar(
      expandedHeight: 125.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          widget.isModal
              ? Icons.close_rounded
              : Icons.arrow_back_ios_new_rounded,
          color: AppColors.ink,
          size: widget.isModal ? 24 : 18,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (!widget.isModal)
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.ink,
              size: 24,
            ),
            onPressed: () => _showDeleteConfirmationDialog(lead),
          ),
        IconButton(
          icon: const Icon(
            Icons.edit_note_rounded,
            color: AppColors.ink,
            size: 24,
          ),
          onPressed: () => _showEditLeadDialog(lead),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.fromLTRB(40, 20, 40, 14),
        title: Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.ink, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.h2.copyWith(
                  fontSize: 16,
                  color: AppColors.textPrimary,
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

  Widget _buildDetailItem(
    String label,
    String value, {
    bool isBadge = false,
    bool isBold = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 12,
              color: AppColors.textCaption,
            ),
          ),
          const SizedBox(height: 4),
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
              style: AppTextStyles.body.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
                height: 1.4,
              ),
              softWrap: true,
            ),
        ],
      ),
    );
  }

  Future<void> _convertLead(Lead? lead) async {
    final leadId = lead?.id ?? widget.leadId;
    if (leadId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ThemisAlertDialog(
        title: 'Converter Lead',
        message:
            'Deseja converter ${lead?.displayName ?? widget.name} em cliente?',
        confirmLabel: 'Converter',
        onCancel: () => Navigator.pop(context, false),
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      try {
        await ref.read(leadActionsProvider).convert(leadId);
        if (!mounted) return;

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sucesso!'),
            content: const Text('Cliente Convertido!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar à Fila'),
              ),
            ],
          ),
        );

        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao converter: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget? _buildFloatingActions(Lead? lead) {
    if (widget.leadId != null && lead == null) {
      return null;
    }

    return FloatingActionButton.extended(
      heroTag: 'lawyer_lead_detail_fab_${lead?.id ?? widget.leadId}',
      onPressed: () => _showActionsSheet(lead),
      backgroundColor: AppColors.yellow,
      foregroundColor: AppColors.ink,
      icon: const Icon(Icons.pending_actions_rounded),
      label: const Text('Ações'),
    );
  }

  void _showActionsSheet(Lead? lead) {
    final showArchiveAction = lead == null || lead.status == 'PENDING';

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            systemNavigationBarColor: AppColors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Row(
                    children: [
                      Text('Ações do Lead', style: AppTextStyles.h2),
                    ],
                  ),
                ),
                ThemisActionRow(
                  icon: Icons.check_circle_outline,
                  label: 'Converter em Cliente',
                  iconBackground: AppColors.primary.withValues(alpha: 0.1),
                  iconColor: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    _convertLead(lead);
                  },
                ),
                ThemisActionRow(
                  icon: Icons.support_agent_rounded,
                  label: 'Abrir Chat (Suporte)',
                  iconBackground: AppColors.yellowSoft,
                  iconColor: AppColors.yellowDeep,
                  onTap: () {
                    Navigator.pop(context);
                    final targetLead = lead;
                    if (targetLead != null) {
                      Navigator.pushNamed(
                        context,
                        AppRouter.lawyerChatHandoffRoute,
                        arguments: {
                          'clientName': targetLead.displayName,
                          'whatsappNumber': targetLead.whatsappNumber,
                        },
                      );
                    } else if (widget.leadId != null) {
                      Navigator.pushNamed(
                        context,
                        AppRouter.lawyerChatHandoffRoute,
                        arguments: {
                          'clientName': widget.name,
                          'whatsappNumber': '',
                        },
                      );
                    }
                  },
                ),
                if (showArchiveAction)
                  ThemisActionRow(
                    icon: Icons.archive_outlined,
                    label: 'Arquivar Lead',
                    iconBackground: AppColors.error.withValues(alpha: 0.1),
                    iconColor: AppColors.error,
                    onTap: () {
                      Navigator.pop(context);
                      _discardLead(lead);
                    },
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
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

  String _formatDisplayName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) return fullName;
    return '${parts.first} ${parts.last}';
  }

  void _showEditLeadDialog(Lead? lead) {
    if (lead == null) return;

    final nameController = TextEditingController(text: lead.name);
    final whatsappController = TextEditingController(text: lead.whatsappNumber);
    final cpfController = TextEditingController(text: lead.cpf);
    final descriptionController = TextEditingController(
      text: lead.caseDescription,
    );

    // Posiciona o cursor no final do texto em todos os campos
    nameController.selection = TextSelection.fromPosition(
      TextPosition(offset: nameController.text.length),
    );
    whatsappController.selection = TextSelection.fromPosition(
      TextPosition(offset: whatsappController.text.length),
    );
    cpfController.selection = TextSelection.fromPosition(
      TextPosition(offset: cpfController.text.length),
    );
    descriptionController.selection = TextSelection.fromPosition(
      TextPosition(offset: descriptionController.text.length),
    );

    String? selectedCaseType = lead.caseType;
    String? selectedUrgency = lead.urgency;
    String? selectedAvailability = lead.contactAvailability;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          systemNavigationBarColor: AppColors.background,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => StatefulBuilder(
            builder: (context, setState) => Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    // Handle fixo no topo do container
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          color: AppColors.line,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          CustomScrollView(
                            controller: scrollController,
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              SliverAppBar(
                                pinned: true,
                                automaticallyImplyLeading: false,
                                backgroundColor: AppColors.background,
                                surfaceTintColor: Colors.transparent,
                                elevation: 0,
                                expandedHeight: 100,
                                centerTitle: true,
                                actions: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: AppColors.ink,
                                        size: 26,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ],
                                flexibleSpace: FlexibleSpaceBar(
                                  centerTitle: true,
                                  titlePadding: const EdgeInsets.only(
                                    bottom: 16,
                                  ),
                                  title: Text(
                                    'Editar dados do lead',
                                    style: AppTextStyles.h2.copyWith(
                                      fontSize: 18,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  32,
                                  24,
                                  220,
                                ), // Top padding aumentado para 32
                                sliver: SliverList(
                                  delegate: SliverChildListDelegate([
                                    _buildEditField(
                                      controller: nameController,
                                      label: 'NOME COMPLETO',
                                    ),
                                    const SizedBox(height: 20),
                                    _buildEditField(
                                      controller: whatsappController,
                                      label: 'WHATSAPP',
                                      keyboardType: TextInputType.phone,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildEditField(
                                      controller: cpfController,
                                      label: 'CPF',
                                      keyboardType: TextInputType.number,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildEditDropdown(
                                      label: 'TIPO DE CASO',
                                      value: selectedCaseType,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'Labor',
                                          child: Text('Trabalhista'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Civil',
                                          child: Text('Cível'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Family',
                                          child: Text('Família'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Criminal',
                                          child: Text('Criminal'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'SocialSecurity',
                                          child: Text('Previdenciário'),
                                        ),
                                      ],
                                      onChanged: (v) =>
                                          setState(() => selectedCaseType = v),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildEditDropdown(
                                      label: 'URGÊNCIA',
                                      value: selectedUrgency,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'High',
                                          child: Text('Alta'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Medium',
                                          child: Text('Média'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Low',
                                          child: Text('Baixa'),
                                        ),
                                      ],
                                      onChanged: (v) =>
                                          setState(() => selectedUrgency = v),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildEditDropdown(
                                      label: 'DISPONIBILIDADE',
                                      value: selectedAvailability,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'Morning',
                                          child: Text('Manhã'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Afternoon',
                                          child: Text('Tarde'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Evening',
                                          child: Text('Noite'),
                                        ),
                                      ],
                                      onChanged: (v) => setState(
                                        () => selectedAvailability = v,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildEditField(
                                      controller: descriptionController,
                                      label: 'DESCRIÇÃO DO CASO',
                                      maxLines: 4,
                                    ),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                          // Área de rodapé sólida e rígida para cobrir a Navigation Bar do Android
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height:
                                  MediaQuery.of(context).padding.bottom +
                                  60, // Ajustado para sumir no meio do botão
                              color: AppColors.background,
                            ),
                          ),
                          // Botão Verdadeiramente Flutuante
                          Positioned(
                            bottom:
                                MediaQuery.of(context).padding.bottom +
                                32, // Aumentado para 32
                            left: 24,
                            right: 24,
                            child: PrimaryButton(
                              label: 'Salvar alterações',
                              isLoading: isSaving,
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      debugPrint(
                                        'LeadEdit: Iniciando salvamento do lead ${lead.id}',
                                      );
                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );
                                      final navigator = Navigator.of(context);
                                      setState(() => isSaving = true);
                                      try {
                                        final data = {
                                          'name': nameController.text,
                                          'cpf': cpfController.text,
                                          'caseType': selectedCaseType,
                                          'urgency': selectedUrgency,
                                          'contactAvailability':
                                              selectedAvailability,
                                          'caseDescription':
                                              descriptionController.text,
                                        };

                                        debugPrint(
                                          'LeadEdit: Enviando dados: $data',
                                        );

                                        await ref
                                            .read(leadActionsProvider)
                                            .update(lead.id, data);

                                        debugPrint(
                                          'LeadEdit: Sucesso ao atualizar',
                                        );

                                        if (mounted) {
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Dados do lead atualizados com sucesso!',
                                              ),
                                              backgroundColor: Colors.green,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              margin: EdgeInsets.fromLTRB(
                                                24,
                                                0,
                                                24,
                                                32,
                                              ),
                                            ),
                                          );
                                          navigator.pop();
                                        }
                                      } catch (e, stack) {
                                        debugPrint(
                                          'LeadEdit: Erro ao salvar: $e',
                                        );
                                        debugPrint(stack.toString());
                                        if (mounted) {
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Erro ao salvar: ${e.toString()}',
                                              ),
                                              backgroundColor: Colors.red,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              margin: const EdgeInsets.fromLTRB(
                                                24,
                                                0,
                                                24,
                                                32,
                                              ),
                                            ),
                                          );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() => isSaving = false);
                                        }
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.cap),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppTextStyles.body.copyWith(color: AppColors.ink),
          onTap: () {
            // Garante que o cursor vá para o final ao clicar
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.yellow, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.cap),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.yellow, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.ink3,
          ),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(Lead? lead) {
    if (lead == null && widget.leadId == null) return;

    final id = lead?.id ?? widget.leadId!;
    final name = lead?.displayName ?? widget.name;

    showDialog(
      context: context,
      builder: (context) => ThemisAlertDialog(
        title: 'Excluir Lead?',
        message:
            'Esta ação é irreversível. O lead "$name", todas as mensagens e a memória da IA serão apagados permanentemente.',
        confirmLabel: 'Excluir',
        isDestructive: true,
        onCancel: () => Navigator.pop(context),
        onConfirm: () async {
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);

          navigator.pop(); // Fecha o dialog

          try {
            // Mostra loading
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Excluindo lead permanentemente...'),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.fromLTRB(24, 0, 24, 32),
              ),
            );

            await ref.read(leadActionsProvider).deleteLead(id);

            if (mounted) {
              messenger.hideCurrentSnackBar();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Lead excluído com sucesso!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.fromLTRB(24, 0, 24, 32),
                ),
              );
              navigator.pop(); // Volta para a listagem
            }
          } catch (e) {
            if (mounted) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Erro ao excluir: $e'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
