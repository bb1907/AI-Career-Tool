import 'package:flutter/material.dart';

enum ApplicationStatus {
  wishlist,
  applied,
  phoneScreen,
  interview,
  offer,
  rejected,
  withdrawn;

  String get label => switch (this) {
    wishlist => 'Wishlist',
    applied => 'Applied',
    phoneScreen => 'Phone Screen',
    interview => 'Interview',
    offer => 'Offer',
    rejected => 'Rejected',
    withdrawn => 'Withdrawn',
  };

  Color get color => switch (this) {
    wishlist => const Color(0xFF6366F1),
    applied => const Color(0xFF3B82F6),
    phoneScreen => const Color(0xFF8B5CF6),
    interview => const Color(0xFFF59E0B),
    offer => const Color(0xFF22C55E),
    rejected => const Color(0xFFEF4444),
    withdrawn => const Color(0xFF6B7280),
  };

  IconData get icon => switch (this) {
    wishlist => Icons.bookmarks_rounded,
    applied => Icons.send_rounded,
    phoneScreen => Icons.phone_rounded,
    interview => Icons.psychology_rounded,
    offer => Icons.celebration_rounded,
    rejected => Icons.cancel_rounded,
    withdrawn => Icons.undo_rounded,
  };

  static ApplicationStatus fromString(String value) {
    return ApplicationStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => ApplicationStatus.wishlist,
    );
  }
}

class Application {
  final String id;
  final String company;
  final String role;
  final String jobDescription;
  final ApplicationStatus status;
  final DateTime createdAt;
  final DateTime? appliedAt;
  final DateTime? followUpAt;
  final String notes;
  final String source;
  final int? matchScore;
  final String? jobPlanId;

  const Application({
    required this.id,
    required this.company,
    required this.role,
    required this.jobDescription,
    required this.status,
    required this.createdAt,
    this.appliedAt,
    this.followUpAt,
    this.notes = '',
    this.source = '',
    this.matchScore,
    this.jobPlanId,
  });

  Application copyWith({
    String? id,
    String? company,
    String? role,
    String? jobDescription,
    ApplicationStatus? status,
    DateTime? createdAt,
    Object? appliedAt = _sentinel,
    Object? followUpAt = _sentinel,
    String? notes,
    String? source,
    Object? matchScore = _sentinel,
    Object? jobPlanId = _sentinel,
  }) => Application(
    id: id ?? this.id,
    company: company ?? this.company,
    role: role ?? this.role,
    jobDescription: jobDescription ?? this.jobDescription,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    appliedAt: appliedAt == _sentinel ? this.appliedAt : appliedAt as DateTime?,
    followUpAt: followUpAt == _sentinel
        ? this.followUpAt
        : followUpAt as DateTime?,
    notes: notes ?? this.notes,
    source: source ?? this.source,
    matchScore: matchScore == _sentinel ? this.matchScore : matchScore as int?,
    jobPlanId: jobPlanId == _sentinel ? this.jobPlanId : jobPlanId as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'company': company,
    'role': role,
    'jobDescription': jobDescription,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'appliedAt': appliedAt?.toIso8601String(),
    'followUpAt': followUpAt?.toIso8601String(),
    'notes': notes,
    'source': source,
    'matchScore': matchScore,
    'jobPlanId': jobPlanId,
  };

  factory Application.fromJson(Map<String, dynamic> json) => Application(
    id: json['id'] as String,
    company: json['company'] as String,
    role: json['role'] as String,
    jobDescription: json['jobDescription'] as String? ?? '',
    status: ApplicationStatus.fromString(
      json['status'] as String? ?? 'wishlist',
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
    appliedAt: json['appliedAt'] != null
        ? DateTime.parse(json['appliedAt'] as String)
        : null,
    followUpAt: json['followUpAt'] != null
        ? DateTime.parse(json['followUpAt'] as String)
        : null,
    notes: json['notes'] as String? ?? '',
    source: json['source'] as String? ?? '',
    matchScore: json['matchScore'] as int?,
    jobPlanId: json['jobPlanId'] as String?,
  );
}

// Sentinel for nullable copyWith fields
const _sentinel = Object();

// ── Application Timeline Event ─────────────────────────────────────────────

class ApplicationEvent {
  final String id;
  final String applicationId;
  final String description;
  final DateTime createdAt;

  const ApplicationEvent({
    required this.id,
    required this.applicationId,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'applicationId': applicationId,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ApplicationEvent.fromJson(Map<String, dynamic> json) =>
      ApplicationEvent(
        id: json['id'] as String,
        applicationId: json['applicationId'] as String,
        description: json['description'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
