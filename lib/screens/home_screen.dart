import 'package:flutter/material.dart';
import '../services/auth_repository.dart';
import '../services/call_log_repository.dart';
import '../theme.dart';
import '../widgets/call_log_status_banner.dart';
import '../widgets/call_tile.dart';
import '../widgets/neu.dart';
import 'app_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = CallLogRepository.instance;
  final _auth = AuthRepository.instance;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChanged);
    _auth.addListener(_onRepoChanged);
    if (_repo.status == CallLogStatus.idle) _repo.refresh();
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    _auth.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  ({String greeting, String date}) _greetingAndDate() {
    final now = DateTime.now();
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final greeting = now.hour < 12 ? 'Good morning' : (now.hour < 17 ? 'Good afternoon' : 'Good evening');
    final date = '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
    return (greeting: greeting, date: date);
  }

  String _initialsFor(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return 'R';
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final greetingAndDate = _greetingAndDate();
    final calls = _repo.calls;
    final hasData = _repo.status == CallLogStatus.loaded;
    final today = calls.where((c) => c.day == 'Today');
    final todaysCalls = hasData ? today.length : null;
    final missedToday = hasData ? today.where((c) => c.type == 'missed').length : null;
    final incomingToday = hasData ? today.where((c) => c.type == 'incoming').length : null;
    final outgoingToday = hasData ? today.where((c) => c.type == 'outgoing').length : null;
    final recent = calls.take(4).toList();
    final needsStatusBanner = _repo.status == CallLogStatus.permissionDenied ||
        _repo.status == CallLogStatus.unsupported ||
        _repo.status == CallLogStatus.error;
    final businessName = _auth.currentUser?.businessName ?? 'Ringlead';

    return RefreshIndicator(
      onRefresh: _repo.refresh,
      color: AppColors.blue,
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(kGutter, 14, kGutter, 28),
        children: [
          Row(
            children: [
              Avatar(initials: _initialsFor(businessName), size: 46, fontSize: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greetingAndDate.greeting, style: AppText.greeting),
                    const SizedBox(height: 2),
                    Text(businessName, style: AppText.h1, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  NeuCircleIcon(
                    icon: Icons.notifications_none_rounded,
                    color: AppColors.ink,
                    size: 42,
                    iconSize: 20,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No new notifications yet.')),
                    ),
                  ),
                  Positioned(
                    top: 9,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SearchField(
            hint: 'Search customers, numbers',
            readOnly: true,
            onTap: () => TabNavigator.maybeOf(context)?.goToTab(1),
          ),
          const SizedBox(height: 18),
          _TodayCard(
            date: greetingAndDate.date,
            total: todaysCalls,
            missed: missedToday,
            incoming: incomingToday,
            outgoing: outgoingToday,
          ),
          const SizedBox(height: 18),
          const SectionLabel(label: 'Quick actions'),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.phone_in_talk_rounded,
                  color: AppColors.greenInk,
                  label: 'Call log',
                  onTap: () => TabNavigator.maybeOf(context)?.goToTab(1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.flag_rounded,
                  color: AppColors.violetInk,
                  label: 'Leads',
                  onTap: () => TabNavigator.maybeOf(context)?.goToTab(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.graphic_eq_rounded,
                  color: AppColors.blueInk,
                  label: 'Recordings',
                  onTap: () => TabNavigator.maybeOf(context)?.goToTab(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionLabel(
            label: 'Recent calls',
            action: 'See all',
            onAction: () => TabNavigator.maybeOf(context)?.goToTab(1),
          ),
          if (_repo.status == CallLogStatus.loading && calls.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(child: CircularProgressIndicator(color: AppColors.blue, strokeWidth: 2.6)),
            )
          else if (needsStatusBanner)
            CallLogStatusBanner(status: _repo.status, errorMessage: _repo.errorMessage, onRetry: _repo.refresh)
          else if (recent.isEmpty)
            const EmptyStateNote(
              icon: Icons.history_rounded,
              title: 'No calls yet',
              message: 'Make or receive a call and it will show up here automatically.',
            )
          else
            ...recent.map(
              (call) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CallListTile(call: call, showMarkers: false),
              ),
            ),
        ],
      ),
    );
  }
}

/// Hero summary for the current day: one big number plus the breakdown.
class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.date,
    required this.total,
    required this.missed,
    required this.incoming,
    required this.outgoing,
  });

  final String date;
  final int? total;
  final int? missed;
  final int? incoming;
  final int? outgoing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2F6BFF), Color(0xFF1B3FB8)],
        ),
        boxShadow: AppShadows.tinted(AppColors.blue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TODAY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              Text(
                date,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.85)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                total?.toString() ?? '—',
                style: const TextStyle(
                  fontSize: 42,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.6,
                  color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                total == 1 ? 'call logged' : 'calls logged',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.85)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _MiniStat(
                  icon: Icons.call_received_rounded,
                  value: incoming,
                  label: 'Incoming',
                  onTap: () => TabNavigator.maybeOf(context)?.goToCallsFiltered('incoming'),
                ),
                _divider(),
                _MiniStat(
                  icon: Icons.call_made_rounded,
                  value: outgoing,
                  label: 'Outgoing',
                  onTap: () => TabNavigator.maybeOf(context)?.goToCallsFiltered('outgoing'),
                ),
                _divider(),
                _MiniStat(
                  icon: Icons.call_missed_rounded,
                  value: missed,
                  label: 'Missed',
                  onTap: () => TabNavigator.maybeOf(context)?.goToCallsFiltered('missed'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.18));
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.value, required this.label, this.onTap});

  final IconData icon;
  final int? value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.8)),
                const SizedBox(width: 5),
                Text(
                  value?.toString() ?? '—',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.78)),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.color, required this.label, this.onTap});

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14),
      radius: 16,
      child: Column(
        children: [
          IconTile(icon: icon, color: color, size: 40, iconSize: 20),
          const SizedBox(height: 9),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}
