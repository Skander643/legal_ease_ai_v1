import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final IconData? icon;
  final String? title;
  final double elevation;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.icon,
    this.title,
    this.elevation = 2,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: elevation,
        color: backgroundColor,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null || title != null) ...[
                Row(
                  children: [
                    if (icon != null)
                      Icon(
                        icon,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    if (icon != null && title != null)
                      const SizedBox(width: 12),
                    if (title != null)
                      Text(
                        title!,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
