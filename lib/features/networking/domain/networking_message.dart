class NetworkingMessage {
  final String id;
  final String messageType;
  final String recipient;
  final String company;
  final String context;
  final String tone;
  final String generatedMessage;
  final DateTime createdAt;

  const NetworkingMessage({
    required this.id,
    required this.messageType,
    required this.recipient,
    required this.company,
    required this.context,
    required this.tone,
    required this.generatedMessage,
    required this.createdAt,
  });

  NetworkingMessage copyWith({
    String? id,
    String? messageType,
    String? recipient,
    String? company,
    String? context,
    String? tone,
    String? generatedMessage,
    DateTime? createdAt,
  }) => NetworkingMessage(
    id: id ?? this.id,
    messageType: messageType ?? this.messageType,
    recipient: recipient ?? this.recipient,
    company: company ?? this.company,
    context: context ?? this.context,
    tone: tone ?? this.tone,
    generatedMessage: generatedMessage ?? this.generatedMessage,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'messageType': messageType,
    'recipient': recipient,
    'company': company,
    'context': context,
    'tone': tone,
    'generatedMessage': generatedMessage,
    'createdAt': createdAt.toIso8601String(),
  };

  factory NetworkingMessage.fromJson(Map<String, dynamic> json) =>
      NetworkingMessage(
        id: json['id'] as String,
        messageType: json['messageType'] as String,
        recipient: json['recipient'] as String,
        company: json['company'] as String,
        context: json['context'] as String,
        tone: json['tone'] as String,
        generatedMessage: json['generatedMessage'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
