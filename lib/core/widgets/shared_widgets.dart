import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/theme.dart';

// ═══════════════════════════════════════════════════════════════
// 1. APP BUTTON
// ═══════════════════════════════════════════════════════════════
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final bool isLoading;
  final bool isSmall;
  final IconData? icon;
  final Color? backgroundColor;
  final double? width;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isOutlined = false,
    this.isLoading = false,
    this.isSmall = false,
    this.icon,
    this.backgroundColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final minH = isSmall ? 40.0 : 48.0;
    final fontSize = isSmall ? 13.0 : 16.0;
    final iconSize = isSmall ? 16.0 : 20.0;
    final iconGap = isSmall ? 4.0 : 8.0;
    final hPad = isSmall ? 16.0 : 24.0;

    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isOutlined ? primaryColor : AppTheme.textOnPrimary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: iconSize),
                SizedBox(width: iconGap),
              ],
              Text(
                text,
                style: AppTheme.buttonText.copyWith(
                  fontSize: fontSize,
                  color: isOutlined ? primaryColor : AppTheme.textOnPrimary,
                ),
              ),
            ],
          );

    final btn = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor, width: 1.5),
              minimumSize: Size(0, minH),
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
            child: child,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? primaryColor,
              foregroundColor: AppTheme.textOnPrimary,
              elevation: 0,
              minimumSize: Size(0, minH),
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
            child: child,
          );

    return width != null ? SizedBox(width: width, child: btn) : btn;
  }
}

// ═══════════════════════════════════════════════════════════════
// 2. APP CARD — with scale animation on press
// ═══════════════════════════════════════════════════════════════
class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius = AppTheme.radiusLg,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: AppTheme.animFast,
      reverseDuration: AppTheme.animFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _scaleController.forward();
  void _onTapUp(_) => _scaleController.reverse();
  void _onTapCancel() => _scaleController.reverse();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: widget.margin ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: widget.color ?? AppTheme.adaptiveCardColor(context),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: isDark ? null : AppTheme.softShadow,
        border:
            isDark ? Border.all(color: AppTheme.darkDivider.withValues(alpha: 0.5)) : null,
      ),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: widget.onTap != null ? _onTapDown : null,
            onTapUp: widget.onTap != null ? _onTapUp : null,
            onTapCancel: widget.onTap != null ? _onTapCancel : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(16),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 3. GRADIENT CARD
// ═══════════════════════════════════════════════════════════════
class GradientCard extends StatelessWidget {
  final IconData headerIcon;
  final String title;
  final String? subtitle;
  final List<Color> gradientColors;
  final Widget body;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.headerIcon,
    required this.title,
    this.subtitle,
    this.gradientColors = const [AppTheme.primaryDark, AppTheme.primaryColor],
    required this.body,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.adaptiveCardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.adaptiveShadow(context),
        border: AppTheme.adaptiveBorder(context),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Gradient Header ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusLg),
                    topRight: Radius.circular(AppTheme.radiusLg),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.textOnPrimary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(headerIcon,
                          color: AppTheme.textOnPrimary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTheme.titleMedium.copyWith(
                                color: AppTheme.textOnPrimary),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: AppTheme.bodySmall.copyWith(
                                  color:
                                      AppTheme.textOnPrimary.withValues(alpha: 0.8)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // ── Body ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 4. APP TEXT FIELD — auto RTL/LTR detection
// ═══════════════════════════════════════════════════════════════
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool obscureText;
  final bool readOnly;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType,
    this.focusNode,
    this.onTap,
    this.autofillHints,
    this.textInputAction,
  });

  bool get _isLtr => keyboardType == TextInputType.emailAddress ||
      keyboardType == TextInputType.phone ||
      keyboardType == TextInputType.number ||
      keyboardType == TextInputType.visiblePassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTheme.labelMedium),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
          readOnly: readOnly,
          onTap: onTap,
          autofillHints: autofillHints,
          textInputAction: textInputAction,
          style: AppTheme.bodyMedium,
          textDirection: _isLtr ? TextDirection.ltr : TextDirection.rtl,
          textAlign: _isLtr ? TextAlign.left : TextAlign.right,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon,
                    color: Theme.of(context).colorScheme.outline, size: 20)
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 5. LOADING SHIMMER — 3 types: list, card, detail
// ═══════════════════════════════════════════════════════════════
enum ShimmerType { list, card, detail }

class LoadingShimmer extends StatelessWidget {
  final int itemCount;
  final double height;
  final ShimmerType type;

  const LoadingShimmer({
    super.key,
    this.itemCount = 5,
    this.height = 100,
    this.type = ShimmerType.list,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppTheme.shimmerBaseDark : AppTheme.shimmerBaseLight;
    final highlight =
        isDark ? AppTheme.shimmerHighlightDark : AppTheme.shimmerHighlightLight;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          switch (type) {
            case ShimmerType.list:
              return _buildListShimmer(base);
            case ShimmerType.card:
              return _buildCardShimmer(base);
            case ShimmerType.detail:
              return _buildDetailShimmer(base);
          }
        },
      ),
    );
  }

  Widget _shimmerBox(double w, double h, Color base, {double radius = 8}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildListShimmer(Color base) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        children: [
          _shimmerBox(48, 48, base, radius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(double.infinity, 14, base),
                const SizedBox(height: 8),
                _shimmerBox(180, 12, base),
                const SizedBox(height: 6),
                _shimmerBox(120, 10, base),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardShimmer(Color base) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
    );
  }

  Widget _buildDetailShimmer(Color base) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(double.infinity, 180, base, radius: 12),
          const SizedBox(height: 16),
          _shimmerBox(double.infinity, 18, base),
          const SizedBox(height: 10),
          _shimmerBox(200, 14, base),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _shimmerBox(double.infinity, 40, base)),
              const SizedBox(width: 8),
              Expanded(child: _shimmerBox(double.infinity, 40, base)),
            ],
          ),
          const SizedBox(height: 12),
          _shimmerBox(double.infinity, 14, base),
          const SizedBox(height: 6),
          _shimmerBox(250, 14, base),
          const SizedBox(height: 6),
          _shimmerBox(180, 14, base),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 6. EMPTY STATE WIDGET — bounce + pulse animation
// ═══════════════════════════════════════════════════════════════
class EmptyStateWidget extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    this.iconColor,
  });

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Bounce animation (entry)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    );
    _bounceController.forward();

    // Pulse animation (2s repeat)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final iconColor = widget.iconColor ?? primaryColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: FadeTransition(
          opacity: _bounceAnimation,
          child: ScaleTransition(
            scale: _bounceAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, size: 48, color: iconColor),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.title,
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.adaptiveTextPrimary(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle!,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.adaptiveTextSecondary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (widget.buttonText != null &&
                    widget.onButtonPressed != null) ...[
                  const SizedBox(height: 24),
                  AppButton(
                    text: widget.buttonText!,
                    onPressed: widget.onButtonPressed,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 7. APP ERROR WIDGET — with pulse animation on retry
// ═══════════════════════════════════════════════════════════════
class AppErrorWidget extends StatefulWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  State<AppErrorWidget> createState() => _AppErrorWidgetState();
}

class _AppErrorWidgetState extends State<AppErrorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 48, color: errorColor),
            ),
            const SizedBox(height: 24),
            Text(
              widget.message,
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.adaptiveTextPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.onRetry != null) ...[
              const SizedBox(height: 16),
              ScaleTransition(
                scale: _pulseAnimation,
                child: AppButton(
                  text: 'إعادة المحاولة',
                  onPressed: widget.onRetry,
                  icon: Icons.refresh,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 8. STATUS BADGE — pill with 12%/18% alpha, optional border
// ═══════════════════════════════════════════════════════════════
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        border: isDark
            ? Border.all(color: color.withValues(alpha: 0.25), width: 0.5)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style:
                AppTheme.bodySmall.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 9. RATING DISPLAY — star + rating + review count
// ═══════════════════════════════════════════════════════════════
class RatingDisplay extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double starSize;
  final bool showCount;

  const RatingDisplay({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.starSize = 16,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded,
            size: starSize, color: AppTheme.secondaryColor),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.adaptiveTextPrimary(context),
          ),
        ),
        if (showCount && reviewCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.adaptiveTextSecondary(context),
            ),
          ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 10. SECTION HEADER — icon + title + action
// ═══════════════════════════════════════════════════════════════
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Text(title, style: AppTheme.headingSmall),
          const Spacer(),
          if (actionText != null && onActionTap != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText!,
                style: AppTheme.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 11. INFO CHIP — pill chip with label, icon, color, onTap, isSelected
// ═══════════════════════════════════════════════════════════════
class InfoChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool isSelected;

  const InfoChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.animNormal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: isDark ? 0.22 : 0.15)
              : (isDark ? AppTheme.darkCard : AppTheme.backgroundLight),
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          border: Border.all(
            color: isSelected
                ? chipColor
                : (isDark
                    ? AppTheme.darkDivider
                    : AppTheme.dividerColor),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: isSelected ? chipColor : null),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: isSelected
                    ? chipColor
                    : AppTheme.adaptiveTextSecondary(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 12. INFO ROW — icon + label + spacer + value
// ═══════════════════════════════════════════════════════════════
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Widget? trailing;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppTheme.adaptiveTextSecondary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.adaptiveTextSecondary(context),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.adaptiveTextPrimary(context),
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 13. STAT CARD — dashboard stat with icon, value, title
// ═══════════════════════════════════════════════════════════════
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;
  final String? subtitle;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.title,
    this.subtitle,
    this.color = AppTheme.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.adaptiveCardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: isDark ? null : AppTheme.softShadow,
        border: isDark
            ? Border.all(color: AppTheme.darkDivider.withValues(alpha: 0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.adaptiveTextPrimary(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.adaptiveTextSecondary(context),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTheme.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 14. BALANCE CARD — gradient card with wallet icon & progress
// ═══════════════════════════════════════════════════════════════
class BalanceCard extends StatelessWidget {
  final double balance;
  final double? maxBalance;

  const BalanceCard({
    super.key,
    required this.balance,
    this.maxBalance,
  });

  @override
  Widget build(BuildContext context) {
    final usagePercent = maxBalance != null && maxBalance! > 0
        ? (balance / maxBalance!).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryColor, AppTheme.primaryLight],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.textOnPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppTheme.textOnPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'رصيدك الحالي',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textOnPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${balance.toInt()} ر.ي',
            style: AppTheme.headingLarge.copyWith(
              color: AppTheme.textOnPrimary,
              fontSize: 36,
            ),
          ),
          if (maxBalance != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: usagePercent,
                backgroundColor: AppTheme.textOnPrimary.withValues(alpha: 0.2),
                color: AppTheme.secondaryColor,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'السقف الأقصى: ${maxBalance!.toInt()} ر.ي',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textOnPrimary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 15. LAZY INDEXED STACK — builds tabs only when visited
// ═══════════════════════════════════════════════════════════════
class LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  late Set<int> _built;

  @override
  void initState() {
    super.initState();
    _built = {widget.index};
  }

  @override
  void didUpdateWidget(covariant LazyIndexedStack old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      setState(() => _built.add(widget.index));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(
        widget.children.length,
        (i) => Offstage(
          offstage: i != widget.index,
          child: _built.contains(i) ? widget.children[i] : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 16. SCROLL TO TOP FAB
// ═══════════════════════════════════════════════════════════════
class ScrollToTopFab extends StatelessWidget {
  final ScrollController scrollController;
  final double showAfterOffset;
  final double? fabSize;

  const ScrollToTopFab({
    super.key,
    required this.scrollController,
    this.showAfterOffset = 400,
    this.fabSize,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _ScrollOffsetNotifier(scrollController),
      builder: (context, offset, _) {
        if (offset < showAfterOffset) return const SizedBox.shrink();

        return SizedBox(
          width: fabSize ?? 40,
          height: fabSize ?? 40,
          child: FloatingActionButton(
            mini: true,
            onPressed: () {
              scrollController.animateTo(
                0,
                duration: AppTheme.animSlow,
                curve: Curves.easeInOut,
              );
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: AppTheme.textOnPrimary,
            elevation: 4,
            child: const Icon(Icons.keyboard_arrow_up_rounded, size: 24),
          ),
        );
      },
    );
  }
}

class _ScrollOffsetNotifier extends ValueNotifier<double> {
  final ScrollController controller;
  late void Function() _listener;

  _ScrollOffsetNotifier(this.controller) : super(controller.offset) {
    _listener = () => value = controller.offset;
    controller.addListener(_listener);
  }

  @override
  void dispose() {
    controller.removeListener(_listener);
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════
// 17. ANIMATED SECTION — fade + slide-up with optional delay
// ═══════════════════════════════════════════════════════════════
class AnimatedSection extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const AnimatedSection({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppTheme.animNormal,
  });

  @override
  State<AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<AnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 18. COUNTDOWN TIMER — relative time with colored badge
// ═══════════════════════════════════════════════════════════════
class CountdownTimer extends StatefulWidget {
  final DateTime targetTime;
  final TextStyle? style;

  const CountdownTimer({
    super.key,
    required this.targetTime,
    this.style,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.targetTime.difference(DateTime.now());
    if (_remaining.isNegative) _remaining = Duration.zero;
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) return '${d.inDays} يوم';
    if (d.inHours > 0) return '${d.inHours} ساعة';
    if (d.inMinutes > 0) return '${d.inMinutes} دقيقة';
    return 'أقل من دقيقة';
  }

  Color _getColor() {
    if (_remaining.inDays > 3) return AppTheme.accentGreen;
    if (_remaining.inDays > 1) return AppTheme.warningColor;
    return AppTheme.accentRed;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return StatusBadge(
      text: _formatDuration(_remaining),
      color: color,
      icon: Icons.schedule_rounded,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 19. OPEN/CLOSED BADGE — green/red dot + text pill
// ═══════════════════════════════════════════════════════════════
class OpenClosedBadge extends StatelessWidget {
  final bool isOpen;
  final String? openText;
  final String? closedText;

  const OpenClosedBadge({
    super.key,
    required this.isOpen,
    this.openText,
    this.closedText,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? AppTheme.accentGreen : AppTheme.accentRed;
    final text = isOpen
        ? (openText ?? 'متاح')
        : (closedText ?? 'غير متاح');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTheme.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 20. IMAGE BASE64 WIDGET — with error handling & placeholder
// ═══════════════════════════════════════════════════════════════
class ImageBase64Widget extends StatelessWidget {
  final String? base64String;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final IconData placeholderIcon;
  final Color? placeholderColor;

  const ImageBase64Widget({
    super.key,
    this.base64String,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppTheme.radiusMd)),
    this.placeholderIcon = Icons.image_outlined,
    this.placeholderColor,
  });

  @override
  Widget build(BuildContext context) {
    final pColor =
        placeholderColor ?? AppTheme.adaptiveTextHint(context);

    if (base64String == null || base64String!.isEmpty) {
      return _buildPlaceholder(pColor);
    }

    try {
      final bytes = base64Decode(base64String!);
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildPlaceholder(pColor),
        ),
      );
    } catch (_) {
      return _buildPlaceholder(pColor);
    }
  }

  Widget _buildPlaceholder(Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(placeholderIcon, size: 32, color: color),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 21. ADMIN TAB BUTTON — icon + label + isSelected + badge count
// ═══════════════════════════════════════════════════════════════
class AdminTabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final int badgeCount;

  const AdminTabButton({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.animNormal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.2 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: isSelected
              ? Border.all(color: primaryColor.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? primaryColor
                  : AppTheme.adaptiveTextSecondary(context),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: isSelected
                    ? primaryColor
                    : AppTheme.adaptiveTextSecondary(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentRed,
                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                ),
                constraints: const BoxConstraints(minWidth: 20),
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textOnPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 22. CONFIRMATION DIALOG
// ═══════════════════════════════════════════════════════════════
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final IconData? icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'تأكيد',
    this.cancelText = 'إلغاء',
    this.confirmColor,
    this.icon,
  });

  Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = confirmColor ?? AppTheme.accentRed;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
          ],
          Text(title, style: AppTheme.headingSmall),
        ],
      ),
      content: Text(
        message,
        style: AppTheme.bodyMedium.copyWith(
          color: AppTheme.adaptiveTextSecondary(context),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: AppTheme.labelMedium.copyWith(
              color: AppTheme.adaptiveTextSecondary(context),
            ),
          ),
        ),
        AppButton(
          text: confirmText,
          backgroundColor: color,
          onPressed: () => Navigator.of(context).pop(true),
          isSmall: true,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 23. SEARCH BAR
// ═══════════════════════════════════════════════════════════════
class SearchBar extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const SearchBar({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: readOnly ? onTap : null,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isDark ? AppTheme.darkDivider : AppTheme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(
              Icons.search_rounded,
              size: 20,
              color: AppTheme.adaptiveTextHint(context),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: readOnly
                  ? Text(
                      hint ?? 'بحث...',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.adaptiveTextHint(context),
                      ),
                    )
                  : TextField(
                      controller: controller,
                      onChanged: onChanged,
                      style: AppTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: hint ?? 'بحث...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintStyle: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.adaptiveTextHint(context),
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 24. DATA TABLE WIDGET — simple admin data table
// ═══════════════════════════════════════════════════════════════
class DataTableWidget extends StatelessWidget {
  final List<String> headers;
  final List<List<Widget>> rows;
  final EdgeInsets? margin;

  const DataTableWidget({
    super.key,
    required this.headers,
    required this.rows,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg =
        isDark ? AppTheme.darkSurface : AppTheme.backgroundLight;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.adaptiveCardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: isDark
            ? Border.all(color: AppTheme.darkDivider.withValues(alpha: 0.5))
            : null,
        boxShadow: isDark ? null : AppTheme.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(headerBg),
          headingTextStyle: AppTheme.labelMedium.copyWith(
            color: AppTheme.adaptiveTextSecondary(context),
            fontSize: 12,
          ),
          dataTextStyle: AppTheme.bodyMedium.copyWith(
            color: AppTheme.adaptiveTextPrimary(context),
          ),
          columnSpacing: 20,
          horizontalMargin: 16,
          columns: headers
              .map((h) => DataColumn(
                    label: Text(h, style: AppTheme.labelMedium.copyWith(
                      fontSize: 12,
                      color: AppTheme.adaptiveTextSecondary(context),
                    )),
                  ))
              .toList(),
          rows: rows
              .map((cells) => DataRow(
                    cells: cells
                        .map((cell) => DataCell(cell))
                        .toList(),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 25. FILTER CHIPS — row of admin filter chips
// ═══════════════════════════════════════════════════════════════
class FilterChips extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Color? selectedColor;

  const FilterChips({
    super.key,
    required this.labels,
    this.selectedIndex = 0,
    required this.onSelected,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final chipColor = selectedColor ?? Theme.of(context).colorScheme.primary;

          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: AppTheme.animFast,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? chipColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                border: Border.all(
                  color: isSelected ? chipColor : AppTheme.adaptiveDivider(context),
                ),
              ),
              child: Center(
                child: Text(
                  labels[index],
                  style: AppTheme.bodySmall.copyWith(
                    color: isSelected
                        ? chipColor
                        : AppTheme.adaptiveTextSecondary(context),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 26. LOADING OVERLAY — full-screen loading with message
// ═══════════════════════════════════════════════════════════════
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.4),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  color: AppTheme.adaptiveCardColor(context),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppTheme.mediumShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.adaptiveTextPrimary(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 27. COPY BUTTON — copies text to clipboard with feedback
// ═══════════════════════════════════════════════════════════════
class CopyButton extends StatefulWidget {
  final String textToCopy;
  final String? label;
  final IconData icon;
  final Color? color;

  const CopyButton({
    super.key,
    required this.textToCopy,
    this.label,
    this.icon = Icons.copy_rounded,
    this.color,
  });

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.textToCopy));
    if (!mounted) return;
    setState(() => _copied = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم النسخ'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: _copy,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: AnimatedContainer(
        duration: AppTheme.animFast,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: _copied ? 0.15 : 0.06),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _copied ? Icons.check_rounded : widget.icon,
              size: 16,
              color: _copied ? AppTheme.accentGreen : color,
            ),
            if (widget.label != null) ...[
              const SizedBox(width: 6),
              Text(
                widget.label!,
                style: AppTheme.bodySmall.copyWith(
                  color: _copied ? AppTheme.accentGreen : color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
