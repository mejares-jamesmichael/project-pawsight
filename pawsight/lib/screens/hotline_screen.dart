import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_constants.dart';
import '../providers/hotline_provider.dart';
import '../models/vet_contact.dart';

/// Hotline screen - displays vet emergency contacts
class HotlineScreen extends StatefulWidget {
  const HotlineScreen({super.key});

  @override
  State<HotlineScreen> createState() => _HotlineScreenState();
}

class _HotlineScreenState extends State<HotlineScreen> {
  @override
  void initState() {
    super.initState();
    // Load vet contacts when screen is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HotlineProvider>().loadContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<HotlineProvider>();

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FIcons.x, size: 48, color: Colors.red),
              const SizedBox(height: AppSpacing.lg),
              Text(
                provider.error!,
                style: theme.typography.base.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              FButton(
                onPress: () {
                  provider.clearError();
                  provider.loadContacts();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.isLoading) {
      return const Center(child: FCircularProgress());
    }

    if (provider.contacts.isEmpty) {
      return _EmptyState(theme: theme);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Banner
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(FIcons.info, color: Colors.red, size: 24),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Assistance',
                        style: theme.typography.base.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'For life-threatening situations, call 24/7 emergency clinics immediately.',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Emergency Contacts Section
          if (provider.emergencyContacts.isNotEmpty) ...[
            _SectionHeader(
              title: '🚨 Emergency Services (24/7)',
              subtitle: '${provider.emergencyContacts.length} available',
              theme: theme,
            ),
            const SizedBox(height: AppSpacing.md),
            ...provider.emergencyContacts.map(
              (contact) => _VetContactCard(
                contact: contact,
                isEmergency: true,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Regular Contacts Section
          if (provider.regularContacts.isNotEmpty) ...[
            _SectionHeader(
              title: '🏥 General Clinics',
              subtitle: '${provider.regularContacts.length} available',
              theme: theme,
            ),
            const SizedBox(height: AppSpacing.md),
            ...provider.regularContacts.map(
              (contact) => _VetContactCard(
                contact: contact,
                isEmergency: false,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Info Notice
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colors.secondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colors.border),
            ),
            child: Row(
              children: [
                Icon(FIcons.info, color: theme.colors.mutedForeground, size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Metro Manila area veterinary clinics. Always call ahead to confirm availability and fees.',
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final FThemeData theme;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.typography.lg.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: theme.typography.xs.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

/// Individual vet contact card
class _VetContactCard extends StatelessWidget {
  final VetContact contact;
  final bool isEmergency;

  const _VetContactCard({
    required this.contact,
    required this.isEmergency,
  });

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        // Fallback or Toast
      }
    }
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Pet Care Inquiry',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openSocialMedia(BuildContext context, String url, String platform) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openMaps(BuildContext context, String address) async {
    final query = Uri.encodeComponent(address);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: FCard(
        title: Row(
          children: [
            Expanded(
              child: Text(
                contact.clinicName,
                style: theme.typography.base.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isEmergency)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '24/7',
                  style: theme.typography.xs.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(
              icon: FIcons.phone,
              text: contact.phoneNumber,
              theme: theme,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (contact.email != null && contact.email!.isNotEmpty) ...[
              _InfoRow(
                icon: FIcons.mail,
                text: contact.email!,
                theme: theme,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            _InfoRow(
              icon: FIcons.mapPin,
              text: contact.address,
              theme: theme,
            ),
            if (contact.notes != null && contact.notes!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _InfoRow(
                icon: FIcons.info,
                text: contact.notes!,
                theme: theme,
                isNote: true,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FButton(
                onPress: () => _showContactOptions(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(FIcons.messageCircle, size: 18),
                    SizedBox(width: AppSpacing.sm),
                    Text('Contact Clinic'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    final theme = context.theme;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the sheet to expand to fit content
      backgroundColor: theme.colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact ${contact.clinicName}',
                  style: theme.typography.lg.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                _AnimatedOptionTile(
                  index: 0,
                  icon: FIcons.phone,
                  label: 'Call ${contact.phoneNumber}',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    _makePhoneCall(context, contact.phoneNumber);
                  },
                ),
                
                if (contact.email != null && contact.email!.isNotEmpty)
                  _AnimatedOptionTile(
                    index: 1,
                    icon: FIcons.mail,
                    label: 'Send Email',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      _sendEmail(context, contact.email!);
                    },
                  ),

                _AnimatedOptionTile(
                  index: 2,
                  icon: FIcons.mapPin,
                  label: 'Get Directions',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _openMaps(context, contact.address);
                  },
                ),

                if (contact.facebookUrl != null && contact.facebookUrl!.isNotEmpty)
                  _AnimatedOptionTile(
                    index: 3,
                    icon: FIcons.facebook,
                    label: 'Visit Facebook Page',
                    color: AppColors.facebook,
                    onTap: () {
                      Navigator.pop(context);
                      _openSocialMedia(context, contact.facebookUrl!, 'Facebook');
                    },
                  ),
                  
                if (contact.instagramUrl != null && contact.instagramUrl!.isNotEmpty)
                  _AnimatedOptionTile(
                    index: 4,
                    icon: FIcons.instagram,
                    label: 'Visit Instagram',
                    color: AppColors.instagram,
                    onTap: () {
                      Navigator.pop(context);
                      _openSocialMedia(context, contact.instagramUrl!, 'Instagram');
                    },
                  ),
                  
                const SizedBox(height: AppSpacing.lg),
                FButton(
                  onPress: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedOptionTile extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AnimatedOptionTile({
    required this.index,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: _ContactOptionTile(
        icon: icon,
        label: label,
        color: color,
        onTap: onTap,
      ),
    );
  }
}

class _ContactOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactOptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colors.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  label,
                  style: theme.typography.base.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              Icon(FIcons.chevronRight, size: 16, color: theme.colors.mutedForeground),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final FThemeData theme;
  final bool isNote;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.theme,
    this.isNote = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: theme.colors.mutedForeground),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: theme.typography.sm.copyWith(
              color: isNote ? theme.colors.mutedForeground : theme.colors.foreground,
              fontStyle: isNote ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final FThemeData theme;

  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FIcons.phoneOff, size: 48, color: theme.colors.mutedForeground),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No vet contacts found',
              style: theme.typography.base.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add your local veterinary clinics to get started',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}