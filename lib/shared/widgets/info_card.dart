import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final List<InfoCardRow> rows;
  final Widget? header;
  final EdgeInsetsGeometry? padding;

  const InfoCard({
    super.key,
    required this.rows,
    this.header,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (header != null) ...[
              header!,
              const Divider(height: 24),
            ],
            ...rows.map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (row.icon != null) ...[
                        Icon(row.icon, size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF9E9E9E),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              row.value ?? '—',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class InfoCardRow {
  final String label;
  final String? value;
  final IconData? icon;

  const InfoCardRow({
    required this.label,
    this.value,
    this.icon,
  });
}
