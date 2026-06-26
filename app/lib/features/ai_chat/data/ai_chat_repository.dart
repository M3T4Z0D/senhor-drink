import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
import 'ai_message_model.dart';

class AiChatRepository {
  String get _uid => supabase.auth.currentUser!.id;

  Future<List<AiMessage>> loadHistory() async {
    final data = await supabase
        .from('ai_conversations')
        .select()
        .eq('user_id', _uid)
        .order('created_at')
        .limit(100);
    return (data as List)
        .map((r) => AiMessage.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveMessage({required String role, required String content}) =>
      supabase.from('ai_conversations').insert({
        'user_id': _uid,
        'role': role,
        'content': content,
      });

  Future<String> callGemini({
    required String message,
    required List<AiMessage> history,
  }) async {
    final res = await supabase.functions.invoke(
      'gemini-chat',
      body: {
        'message': message,
        'history': history
            .map((m) => {'role': m.role, 'content': m.content})
            .toList(),
      },
    );

    if (res.status != 200) {
      throw Exception('Erro ${res.status}: ${res.data}');
    }

    final text = res.data['response'] as String?;
    if (text == null) throw Exception('Resposta inválida do Guru IA');
    return text;
  }
}

final aiChatRepositoryProvider = Provider((ref) => AiChatRepository());

// ── Notifier ──────────────────────────────────────────────────────────────────

class AiChatNotifier extends AutoDisposeNotifier<AiChatState> {
  @override
  AiChatState build() {
    _loadHistory();
    return const AiChatState();
  }

  Future<void> _loadHistory() async {
    try {
      final messages = await ref.read(aiChatRepositoryProvider).loadHistory();
      state = state.copyWith(messages: messages, loadingHistory: false);
    } catch (e) {
      state = state.copyWith(loadingHistory: false, error: e.toString());
    }
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.sending) return;

    final repo = ref.read(aiChatRepositoryProvider);
    final userMsg = AiMessage.optimistic(role: 'user', content: trimmed);

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      sending: true,
      clearError: true,
    );

    try {
      // Salva mensagem do usuário e chama Gemini em paralelo
      final historyForApi = state.messages
          .where((m) => m.id != userMsg.id)
          .toList();

      final results = await Future.wait([
        repo.saveMessage(role: 'user', content: trimmed),
        repo.callGemini(message: trimmed, history: historyForApi),
      ]);

      final responseText = results[1] as String;
      final assistantMsg =
          AiMessage.optimistic(role: 'assistant', content: responseText);

      await repo.saveMessage(role: 'assistant', content: responseText);

      state = state.copyWith(
        messages: [...state.messages, assistantMsg],
        sending: false,
      );
    } catch (e) {
      state = state.copyWith(sending: false, error: e.toString());
    }
  }
}

final aiChatProvider =
    AutoDisposeNotifierProvider<AiChatNotifier, AiChatState>(
  AiChatNotifier.new,
);
