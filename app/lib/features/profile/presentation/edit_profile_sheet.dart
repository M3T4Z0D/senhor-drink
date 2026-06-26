import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile_model.dart';
import '../data/profile_repository.dart';
import 'widgets/avatar_widget.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final _usernameCtrl =
      TextEditingController(text: widget.profile.username);
  late final _bioCtrl =
      TextEditingController(text: widget.profile.bio ?? '');
  late final _avatarCtrl =
      TextEditingController(text: widget.profile.avatarUrl ?? '');

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    _avatarCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_usernameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Username é obrigatório.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(profileRepositoryProvider).updateProfile(
            username: _usernameCtrl.text.trim(),
            bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
            avatarUrl: _avatarCtrl.text.trim().isEmpty
                ? null
                : _avatarCtrl.text.trim(),
          );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = UserProfile(
      id: widget.profile.id,
      username: _usernameCtrl.text.isEmpty
          ? widget.profile.username
          : _usernameCtrl.text,
      avatarUrl: _avatarCtrl.text.isEmpty ? null : _avatarCtrl.text,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Text('Editar perfil',
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context, false),
              ),
            ]),
            const SizedBox(height: 16),
            Center(child: AvatarWidget(profile: preview, radius: 48)),
            const SizedBox(height: 16),
            TextField(
              controller: _avatarCtrl,
              decoration: const InputDecoration(
                labelText: 'URL da foto de perfil',
                hintText: 'https://...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(
                labelText: 'Username *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.alternate_email),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bioCtrl,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Conte um pouco sobre você...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
              maxLines: 3,
              maxLength: 160,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
