import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final double padding;
  final Color? color;
  final bool hasBorder;

  const ModernCard({
    super.key,
    required this.child,
    this.padding = 32,
    this.color = AppTheme.backgroundLight,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: hasBorder ? Border.all(color: AppTheme.borderSoft, width: 1) : null,
      ),
      child: child,
    );
  }
}

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;

  const ActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final accentOrange = const Color(0xFFEB984E);
    final darkNavy = const Color(0xFF1E293B);

    return MouseRegion(
      cursor: onPressed != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: onPressed == null ? 0.6 : 1.0,
        child: Container(
          height: 64,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isSecondary ? Colors.white : darkNavy,
            borderRadius: BorderRadius.circular(20),
            border: isSecondary ? Border.all(color: accentOrange.withValues(alpha: 0.5), width: 1.5) : null,
            boxShadow: [
              if (!isSecondary)
                BoxShadow(color: darkNavy.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onPressed,
              borderRadius: BorderRadius.circular(20),
              child: Center(
                child: isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, color: isSecondary ? accentOrange : Colors.white, size: 22),
                            const SizedBox(width: 12),
                          ],
                          Text(
                            text,
                            style: GoogleFonts.lexend(
                              color: isSecondary ? darkNavy : Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
