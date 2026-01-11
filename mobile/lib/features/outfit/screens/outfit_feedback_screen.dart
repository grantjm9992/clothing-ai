import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/providers.dart';
import '../../../shared/models/outfit_session.dart';

class OutfitFeedbackScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const OutfitFeedbackScreen({super.key, required this.sessionId});

  @override
  ConsumerState<OutfitFeedbackScreen> createState() => _OutfitFeedbackScreenState();
}

class _OutfitFeedbackScreenState extends ConsumerState<OutfitFeedbackScreen> {
  @override
  void initState() {
    super.initState();
    _pollForResults();
  }

  Future<void> _pollForResults() async {
    // Poll every 2 seconds until done
    while (mounted) {
      await ref.read(outfitSessionsProvider.notifier).pollSession(widget.sessionId);
      final state = ref.read(outfitSessionsProvider);

      if (state.currentSession?.isComplete == true) {
        break;
      }

      await Future.delayed(const Duration(seconds: 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(outfitSessionsProvider);
    final session = sessionState.currentSession;

    if (session == null || session.isPending) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analyzing...')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text('AI is analyzing your outfit...', style: AppTheme.h3),
              const SizedBox(height: 12),
              Text(
                'This usually takes 5-10 seconds',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final feedback = session.feedback;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Feedback'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Outfit photo
            if (session.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Image.network(
                    session.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Context
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 20),
                        const SizedBox(width: 8),
                        Text('Context', style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ContextRow(
                      icon: Icons.event,
                      label: 'Occasion',
                      value: session.occasionDisplay,
                    ),
                    _ContextRow(
                      icon: Icons.auto_awesome,
                      label: 'Vibe',
                      value: session.vibeDisplay,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Overall score
            if (feedback?.overallScore != null) ...[
              _ScoreCard(
                score: feedback!.overallScore!,
                label: feedback.scoreLabel,
              ),
              const SizedBox(height: 24),
            ],

            // Summary
            if (feedback?.summary != null) ...[
              Text('Summary', style: AppTheme.h3),
              const SizedBox(height: 12),
              Text(
                feedback!.summary!,
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
            ],

            // What Works
            if (feedback?.positives != null && feedback!.positives.isNotEmpty) ...[
              _SectionHeader(
                icon: Icons.check_circle,
                title: 'What Works',
                color: AppTheme.success,
              ),
              const SizedBox(height: 12),
              ...feedback.positives.map((positive) => _FeedbackCard(
                    icon: Icons.check_circle_outline,
                    iconColor: AppTheme.success,
                    title: positive.title,
                    detail: positive.detail,
                  )),
              const SizedBox(height: 24),
            ],

            // Issues
            if (feedback?.issues != null && feedback!.issues.isNotEmpty) ...[
              _SectionHeader(
                icon: Icons.warning,
                title: 'Things to Consider',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              ...feedback.issues.map((issue) => _FeedbackCard(
                    icon: Icons.info_outline,
                    iconColor: Colors.orange,
                    title: issue.title,
                    detail: issue.detail,
                  )),
              const SizedBox(height: 24),
            ],

            // Suggestions
            if (feedback?.suggestions != null && feedback!.suggestions.isNotEmpty) ...[
              _SectionHeader(
                icon: Icons.lightbulb,
                title: 'Suggestions',
                color: AppTheme.accent,
              ),
              const SizedBox(height: 12),
              ...feedback.suggestions.map((suggestion) => _SuggestionCard(
                    suggestion: suggestion,
                  )),
              const SizedBox(height: 24),
            ],

            // Recommendations
            if (session.recommendations.isNotEmpty) ...[
              Text('Outfit Recommendations', style: AppTheme.h3),
              const SizedBox(height: 12),
              Text(
                'Based on your wardrobe',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              ...session.recommendations.map((rec) => _RecommendationCard(
                    recommendation: rec,
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final double score;
  final String label;

  const _ScoreCard({required this.score, required this.label});

  @override
  Widget build(BuildContext context) {
    final percentage = score / 10;
    final color = _getScoreColor(score);

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                  Center(
                    child: Text(
                      score.toStringAsFixed(1),
                      style: AppTheme.h2.copyWith(color: color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overall Score', style: AppTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(label, style: AppTheme.h3.copyWith(color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.5) return AppTheme.success;
    if (score >= 7.0) return const Color(0xFF10B981);
    if (score >= 5.5) return Colors.orange;
    return AppTheme.error;
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(title, style: AppTheme.h3),
      ],
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String detail;

  const _FeedbackCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(detail, style: AppTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final Suggestion suggestion;

  const _SuggestionCard({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Text(suggestion.icon, style: const TextStyle(fontSize: 24)),
        title: Text(
          _getTypeLabel(suggestion.type),
          style: AppTheme.bodySmall,
        ),
        subtitle: Text(
          suggestion.instruction,
          style: AppTheme.bodyMedium,
        ),
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'swap':
        return 'Swap ${suggestion.target}';
      case 'add':
        return 'Add ${suggestion.target}';
      case 'remove':
        return 'Remove ${suggestion.target}';
      default:
        return 'Suggestion';
    }
  }
}

class _RecommendationCard extends StatelessWidget {
  final OutfitRecommendation recommendation;

  const _RecommendationCard({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Option ${recommendation.rank + 1}',
                    style: AppTheme.caption.copyWith(color: AppTheme.accent),
                  ),
                ),
                if (recommendation.confidence != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${(recommendation.confidence! * 100).toStringAsFixed(0)}% match',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ],
            ),
            if (recommendation.explanation != null) ...[
              const SizedBox(height: 12),
              Text(
                recommendation.explanation!,
                style: AppTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {},
              child: const Text('View Items'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContextRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: AppTheme.bodySmall,
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
