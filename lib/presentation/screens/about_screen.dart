import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gap/gap.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('About App')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Gap(20),
            // Section 1: App Information
            Image.asset('assets/images/logo.png', height: 100),
            const Gap(16),
            Text(
              'CalcLab',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              'v1.0.0',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            const Gap(16),
            Text(
              'CalcLab is a modern Flutter-based calculator app featuring standard, scientific, and EMI/interest calculators with an elegant user experience.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const Gap(32),

            // Section 2: Developer Information
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Developed by',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(16),
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(
                        'assets/images/profile_pic.png',
                      ),
                    ),
                    const Gap(16),
                    Text(
                      'Aarambha Aryal',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'Flutter Developer & Frontend Developer',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Gap(8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: theme.colorScheme.secondary,
                        ),
                        const Gap(4),
                        Text('Nepal', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                    const Gap(16),
                    Text(
                      'I am a Flutter and Frontend Developer from Nepal, passionate about building clean, efficient, and user-friendly applications.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const Gap(24),
                    // Contact Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildContactButton(
                          context,
                          icon: Icons.phone,
                          label: 'Call',
                          onTap: () => _launchUrl('tel:+9779855062769'),
                        ),
                        _buildContactButton(
                          context,
                          icon: Icons.language,
                          label: 'Website',
                          onTap: () =>
                              _launchUrl('https://aarambhaaryal.com.np/'),
                        ),
                      ],
                    ),
                    const Gap(16),
                    Text('+977 9855062769', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            const Gap(40),

            // Section 3: Footer
            Text(
              '© 2025 Aarambha. All rights reserved.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}
