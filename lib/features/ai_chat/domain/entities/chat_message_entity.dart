import 'package:equatable/equatable.dart';

enum MessageRole { user, assistant }

class ChatMessageEntity extends Equatable {
  final String id;
  final String text;
  final MessageRole role;
  final DateTime timestamp;
  final bool isLoading;

  const ChatMessageEntity({
    required this.id,
    required this.text,
    required this.role,
    required this.timestamp,
    this.isLoading = false,
  });

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;

  @override
  List<Object?> get props => [id];
}
