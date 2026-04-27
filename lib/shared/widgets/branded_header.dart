import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/app_providers.dart';

class BrandedHeader extends ConsumerWidget {
  const BrandedHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(clientConfigProvider);
    final clientImageUrl = config?.clientImageUrl;
    final clientName = config?.clientName ?? '';

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
          _buildClientLogo(context, clientImageUrl, clientName),
        ],
      ),
    );
  }

  Widget _buildClientLogo(
      BuildContext context, String? imageUrl, String clientName) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        height: 28,
        fit: BoxFit.contain,
        placeholder: (_, __) => Text(
          clientName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        errorWidget: (_, __, ___) => Text(
          clientName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Text(
      clientName,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
