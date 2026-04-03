import 'package:flutter/material.dart';

class BrandedHeader extends StatelessWidget {
  const BrandedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/images/kelsa_logo.png',
            height: 24,
            errorBuilder: (_, __, ___) => Text(
              'Kelsa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Image.asset(
            'assets/images/ansr_logo_full.png',
            height: 28,
            errorBuilder: (_, __, ___) => Text(
              'ANSR',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
