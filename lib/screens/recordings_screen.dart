import 'package:flutter/material.dart';
import '../services/recording_repository.dart';
import '../theme.dart';
import '../widgets/neu.dart';
import 'call_detail_screen.dart' show AudioPlayerRow, formatSeconds;

class RecordingsScreen extends StatefulWidget {
  const RecordingsScreen({super.key});

  @override
  State<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends State<RecordingsScreen> {
  String _query = '';
  final _repo = RecordingRepository.instance;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChanged);
    // Only scans if access was granted before; the user asks for it via the button below.
    if (_repo.status == RecordingStatus.idle) _repo.refresh();
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final all = _repo.recordings;
    final q = _query.trim().toLowerCase();
    final matches = all.where((r) {
      return q.isEmpty || r.title.toLowerCase().contains(q) || r.number.contains(q) || r.fileName.toLowerCase().contains(q);
    }).toList();

    return RefreshIndicator(
      onRefresh: () => _repo.refresh(),
      color: AppColors.blue,
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(kGutter, 14, kGutter, 28),
        children: [
          ScreenHeader(
            title: 'Recordings',
            subtitle: _repo.status == RecordingStatus.loaded
                ? '${all.length} recording${all.length == 1 ? '' : 's'} on this phone'
                : 'Call audio saved by your dialer',
          ),
          const SizedBox(height: 16),
          SearchField(hint: 'Search recordings', onChanged: (v) => setState(() => _query = v)),
          const SizedBox(height: 18),
          if (_repo.status == RecordingStatus.loading && all.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Center(child: CircularProgressIndicator(color: AppColors.blue, strokeWidth: 2.6)),
            )
          else if (_repo.status == RecordingStatus.permissionDenied)
            _PermissionCard(onAllow: () => _repo.refresh(requestPermission: true), onOpenSettings: _repo.openSettings)
          else if (_repo.status == RecordingStatus.unsupported)
            const EmptyStateNote(
              icon: Icons.phone_android_rounded,
              title: 'Android only',
              message: 'Call recordings are available on Android phones only.',
            )
          else if (_repo.status == RecordingStatus.error)
            EmptyStateNote(
              icon: Icons.error_outline_rounded,
              title: 'Could not read recordings',
              message: _repo.errorMessage ?? 'Pull down to try again.',
            )
          else if (all.isEmpty)
            const _NoRecordingsHelp()
          else if (matches.isEmpty)
            const EmptyStateNote(
              icon: Icons.search_off_rounded,
              title: 'Nothing matches',
              message: 'No recordings match your search.',
            )
          else
            ...matches.map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NeuCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Avatar(initials: rec.initials),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(rec.title, style: AppText.cardTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 3),
                                Text(
                                  // The title already shows the number when there is no contact.
                                  rec.number.isEmpty || rec.number == rec.title
                                      ? rec.whenLabel
                                      : '${rec.number}  ·  ${rec.whenLabel}',
                                  style: AppText.mono(12.5, color: AppColors.inkSoft),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AudioPlayerRow(
                        key: ValueKey(rec.path),
                        path: rec.path,
                        durationHint: (rec.call?.durationSeconds ?? 0) > 0 ? formatSeconds(rec.call!.durationSeconds) : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.onAllow, required this.onOpenSettings});

  final VoidCallback onAllow;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 14),
      child: Column(
        children: [
          const IconTile(icon: Icons.mic_rounded, color: AppColors.blueInk, size: 52, iconSize: 24, radius: 26),
          const SizedBox(height: 14),
          const Text('Show your call recordings', style: AppText.cardTitle),
          const SizedBox(height: 6),
          const Text(
            'Ringlead finds the recordings your dialer saves and links each one to its call. '
            'Allow access to audio files to continue.',
            textAlign: TextAlign.center,
            style: AppText.caption,
          ),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: NeuPrimaryButton(label: 'Allow access', onPressed: onAllow)),
          const SizedBox(height: 4),
          TextButton(onPressed: onOpenSettings, child: const Text('Open app settings')),
        ],
      ),
    );
  }
}

class _NoRecordingsHelp extends StatelessWidget {
  const _NoRecordingsHelp();

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Open your Phone app, then Settings, then Call recording.',
      'Turn on "Auto record calls" for all numbers.',
      'Make or receive a call, then pull down here to refresh.',
    ];

    return NeuCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconTile(icon: Icons.graphic_eq_rounded, color: AppColors.blueInk),
              const SizedBox(width: 12),
              const Expanded(child: Text('No recordings found yet', style: AppText.cardTitle)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Android does not let apps record calls directly, so Ringlead uses the recordings your phone makes:',
            style: AppText.caption,
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColors.blueSoft, shape: BoxShape.circle),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blueInk),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(steps[i], style: AppText.body)),
                ],
              ),
            ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(color: AppColors.amberSoft, borderRadius: BorderRadius.circular(12)),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 15, color: AppColors.amberInk),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Recordings made by the Google Phone app are kept private by Google and cannot be shown here.',
                    style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.amberInk, fontWeight: FontWeight.w500),
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
