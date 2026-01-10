import 'package:flutter/material.dart';

/// PRO paywall bottom sheet for premium features
class PaywallSheet extends StatelessWidget {
  final String featureName;
  final VoidCallback? onUnlock;

  const PaywallSheet({
    super.key,
    required this.featureName,
    this.onUnlock,
  });

  static void show({
    required BuildContext context,
    required String featureName,
    VoidCallback? onUnlock,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaywallSheet(
        featureName: featureName,
        onUnlock: onUnlock,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // PRO badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE4B85F), Color(0xFFD4A84F)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'SOLAREKLIPS PRO',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'Unlock $featureName',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'Get full access to advanced photography tools, practice modes, and premium features.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade400,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Features list
              const _FeatureItem(
                icon: Icons.camera_enhance,
                title: 'Manual Camera Controls',
                description: 'Platform-optimized controls for perfect shots',
              ),
              const SizedBox(height: 16),
              const _FeatureItem(
                icon: Icons.science,
                title: 'Practice Mode',
                description: 'Simulated eclipses to test your settings',
              ),
              const SizedBox(height: 16),
              const _FeatureItem(
                icon: Icons.layers,
                title: 'Advanced Overlays',
                description: 'Real-time AR guides and phase indicators',
              ),
              const SizedBox(height: 16),
              const _FeatureItem(
                icon: Icons.accessibility_new,
                title: 'Unlimited Access',
                description: 'All future PRO features included',
              ),

              const SizedBox(height: 32),

              // Pricing options
              _PricingOption(
                title: 'Full Access',
                price: '€6.99',
                description: 'One-time unlock for all PRO features',
                isRecommended: true,
                onTap: () {
                  _handlePurchase(context, 'full');
                },
              ),

              const SizedBox(height: 12),

              _PricingOption(
                title: 'Event Pass',
                price: '€2.99',
                description: 'Unlock for one specific eclipse event',
                isRecommended: false,
                onTap: () {
                  _handlePurchase(context, 'event');
                },
              ),

              const SizedBox(height: 24),

              // Close button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Maybe Later'),
              ),

              const SizedBox(height: 8),

              // Terms
              Text(
                'One-time payment • No subscriptions • Cancel anytime',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePurchase(BuildContext context, String type) {
    // Mock purchase flow - will integrate with in_app_purchase package later
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Welcome to PRO!'),
        content: Text(
          type == 'full'
              ? 'Full access unlocked! All PRO features are now available.'
              : 'Event Pass unlocked! PRO features available for this event.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close paywall
              onUnlock?.call();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE4B85F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFE4B85F),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PricingOption extends StatelessWidget {
  final String title;
  final String price;
  final String description;
  final bool isRecommended;
  final VoidCallback onTap;

  const _PricingOption({
    required this.title,
    required this.price,
    required this.description,
    required this.isRecommended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isRecommended
              ? const Color(0xFFE4B85F).withOpacity(0.15)
              : Colors.grey.shade900,
          border: Border.all(
            color:
                isRecommended ? const Color(0xFFE4B85F) : Colors.grey.shade800,
            width: isRecommended ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4B85F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'BEST VALUE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE4B85F),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
