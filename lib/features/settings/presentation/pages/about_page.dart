import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../services/ai/ai_providers_disclosure.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBG,
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: context.appBG,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
        children: [
          // ── Logo + App Name ─────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 34,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'AI Career Copilot',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.0.0',
                  style: TextStyle(fontSize: 13, color: context.appText2),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your AI-powered career toolkit',
                  style: TextStyle(fontSize: 14, color: context.appText2),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Built with AI ───────────────────────────────────────────────
          Text(
            'Built with world-class AI',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.appText2,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 12),

          // OpenAI GPT
          _AiCard(
            gradient: const LinearGradient(
              colors: [Color(0xFF10A37F), Color(0xFF1A7F5A)],
            ),
            icon: Icons.psychology_rounded,
            title: 'OpenAI GPT',
            description:
                'Powers natural language understanding and generation for resumes, cover letters, and career coaching.',
          ),

          const SizedBox(height: 10),

          // Google Gemini
          _AiCard(
            gradient: const LinearGradient(
              colors: [Color(0xFF4285F4), Color(0xFF34A853)],
            ),
            icon: Icons.auto_awesome_rounded,
            title: 'Google Gemini',
            description:
                'Provides advanced reasoning and multi-modal capabilities for CV parsing and skill analysis.',
          ),

          const SizedBox(height: 10),

          // DeepSeek
          _AiCard(
            gradient: const LinearGradient(
              colors: [Color(0xFF5B5FEF), Color(0xFF8B5CF6)],
            ),
            icon: Icons.hub_rounded,
            title: 'DeepSeek',
            description:
                'High-quality content generation engine optimized for resume writing and structured document creation.',
          ),

          const SizedBox(height: 10),

          // Groq
          _AiCard(
            gradient: const LinearGradient(
              colors: [Color(0xFFF55036), Color(0xFFE03E2D)],
            ),
            icon: Icons.bolt_rounded,
            title: 'Groq',
            description:
                'Ultra-fast inference for real-time chat responses and instant career suggestions.',
          ),

          const SizedBox(height: 32),

          // ── Footer ──────────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    kAiBrandingTagline,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Made with care for job seekers worldwide',
                  style: TextStyle(fontSize: 12, color: context.appText2),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2025 AI Career Copilot. All rights reserved.',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.appText2.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── AI Provider Card ────────────────────────────────────────────────────────

class _AiCard extends StatelessWidget {
  final Gradient gradient;
  final IconData icon;
  final String title;
  final String description;

  const _AiCard({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appBorder),
        boxShadow: AppShadows.card(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.appText2,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
