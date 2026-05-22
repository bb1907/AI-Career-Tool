import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

/// Displays a compact language/country badge.
/// Uses a colored 2-letter code (reliable cross-platform, no emoji rendering issues).
class LanguageBadge extends StatelessWidget {
  final String code; // language code e.g. 'tr', 'en', 'auto'
  final double size;

  const LanguageBadge({super.key, required this.code, this.size = 26});

  @override
  Widget build(BuildContext context) {
    if (code == 'auto') {
      return _badge(
        child: Icon(
          Icons.language_rounded,
          size: size * 0.55,
          color: Colors.white,
        ),
        color: AppColors.primary,
      );
    }
    final label = code.toUpperCase().substring(0, code.length >= 2 ? 2 : 1);
    final color = _colorFor(code);
    return _badge(
      child: Text(
        label,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0,
          height: 1,
        ),
      ),
      color: color,
    );
  }

  Widget _badge({required Widget child, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Center(child: child),
    );
  }

  static Color _colorFor(String code) {
    const map = <String, Color>{
      'en': Color(0xFF1A56DB), // blue — US/UK
      'tr': Color(0xFFD30F2F), // red — Turkey
      'es': Color(0xFFAA151B), // red — Spain
      'fr': Color(0xFF002395), // blue — France
      'de': Color(0xFF222222), // black — Germany
      'pt': Color(0xFF006600), // green — Portugal/Brazil
      'it': Color(0xFF009246), // green — Italy
      'ru': Color(0xFF003399), // blue — Russia
      'ar': Color(0xFF007A3D), // green — Arabia
      'hi': Color(0xFFFF9933), // orange — India
      'zh': Color(0xFFDE2910), // red — China
      'ja': Color(0xFFBC002D), // red — Japan
      'ko': Color(0xFF003478), // blue — Korea
      'pl': Color(0xFFDC143C), // crimson — Poland
      'nl': Color(0xFFAE1C28), // red — Netherlands
      'sv': Color(0xFF006AA7), // blue — Sweden
      'uk': Color(0xFF005BBB), // blue — Ukraine
      'cs': Color(0xFFD7141A), // red — Czech
      'sk': Color(0xFF0B4EA2), // blue — Slovakia
      'hr': Color(0xFF171796), // blue — Croatia
      'sr': Color(0xFF0C4076), // blue — Serbia
      'bg': Color(0xFF00966E), // green — Bulgaria
      'ro': Color(0xFF002B7F), // blue — Romania
      'hu': Color(0xFF436F4D), // green — Hungary
      'el': Color(0xFF0D5EAF), // blue — Greece
      'he': Color(0xFF0038B8), // blue — Israel
      'fa': Color(0xFF239F40), // green — Iran
      'bn': Color(0xFF006A4E), // green — Bangladesh
      'ur': Color(0xFF01411C), // green — Pakistan
      'ne': Color(0xFF003893), // blue — Nepal
      'si': Color(0xFF8D153A), // maroon — Sri Lanka
      'th': Color(0xFF2D2A4A), // dark — Thailand
      'vi': Color(0xFFDA251D), // red — Vietnam
      'id': Color(0xFFCE1126), // red — Indonesia
      'ms': Color(0xFFCC0001), // red — Malaysia
      'tl': Color(0xFF0038A8), // blue — Philippines
      'my': Color(0xFF34A853), // green — Myanmar
      'km': Color(0xFF032EA1), // blue — Cambodia
      'lo': Color(0xFFCE1126), // red — Laos
      'sw': Color(0xFF006600), // green — Swahili
      'am': Color(0xFF078930), // green — Ethiopia
      'ca': Color(0xFFCFB53B), // gold — Catalan
      'nb': Color(0xFFEF2B2D), // red — Norwegian
      'da': Color(0xFFC60C30), // red — Danish
      'fi': Color(0xFF003580), // blue — Finland
      'lt': Color(0xFF006A44), // green — Lithuania
      'lv': Color(0xFF9E3039), // maroon — Latvia
      'et': Color(0xFF0072CE), // blue — Estonia
      'ka': Color(0xFFD42127), // red — Georgia
      'sl': Color(0xFF003DA5), // blue — Slovenia
    };
    return map[code] ?? AppColors.primary;
  }
}
