class AiMessage {
  const AiMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime createdAt;

  bool get isUser => role == 'user';

  factory AiMessage.fromJson(Map<String, dynamic> json) => AiMessage(
        id: json['id'] as String,
        role: json['role'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  // Usado para mensagens otimistas (antes de salvar no banco)
  factory AiMessage.optimistic({required String role, required String content}) =>
      AiMessage(
        id: '${role}_${DateTime.now().millisecondsSinceEpoch}',
        role: role,
        content: content,
        createdAt: DateTime.now(),
      );
}

class AiChatState {
  const AiChatState({
    this.messages = const [],
    this.loadingHistory = true,
    this.sending = false,
    this.error,
  });

  final List<AiMessage> messages;
  final bool loadingHistory;
  final bool sending;
  final String? error;

  AiChatState copyWith({
    List<AiMessage>? messages,
    bool? loadingHistory,
    bool? sending,
    String? error,
    bool clearError = false,
  }) =>
      AiChatState(
        messages: messages ?? this.messages,
        loadingHistory: loadingHistory ?? this.loadingHistory,
        sending: sending ?? this.sending,
        error: clearError ? null : error ?? this.error,
      );
}
