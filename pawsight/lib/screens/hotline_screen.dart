import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        title: const Text('Vet Hotline'),
        backgroundColor: theme.colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: provider.error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FIcons.x,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      style: theme.typography.base.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
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
            )
          : provider.isLoading
              ? const Center(child: FCircularProgress())
              : provider.contacts.isEmpty
                  ? _EmptyState(theme: theme)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              FIcons.info,
                              color: Colors.red,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
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
                                  const SizedBox(height: 4),
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
                      const SizedBox(height: 24),

                      // Emergency Contacts Section
                      if (provider.emergencyContacts.isNotEmpty) ...[
                        _SectionHeader(
                          title: '🚨 Emergency Services (24/7)',
                          subtitle:
                              '${provider.emergencyContacts.length} available',
                          theme: theme,
                        ),
                        const SizedBox(height: 12),
                        ...provider.emergencyContacts.map(
                          (contact) => _VetContactCard(
                            contact: contact,
                            isEmergency: true,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Regular Contacts Section
                      if (provider.regularContacts.isNotEmpty) ...[
                        _SectionHeader(
                          title: '🏥 General Clinics',
                          subtitle:
                              '${provider.regularContacts.length} available',
                          theme: theme,
                        ),
                        const SizedBox(height: 12),
                        ...provider.regularContacts.map(
                          (contact) => _VetContactCard(
                            contact: contact,
                            isEmergency: false,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Info Notice
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colors.secondary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              FIcons.info,
                              color: theme.colors.mutedForeground,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
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
          ),
        ),
        const SizedBox(height: 4),
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
      if (context.mounted) {
        showFToast(
          context: context,
          alignment: FToastAlignment.bottomCenter,
          icon: const Icon(FIcons.phone),
          title: const Text('Opening dialer...'),
          duration: const Duration(seconds: 2),
        );
      }
    } else {
      if (context.mounted) {
        showFToast(
          context: context,
          alignment: FToastAlignment.bottomCenter,
          icon: const Icon(FIcons.triangleAlert),
          title: const Text('Unable to open dialer'),
          description: const Text('Please check your device settings.'),
          duration: const Duration(seconds: 3),
        );
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
      if (context.mounted) {
        showFToast(
          context: context,
          alignment: FToastAlignment.bottomCenter,
          icon: const Icon(FIcons.mail),
          title: const Text('Opening email app...'),
          duration: const Duration(seconds: 2),
        );
      }
    } else {
      if (context.mounted) {
        showFToast(
          context: context,
          alignment: FToastAlignment.bottomCenter,
          icon: const Icon(FIcons.triangleAlert),
          title: const Text('Unable to open email'),
          description: const Text('No email app found on your device.'),
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _openSocialMedia(BuildContext context, String url, String platform) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (context.mounted) {
        showFToast(
          context: context,
          alignment: FToastAlignment.bottomCenter,
          icon: Icon(platform == 'Facebook' ? FIcons.facebook : FIcons.instagram),
          title: Text('Opening $platform...'),
          duration: const Duration(seconds: 2),
        );
      }
    } else {
      if (context.mounted) {
        showFToast(
          context: context,
          alignment: FToastAlignment.bottomCenter,
          icon: const Icon(FIcons.triangleAlert),
          title: Text('Unable to open $platform'),
          description: const Text('Please check your internet connection.'),
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _openMaps(BuildContext context, String address) async {
    final query = Uri.encodeComponent(address);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (context.mounted) {
        showFToast(
          context: context,
          alignment: FToastAlignment.bottomCenter,
          icon: const Icon(FIcons.mapPin),
          title: const Text('Opening Google Maps...'),
          duration: const Duration(seconds: 2),
        );
      }
    } else {
      if (context.mounted) {
        showFToast(
          context: context,
          alignment: FToastAlignment.bottomCenter,
          icon: const Icon(FIcons.triangleAlert),
          title: const Text('Unable to open maps'),
          description: const Text('Please check your internet connection.'),
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accentColor = isEmergency ? Colors.red : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEmergency
              ? Colors.red.withValues(alpha: 0.3)
              : theme.colors.border,
          width: isEmergency ? 2 : 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Accent Color Bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),

            // Card Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Clinic Name + Badge
                    Row(
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                              ),
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
                    const SizedBox(height: 12),

                    // Phone Number
                    _InfoRow(
                      icon: FIcons.phone,
                      text: contact.phoneNumber,
                      theme: theme,
                    ),
                    const SizedBox(height: 8),

                    // Email (if available)
                    if (contact.email != null &&
                        contact.email!.isNotEmpty) ...[
                      _InfoRow(
                        icon: FIcons.mail,
                        text: contact.email!,
                        theme: theme,
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Address
                    _InfoRow(
                      icon: FIcons.mapPin,
                      text: contact.address,
                      theme: theme,
                    ),

                    // Notes (if available)
                    if (contact.notes != null &&
                        contact.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: FIcons.info,
                        text: contact.notes!,
                        theme: theme,
                        isNote: true,
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Action Buttons
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ActionButton(
                          label: 'Call',
                          icon: FIcons.phone,
                          color: accentColor,
                          onTap: () => _makePhoneCall(context, contact.phoneNumber),
                        ),
                        if (contact.email != null && contact.email!.isNotEmpty)
                          _ActionButton(
                            label: 'Email',
                            icon: FIcons.mail,
                            color: Colors.orange,
                            onTap: () => _sendEmail(context, contact.email!),
                          ),
                        _ActionButton(
                          label: 'Location',
                          icon: FIcons.mapPin,
                          color: Colors.green,
                          onTap: () => _openMaps(context, contact.address),
                        ),
                        if (contact.facebookUrl != null && contact.facebookUrl!.isNotEmpty)
                          _ActionButton(
                            label: 'Facebook',
                            icon: FIcons.facebook,
                            color: const Color(0xFF1877F2), // Facebook blue
                            onTap: () => _openSocialMedia(context, contact.facebookUrl!, 'Facebook'),
                          ),
                        if (contact.instagramUrl != null && contact.instagramUrl!.isNotEmpty)
                          _ActionButton(
                            label: 'Instagram',
                            icon: FIcons.instagram,
                            color: const Color(0xFFE4405F), // Instagram pink
                            onTap: () => _openSocialMedia(context, contact.instagramUrl!, 'Instagram'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Info row with icon and text
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
        Icon(
          icon,
          size: 16,
          color: theme.colors.mutedForeground,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.typography.sm.copyWith(
              color: isNote
                  ? theme.colors.mutedForeground
                  : theme.colors.foreground,
              fontStyle: isNote ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
}

/// Action button widget
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.typography.sm.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state when no contacts are available
class _EmptyState extends StatelessWidget {
  final FThemeData theme;

  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FIcons.phoneOff,
              size: 48,
              color: theme.colors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              'No vet contacts found',
              style: theme.typography.base.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
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
