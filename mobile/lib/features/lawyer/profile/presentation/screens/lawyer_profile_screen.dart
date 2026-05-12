import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../../../../features/auth/domain/entities/account.dart';
import '../../../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../../../shared/constants/app_colors.dart';
import '../../../../../../shared/constants/app_dimensions.dart';
import '../../../../../../shared/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/app_app_bar_actions.dart';
import '../../../../../../shared/widgets/cards/app_card.dart';
import '../../../../../../app/routes/app_router.dart';
import '../../../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../../../shared/widgets/layout/lawyer_main_layout.dart';
import '../../../../../../shared/widgets/layout/loading_skeleton.dart';
import '../../../../../../shared/utils/string_utils.dart';

class LawyerProfileScreen extends ConsumerStatefulWidget {
  const LawyerProfileScreen({super.key});

  @override
  ConsumerState<LawyerProfileScreen> createState() =>
      _LawyerProfileScreenState();
}

class _LawyerProfileScreenState extends ConsumerState<LawyerProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isUploading = false;

  late final AnimationController _animController;
  late final Animation<Offset> _sheetSlide;
  late final Animation<double> _sheetFade;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  ValueNotifier<int>? _tabNotifier;
  int _profileIndex = LawyerMainLayoutState.profileIndex;

  static const _headerHeight = 180.0;
  static const _sheetOverlap = 50.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _sheetSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
          ),
        );

    _sheetFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _contentFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _animController.forward();
    });
  }

  void _onScroll() {
    _scrollOffset.value = _scrollController.offset;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final layout = context.findAncestorStateOfType<LawyerMainLayoutState>();
    final notifier = layout?.currentIndexNotifier;
    final isAdmin =
        ref.read(authControllerProvider).valueOrNull?.account?.role.isAdmin ??
        false;
    _profileIndex =
        layout?.profileIndexFor(isAdmin) ?? LawyerMainLayoutState.profileIndex;
    if (notifier == _tabNotifier) return;
    _tabNotifier?.removeListener(_onTabChanged);
    _tabNotifier = notifier;
    _tabNotifier?.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!mounted) return;
    if (_tabNotifier?.value == _profileIndex) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _tabNotifier?.removeListener(_onTabChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollOffset.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(currentAccountProvider);
    final cachedAccount = account.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.yellow,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: 'Perfil',
        showBackButton: false,
        showDivider: false,
        backgroundColor: Colors.transparent,
        actions: [
          AppAppBarActions(showChat: false, badgeColor: AppColors.white),
        ],
      ),
      body: cachedAccount != null
          ? _buildBody(cachedAccount)
          : account.when(
              data: _buildBody,
              loading: () => Container(
                color: AppColors.background,
                padding: const EdgeInsets.all(24),
                child: const LoadingSkeleton(height: 260, borderRadius: 16),
              ),
              error: (error, _) => Container(
                color: AppColors.background,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.error),
                ),
              ),
            ),
    );
  }

  Widget _buildBody(Account account) {
    final topInset = MediaQuery.of(context).padding.top;
    final sheetTopMin = topInset + kToolbarHeight + 8;
    final sheetTopMax = _headerHeight - _sheetOverlap;
    final maxCollapse = (sheetTopMax - sheetTopMin).clamp(0.0, double.infinity);

    return Stack(
      children: [
        _buildGradientHeader(),
        ValueListenableBuilder<double>(
          valueListenable: _scrollOffset,
          builder: (context, offset, child) {
            final collapse = offset.clamp(0.0, maxCollapse);
            return Padding(
              padding: EdgeInsets.only(top: sheetTopMax - collapse),
              child: child,
            );
          },
          child: SlideTransition(
            position: _sheetSlide,
            child: FadeTransition(
              opacity: _sheetFade,
              child: _buildSheet(account),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientHeader() {
    return Container(
      height: _headerHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.yellow2, AppColors.yellow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildSheet(Account account) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: SingleChildScrollView(
          controller: _scrollController,
          key: const PageStorageKey<String>('lawyer-profile-scroll'),
          padding: EdgeInsets.fromLTRB(
            20,
            22,
            20,
            AppDimensions.bottomPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIdentityRow(account),
              const SizedBox(height: 22),
              FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: _buildOverviewContent(account),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityRow(Account account) {
    final initial = StringUtils.getInitials(account.name);
    final avatarUrl = account.avatarUrl;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Tooltip(
          message: 'Alterar foto',
          child: GestureDetector(
            onTap: _isUploading ? null : () => _pickAndUploadAvatar(context),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.surface, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? Image.network(avatarUrl, fit: BoxFit.cover)
                        : Container(
                            color: AppColors.yellow,
                            alignment: Alignment.center,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                  ),
                ),
                if (_isUploading)
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.yellow,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 12,
                      color: AppColors.yellow,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.name,
                style: AppTextStyles.h1.copyWith(fontSize: 22, height: 1.15),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.yellowSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Advogado',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.yellowDeep,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewContent(Account account) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Dados da Conta'),
        _buildSection(
          children: [
            _buildInfoTile(Icons.person_outline_rounded, 'Nome', account.name),
            _buildInfoTile(
              Icons.fingerprint_rounded,
              'CPF',
              account.cpf?.isNotEmpty == true ? account.cpf! : 'Não informado',
            ),
            _buildInfoTile(
              Icons.email_outlined,
              'E-mail',
              account.email?.isNotEmpty == true
                  ? account.email!
                  : 'Não informado',
            ),
            _buildInfoTile(
              Icons.phone_android_rounded,
              'WhatsApp',
              account.whatsappNumber.isNotEmpty
                  ? account.whatsappNumber
                  : 'Não informado',
            ),
          ],
        ),
        const SizedBox(height: 20),
        _sectionTitle('Atendimento'),
        _buildSection(
          children: [
            _buildActionTile(
              Icons.chat_bubble_outline_rounded,
              'Mensagens e Handoffs',
              () => Navigator.pushNamed(context, '/lawyer-chats'),
            ),
            _buildActionTile(
              Icons.smart_toy_rounded,
              'Assistente IA Themis',
              () =>
                  Navigator.pushNamed(context, AppRouter.lawyerAIManagerRoute),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _sectionTitle('Notificações'),
        _buildSection(
          children: [
            _buildPreferenceTile(
              title: 'Leads',
              value: account.notificationPreferences['leads'] ?? true,
              onChanged: (v) => _updatePreference(context, account, 'leads', v),
            ),
            _buildPreferenceTile(
              title: 'Trâmites',
              value: account.notificationPreferences['processUpdates'] ?? true,
              onChanged: (v) =>
                  _updatePreference(context, account, 'processUpdates', v),
            ),
            _buildPreferenceTile(
              title: 'Arquivos',
              value: account.notificationPreferences['documents'] ?? true,
              onChanged: (v) =>
                  _updatePreference(context, account, 'documents', v),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _sectionTitle('Conta'),
        _buildSection(
          children: [
            _buildActionTile(
              Icons.logout_rounded,
              'Sair da Conta',
              () => _showLogoutDialog(context),
              isDestructive: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text,
        style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.ink),
      ),
    );
  }

  Widget _buildSection({required List<Widget> children}) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(children.length, (index) {
          return Column(
            children: [
              children[index],
              if (index < children.length - 1)
                const Divider(height: 1, indent: 60, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.ink, size: 20),
      ),
      title: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          fontSize: 11.5,
          color: AppColors.textCaption,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      activeThumbColor: AppColors.ink,
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive ? AppColors.errorBackground : AppColors.surface2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.ink,
          size: 20,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: AppColors.textCaption,
      ),
      onTap: onTap,
    );
  }

  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'heic', 'heif'],
      withData: false,
    );
    final file = result?.files.single;
    if (file == null || file.path == null) return;

    final croppedFile = await _cropImage(file.path!);
    if (croppedFile == null) return;

    setState(() => _isUploading = true);
    try {
      await ref
          .read(accountActionsProvider)
          .uploadAvatar(filePath: croppedFile.path, fileName: file.name);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil atualizada.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<CroppedFile?> _cropImage(String path) async {
    return await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ajustar imagem',
          toolbarColor: AppColors.background,
          toolbarWidgetColor: AppColors.ink,
          activeControlsWidgetColor: AppColors.yellow,
          statusBarLight: true,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: 'Ajustar imagem',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
  }

  Future<void> _updatePreference(
    BuildContext context,
    Account account,
    String key,
    bool value,
  ) async {
    final updated = Map<String, bool>.from(account.notificationPreferences)
      ..[key] = value;
    final optimisticAccount = Account(
      id: account.id,
      name: account.name,
      whatsappNumber: account.whatsappNumber,
      role: account.role,
      cpf: account.cpf,
      email: account.email,
      avatarUrl: account.avatarUrl,
      notificationPreferences: updated,
      teamPermissions: account.teamPermissions,
      lawyerAdminId: account.lawyerAdminId,
      mustChangePassword: account.mustChangePassword,
    );

    ref
        .read(authControllerProvider.notifier)
        .updateSessionAccount(optimisticAccount);

    try {
      await ref
          .read(accountActionsProvider)
          .updateNotificationPreferences(updated);
    } catch (error) {
      ref.read(authControllerProvider.notifier).updateSessionAccount(account);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sair da Conta'),
        content: const Text('Tem certeza que deseja sair do aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textCaption),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authControllerProvider.notifier).logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text(
              'Sair',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
