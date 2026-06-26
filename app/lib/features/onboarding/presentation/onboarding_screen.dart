import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../profile/data/profile_repository.dart';
import '../../profile/presentation/widgets/avatar_widget.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  final _displayNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();

  String? _avatarUrl;
  bool _uploadingAvatar = false;
  bool _saving = false;
  String? _error;
  bool _usernameEdited = false;
  int _page = 0;

  static final _usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');

  @override
  void initState() {
    super.initState();
    // Pré-preenche com o username gerado pelo trigger
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(myProfileProvider).valueOrNull;
      if (profile != null) {
        _usernameCtrl.text = profile.username;
      }
    });
    _displayNameCtrl.addListener(_onDisplayNameChanged);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _displayNameCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  void _onDisplayNameChanged() {
    if (_usernameEdited) return;
    final raw = _displayNameCtrl.text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    _usernameCtrl.text = raw;
  }

  String? _validateStep1() {
    final name = _displayNameCtrl.text.trim();
    final user = _usernameCtrl.text.trim();
    if (name.length < 2) return 'Nome deve ter ao menos 2 caracteres.';
    if (user.length < 3) return 'Username deve ter ao menos 3 caracteres.';
    if (!_usernameRegex.hasMatch(user)) {
      return 'Username só pode ter letras, números e _.';
    }
    return null;
  }

  void _nextPage() {
    final err = _validateStep1();
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() => _error = null);
    _pageCtrl.animateToPage(
      1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    _pageCtrl.animateToPage(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _pickAvatar() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image == null) return;
    setState(() => _uploadingAvatar = true);
    try {
      final bytes = await image.readAsBytes();
      final ext = image.path.split('.').last.toLowerCase();
      final url = await ref
          .read(profileRepositoryProvider)
          .uploadAvatar(bytes, ext.isEmpty ? 'jpg' : ext);
      setState(() => _avatarUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar foto: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _finish() async {
    setState(() { _saving = true; _error = null; });
    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.updateProfile(
        username: _usernameCtrl.text.trim(),
        displayName: _displayNameCtrl.text.trim(),
        avatarUrl: _avatarUrl,
      );
      await repo.completeOnboarding();
      ref.invalidate(onboardingNeededProvider);
      ref.invalidate(myProfileProvider);
      if (mounted) context.go('/');
    } catch (e) {
      setState(() { _saving = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final amber = scheme.primary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: SafeArea(
          child: PageView(
            controller: _pageCtrl,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (p) => setState(() => _page = p),
            children: [
              _Step1(
                amber: amber,
                scheme: scheme,
                displayNameCtrl: _displayNameCtrl,
                usernameCtrl: _usernameCtrl,
                error: _error,
                onUsernameEdited: () => setState(() => _usernameEdited = true),
                onNext: _nextPage,
                page: _page,
              ),
              _Step2(
                amber: amber,
                scheme: scheme,
                avatarUrl: _avatarUrl,
                uploading: _uploadingAvatar,
                saving: _saving,
                error: _error,
                onPickAvatar: _pickAvatar,
                onBack: _prevPage,
                onFinish: _finish,
                page: _page,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step 1: Nome e username ──────────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  const _Step1({
    required this.amber,
    required this.scheme,
    required this.displayNameCtrl,
    required this.usernameCtrl,
    required this.error,
    required this.onUsernameEdited,
    required this.onNext,
    required this.page,
  });

  final Color amber;
  final ColorScheme scheme;
  final TextEditingController displayNameCtrl;
  final TextEditingController usernameCtrl;
  final String? error;
  final VoidCallback onUsernameEdited;
  final VoidCallback onNext;
  final int page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone com glow de bar
          Center(
            child: _BarGlowIcon(amber: amber),
          ),
          const SizedBox(height: 32),

          Text(
            'Bom te ver\npor aqui.',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1.1,
              color: scheme.onSurface,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Como quer ser conhecido na comunidade?',
            style: TextStyle(
              fontSize: 15,
              color: scheme.onSurface.withAlpha(160),
            ),
          ),
          const SizedBox(height: 32),

          TextField(
            controller: displayNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nome de exibição',
              hintText: 'Ex: Rafael Barman',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: usernameCtrl,
            decoration: const InputDecoration(
              labelText: 'Username',
              hintText: 'seu_username',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.alternate_email),
              helperText: 'Letras, números e _. Mínimo 3 caracteres.',
            ),
            textInputAction: TextInputAction.done,
            onChanged: (_) => onUsernameEdited(),
            onSubmitted: (_) => onNext(),
          ),

          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                error!,
                style: TextStyle(color: scheme.error, fontSize: 13),
              ),
            ),

          const Spacer(),

          _StepDots(current: 0, scheme: scheme, amber: amber),
          const SizedBox(height: 16),

          FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Continuar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Avatar ───────────────────────────────────────────────────────────

class _Step2 extends ConsumerWidget {
  const _Step2({
    required this.amber,
    required this.scheme,
    required this.avatarUrl,
    required this.uploading,
    required this.saving,
    required this.error,
    required this.onPickAvatar,
    required this.onBack,
    required this.onFinish,
    required this.page,
  });

  final Color amber;
  final ColorScheme scheme;
  final String? avatarUrl;
  final bool uploading;
  final bool saving;
  final String? error;
  final VoidCallback onPickAvatar;
  final VoidCallback onBack;
  final VoidCallback onFinish;
  final int page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final profile = profileAsync.valueOrNull;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 24),

          // Avatar com overlay de câmera
          Center(
            child: GestureDetector(
              onTap: uploading ? null : onPickAvatar,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: amber.withAlpha(60),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: avatarUrl != null
                        ? CircleAvatar(
                            radius: 72,
                            backgroundImage: NetworkImage(avatarUrl!),
                          )
                        : profile != null
                            ? AvatarWidget(profile: profile, radius: 72)
                            : CircleAvatar(
                                radius: 72,
                                backgroundColor:
                                    scheme.surfaceContainerHighest,
                                child: Icon(Icons.person,
                                    size: 56,
                                    color: scheme.onSurface.withAlpha(100)),
                              ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: amber,
                      child: uploading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black),
                            )
                          : const Icon(Icons.camera_alt,
                              size: 20, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          Text(
            'Seu rosto na\ncomunidade.',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1.1,
              color: scheme.onSurface,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Uma foto ajuda outros mixologistas a te encontrar.',
            style: TextStyle(
              fontSize: 15,
              color: scheme.onSurface.withAlpha(160),
            ),
          ),

          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                error!,
                style: TextStyle(color: scheme.error, fontSize: 13),
              ),
            ),

          const Spacer(),

          _StepDots(current: 1, scheme: scheme, amber: amber),
          const SizedBox(height: 16),

          FilledButton(
            onPressed: (saving || uploading) ? null : onFinish,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black))
                : const Text('Começar!',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: (saving || uploading) ? null : onFinish,
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
            child: Text(
              'Pular por agora',
              style: TextStyle(color: scheme.onSurface.withAlpha(130)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ───────────────────────────────────────────────────────

class _BarGlowIcon extends StatelessWidget {
  const _BarGlowIcon({required this.amber});
  final Color amber;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow externo — luz de bar
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  amber.withAlpha(70),
                  amber.withAlpha(25),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          // Ícone central
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: amber.withAlpha(20),
              border: Border.all(color: amber.withAlpha(80), width: 1.5),
            ),
            child: Icon(Icons.local_bar, size: 40, color: amber),
          ),
        ],
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({
    required this.current,
    required this.scheme,
    required this.amber,
  });

  final int current;
  final ColorScheme scheme;
  final Color amber;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: active ? amber : scheme.onSurface.withAlpha(50),
          ),
        );
      }),
    );
  }
}
