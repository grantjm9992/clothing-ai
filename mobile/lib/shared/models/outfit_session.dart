class OutfitSession {
  final String id;
  final String userId;
  final String? outfitPhotoId;
  final Map<String, dynamic> context;
  final String status;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final OutfitFeedback? feedback;
  final List<OutfitRecommendation> recommendations;
  final String? imageUrl;

  OutfitSession({
    required this.id,
    required this.userId,
    this.outfitPhotoId,
    required this.context,
    required this.status,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
    this.feedback,
    this.recommendations = const [],
    this.imageUrl,
  });

  factory OutfitSession.fromJson(Map<String, dynamic> json) {
    return OutfitSession(
      id: json['id'],
      userId: json['user_id'],
      outfitPhotoId: json['outfit_photo_id'],
      context: Map<String, dynamic>.from(json['context'] ?? {}),
      status: json['status'],
      errorMessage: json['error_message'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      feedback: json['feedback'] != null ? OutfitFeedback.fromJson(json['feedback']) : null,
      recommendations: (json['recommendations'] as List?)
              ?.map((r) => OutfitRecommendation.fromJson(r))
              .toList() ??
          [],
      imageUrl: json['image_url'],
    );
  }

  bool get isPending => status == 'queued' || status == 'processing';
  bool get isComplete => status == 'done';
  bool get hasFailed => status == 'failed';

  String get occasionDisplay => context['occasion'] ?? 'Casual';
  String get vibeDisplay => context['vibe'] ?? 'Smart Casual';
}

class OutfitFeedback {
  final String id;
  final String outfitSessionId;
  final double? overallScore;
  final String? summary;
  final List<FeedbackPoint> positives;
  final List<FeedbackPoint> issues;
  final List<Suggestion> suggestions;
  final DateTime createdAt;

  OutfitFeedback({
    required this.id,
    required this.outfitSessionId,
    this.overallScore,
    this.summary,
    this.positives = const [],
    this.issues = const [],
    this.suggestions = const [],
    required this.createdAt,
  });

  factory OutfitFeedback.fromJson(Map<String, dynamic> json) {
    return OutfitFeedback(
      id: json['id'],
      outfitSessionId: json['outfit_session_id'],
      overallScore: json['overall_score']?.toDouble(),
      summary: json['summary'],
      positives: (json['positives'] as List?)
              ?.map((p) => FeedbackPoint.fromJson(p))
              .toList() ??
          [],
      issues: (json['issues'] as List?)
              ?.map((i) => FeedbackPoint.fromJson(i))
              .toList() ??
          [],
      suggestions: (json['suggestions'] as List?)
              ?.map((s) => Suggestion.fromJson(s))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get scoreLabel {
    if (overallScore == null) return 'N/A';
    if (overallScore! >= 8.5) return 'Excellent';
    if (overallScore! >= 7.5) return 'Great';
    if (overallScore! >= 6.5) return 'Good';
    if (overallScore! >= 5.5) return 'Fair';
    return 'Needs Improvement';
  }
}

class FeedbackPoint {
  final String title;
  final String detail;

  FeedbackPoint({required this.title, required this.detail});

  factory FeedbackPoint.fromJson(Map<String, dynamic> json) {
    return FeedbackPoint(
      title: json['title'] ?? '',
      detail: json['detail'] ?? '',
    );
  }
}

class Suggestion {
  final String type;
  final String target;
  final String instruction;

  Suggestion({
    required this.type,
    required this.target,
    required this.instruction,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      type: json['type'] ?? 'general',
      target: json['target'] ?? '',
      instruction: json['instruction'] ?? '',
    );
  }

  String get icon {
    switch (type) {
      case 'swap':
        return '🔄';
      case 'add':
        return '➕';
      case 'remove':
        return '➖';
      default:
        return '💡';
    }
  }
}

class OutfitRecommendation {
  final String id;
  final String outfitSessionId;
  final String type;
  final List<String> items;
  final String? explanation;
  final double? confidence;
  final int rank;

  OutfitRecommendation({
    required this.id,
    required this.outfitSessionId,
    required this.type,
    this.items = const [],
    this.explanation,
    this.confidence,
    required this.rank,
  });

  factory OutfitRecommendation.fromJson(Map<String, dynamic> json) {
    return OutfitRecommendation(
      id: json['id'],
      outfitSessionId: json['outfit_session_id'],
      type: json['type'],
      items: List<String>.from(json['items'] ?? []),
      explanation: json['explanation'],
      confidence: json['confidence']?.toDouble(),
      rank: json['rank'] ?? 0,
    );
  }
}
