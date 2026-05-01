import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDark;

  const AppLogo({super.key, this.size = 40, this.showText = false, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                  ? [AppTheme.violet400, AppTheme.violet600]
                  : [AppTheme.violet600, AppTheme.violet800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppTheme.violet400 : AppTheme.violet600).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.chat_rounded,
            size: size * 0.55,
            color: Colors.white,
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 8),
          Text(
            'Chirper',
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.violet400 : AppTheme.violet600,
              letterSpacing: -0.03,
            ),
          ),
        ],
      ],
    );
  }
}

class VerifiedBadge extends StatelessWidget {
  final double size;
  final bool isSmall;

  const VerifiedBadge({super.key, this.size = 16, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmall ? size * 0.1 : size * 0.15),
      decoration: const BoxDecoration(
        color: AppTheme.moss600,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        size: isSmall ? size * 0.6 : size * 0.7,
        color: Colors.white,
      ),
    );
  }
}

class LikeButton extends StatelessWidget {
  final bool isLiked;
  final String count;
  final VoidCallback onTap;
  final bool isDark;

  const LikeButton({
    super.key,
    required this.isLiked,
    required this.count,
    required this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isLiked ? AppTheme.coral50 : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: isLiked 
                  ? AppTheme.coral600 
                  : (isDark ? AppTheme.darkTextSecondary : AppTheme.stone500),
            ),
            if (count.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                count,
                style: TextStyle(
                  fontSize: 13,
                  color: isLiked 
                      ? AppTheme.coral600 
                      : (isDark ? AppTheme.darkTextSecondary : AppTheme.stone500),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color? color;
  final VoidCallback onTap;
  final bool isDark;

  const ActionButton({
    super.key,
    required this.icon,
    this.label,
    this.color,
    required this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? (isDark ? AppTheme.darkTextSecondary : AppTheme.stone500);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: effectiveColor),
            if (label != null && label!.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label!,
                style: TextStyle(fontSize: 13, color: effectiveColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}