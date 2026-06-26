import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../data/profile_model.dart';
import '../data/profile_repository.dart';
import 'widgets/avatar_widget.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _displayNameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _pronounsCtrl;
  late final TextEditingController _bioCtrl;

  late String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _displayNameCtrl = TextEditingController(text: widget.profile.displayName ?? '');
    _usernameCtrl = TextEditingController(text: widget.profile.username);
    _nicknameCtrl = TextEditingController(text: widget.profile.nickname ?? '');
    _pronounsCtrl = TextEditingController(text: widget.profile.pronouns ?? '');
    _bioCtrl = TextEditingController(text: widget.profile.bio ?? '');
    _avatarUrl = widget.profile.avatarUrl;
  }
  bool _uploadingAvatar = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _usernameCtrl.dispose();
    _nicknameCtrl.dispose();
    _pronounsCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
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

  Future<void> _save() async {
    if (_usernameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Username é obrigatório.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      await ref.read(profileRepositoryProvider).updateProfile(
            username: _usernameCtrl.text.trim(),
            displayName: _displayNameCtrl.text.trim().isEmpty
                ? null
                : _displayNameCtrl.text.trim(),
            nickname: _nicknameCtrl.text.trim().isEmpty
                ? null
                : _nicknameCtrl.text.trim(),
            pronouns: _pronounsCtrl.text.trim().isEmpty
                ? null
                : _pronounsCtrl.text.trim(),
            bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
            avatarUrl: _avatarUrl,
          );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() { _saving = false; _error = e.toString(); });
    }
  }

  Future<void> _changePassword() async {
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    var loading = false;
    String? err;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Alterar senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nova senha', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmCtrl,
                decoration: const InputDecoration(
                    labelText: 'Confirmar nova senha',
                    border: OutlineInputBorder()),
                obscureText: true,
              ),
              if (err != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(err!,
                      style: TextStyle(
                          color: Theme.of(ctx).colorScheme.error,
                          fontSize: 12)),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (newCtrl.text.length < 6) {
                        setState(() => err = 'Senha deve ter ao menos 6 caracteres.');
                        return;
                      }
                      if (newCtrl.text != confirmCtrl.text) {
                        setState(() => err = 'As senhas não coincidem.');
                        return;
                      }
                      setState(() { loading = true; err = null; });
                      try {
                        await ref
                            .read(profileRepositoryProvider)
                            .changePassword(newCtrl.text);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Senha alterada com sucesso!')),
                          );
                        }
                      } catch (e) {
                        setState(() { loading = false; err = e.toString(); });
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewProfile = UserProfile(
      id: widget.profile.id,
      username: _usernameCtrl.text,
      avatarUrl: _avatarUrl,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Avatar ──────────────────────────────────────
          Center(
            child: Stack(
              children: [
                AvatarWidget(profile: previewProfile, radius: 52),
                Positioned(
                  bottom: 0, right: 0,
                  child: GestureDetector(
                    onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: _uploadingAvatar
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.camera_alt, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Informações básicas ─────────────────────────
          _SectionHeader('Informações básicas'),
          const SizedBox(height: 12),
          _Field(
            controller: _displayNameCtrl,
            label: 'Nome de exibição',
            hint: 'Como você quer ser chamado(a)',
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 12),
          _Field(
            controller: _usernameCtrl,
            label: 'Username *',
            hint: 'seu_username',
            icon: Icons.alternate_email,
          ),
          const SizedBox(height: 12),
          _Field(
            controller: _nicknameCtrl,
            label: 'Apelido',
            hint: 'Como seus amigos te chamam',
            icon: Icons.local_bar_outlined,
          ),
          const SizedBox(height: 12),
          _Field(
            controller: _pronounsCtrl,
            label: 'Pronomes',
            hint: 'ex: ele/dele, ela/dela, elu/delu',
            icon: Icons.wc_outlined,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bioCtrl,
            decoration: const InputDecoration(
              labelText: 'Bio',
              hintText: 'Fale sobre você e seus drinks favoritos...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit_note_outlined),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            maxLength: 160,
          ),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12)),
            ),

          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),

          // ── Segurança ───────────────────────────────────
          _SectionHeader('Segurança'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _changePassword,
            icon: const Icon(Icons.lock_outline),
            label: const Text('Alterar senha'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),

          // ── Salvar ──────────────────────────────────────
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Salvar', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
      );
}
