import 'package:flutter/material.dart';
import '../models/api_exception.dart';
import '../services/auth_repository.dart';
import '../theme.dart';
import '../widgets/neu.dart';
import 'subscription_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label — coming soon.')));
  }

  Future<void> _editProfile(BuildContext context) async {
    final user = AuthRepository.instance.currentUser;
    if (user == null) return;

    final businessNameController = TextEditingController(text: user.businessName);
    final phoneController = TextEditingController(text: user.phone ?? '');

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _EditProfileSheet(
        businessNameController: businessNameController,
        phoneController: phoneController,
      ),
    );

    if (saved == true && context.mounted) {
      try {
        await AuthRepository.instance.updateProfile(
          businessName: businessNameController.text.trim(),
          phone: phoneController.text.trim(),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
        }
      } on ApiException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
        }
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ConfirmLogoutSheet(),
    );
    if (confirmed != true) return;
    await AuthRepository.instance.logout();
    // The root session gate reacts to the signedOut status and swaps to LoginScreen.
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthRepository.instance,
      builder: (context, _) {
        final user = AuthRepository.instance.currentUser;
        final initials = _initialsFor(user?.businessName ?? '');
        final isPro = user?.isPro ?? false;

        return ListView(
          padding: const EdgeInsets.fromLTRB(kGutter, 14, kGutter, 28),
          children: [
            const ScreenHeader(title: 'Profile', subtitle: 'Account, plan and app settings'),
            const SizedBox(height: 16),
            NeuCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Avatar(initials: initials, size: 54, fontSize: 18),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.businessName ?? '—',
                          style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: AppColors.ink),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        if ((user?.email ?? '').isNotEmpty)
                          Text(user!.email, style: AppText.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                        if ((user?.phone ?? '').isNotEmpty)
                          Text(user!.phone!, style: AppText.mono(12.5, color: AppColors.inkSoft), maxLines: 1),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _TextAction(label: 'Edit', onTap: () => _editProfile(context)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            NeuCard(
              padding: const EdgeInsets.all(16),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
              child: Row(
                children: [
                  IconTile(
                    icon: Icons.workspace_premium_rounded,
                    color: isPro ? AppColors.amberInk : AppColors.inkSoft,
                    size: 44,
                    iconSize: 21,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isPro ? 'Ringlead Pro' : 'Ringlead Free',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                            ),
                            const SizedBox(width: 8),
                            StatusPill(
                              dense: true,
                              label: isPro ? 'PRO' : 'FREE',
                              color: isPro ? AppColors.greenInk : AppColors.inkSoft,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(isPro ? 'All features unlocked' : 'Upgrade to unlock recordings and broadcasts', style: AppText.caption),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.inkFaint),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionLabel(label: 'Preferences'),
            _SettingsGroup(
              rows: [
                _SettingsRow(icon: Icons.call_rounded, label: 'Call settings', onTap: () => _comingSoon(context, 'Call settings')),
                _SettingsRow(icon: Icons.mic_rounded, label: 'Recording settings', onTap: () => _comingSoon(context, 'Recording settings')),
                _SettingsRow(icon: Icons.description_rounded, label: 'WhatsApp templates', onTap: () => _comingSoon(context, 'WhatsApp templates')),
                _SettingsRow(icon: Icons.notifications_rounded, label: 'Notifications', onTap: () => _comingSoon(context, 'Notifications')),
              ],
            ),
            const SizedBox(height: 22),
            const SectionLabel(label: 'Data'),
            _SettingsGroup(
              rows: [
                _SettingsRow(icon: Icons.cloud_rounded, label: 'Backup and sync', onTap: () => _comingSoon(context, 'Backup and sync')),
              ],
            ),
            const SizedBox(height: 22),
            const SectionLabel(label: 'Support'),
            _SettingsGroup(
              rows: [
                _SettingsRow(icon: Icons.help_rounded, label: 'Help and support', onTap: () => _comingSoon(context, 'Help and support')),
                _SettingsRow(
                  icon: Icons.logout_rounded,
                  label: 'Log out',
                  color: AppColors.redInk,
                  showChevron: false,
                  onTap: () => _logout(context),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Ringlead v2.4.1', textAlign: TextAlign.center, style: AppText.tiny),
          ],
        );
      },
    );
  }

  String _initialsFor(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '—';
    final letters = words.take(2).map((w) => w[0].toUpperCase()).join();
    return letters.isEmpty ? '—' : letters;
  }
}

/// White card holding settings rows separated by hairlines.
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: neuRaised(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusCard),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const Padding(padding: EdgeInsets.only(left: 58), child: Divider(height: 1)),
              rows[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.blueSoft,
      borderRadius: BorderRadius.circular(kRadiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(kRadiusPill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.blueInk)),
        ),
      ),
    );
  }
}

class _EditProfileSheet extends StatelessWidget {
  const _EditProfileSheet({required this.businessNameController, required this.phoneController});

  final TextEditingController businessNameController;
  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetGrabber(),
            const Text('Edit profile', style: AppText.h1),
            const SizedBox(height: 18),
            LabeledField(
              label: 'Business name',
              child: TextField(
                controller: businessNameController,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.ink),
                decoration: const InputDecoration(border: InputBorder.none, isCollapsed: true),
              ),
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: 'Phone',
              child: TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.ink),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintText: '+91 98765 43210',
                  hintStyle: TextStyle(color: AppColors.inkFaint, fontWeight: FontWeight.w400),
                ),
              ),
            ),
            const SizedBox(height: 22),
            NeuPrimaryButton(label: 'Save changes', onPressed: () => Navigator.of(context).pop(true)),
          ],
        ),
      ),
    );
  }
}

class _ConfirmLogoutSheet extends StatelessWidget {
  const _ConfirmLogoutSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetGrabber(),
          const Text('Log out of Ringlead?', style: AppText.h1),
          const SizedBox(height: 6),
          const Text('Your call notes and leads stay saved to your account.', style: AppText.caption),
          const SizedBox(height: 22),
          NeuPrimaryButton(
            label: 'Log out',
            color: AppColors.redInk,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: 10),
          NeuSecondaryButton(
            label: 'Cancel',
            color: AppColors.inkSoft,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.color = AppColors.blueInk,
    this.showChevron = true,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            IconTile(icon: icon, color: color, size: 34, iconSize: 17, radius: 10),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: color == AppColors.redInk ? color : AppColors.ink,
                ),
              ),
            ),
            if (showChevron) const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.inkFaint),
          ],
        ),
      ),
    );
  }
}
