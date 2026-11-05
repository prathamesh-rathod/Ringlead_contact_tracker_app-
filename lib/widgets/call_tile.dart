import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../screens/call_detail_screen.dart';
import '../services/notes_repository.dart';
import '../services/recording_repository.dart';
import '../theme.dart';
import 'neu.dart';

/// One row in a call list. Used by Home (compact) and the Calls tab (with the
/// recording / note / lead-status markers) so both read identically.
class CallListTile extends StatelessWidget {
  const CallListTile({super.key, required this.call, this.showMarkers = true});

  final CallEntry call;
  final bool showMarkers;

  static String typeWord(String type) => '${type[0].toUpperCase()}${type.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final color = callTypeColor(call.type);
    final hasRecording = showMarkers && RecordingRepository.instance.recordingFor(call) != null;
    final hasNote = showMarkers && NotesRepository.instance.hasNote(call.timestamp);
    final hasStatus = showMarkers && NotesRepository.instance.hasStatus(call.timestamp);
    // The name falls back to the number when there is no contact; do not repeat it.
    final subtitle = call.number == call.name || call.number.isEmpty
        ? typeWord(call.type)
        : '${typeWord(call.type)}  ·  ${call.number}';

    return NeuCard(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CallDetailScreen(call: call))),
      child: Row(
        children: [
          _AvatarWithType(initials: call.initials, type: call.type),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(call.name, style: AppText.cardTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: color),
                ),
                if (hasRecording || hasNote) ...[
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      if (hasRecording) const _Marker(icon: Icons.mic_rounded, label: 'Recorded', color: AppColors.blueInk),
                      if (hasRecording && hasNote) const SizedBox(width: 6),
                      if (hasNote) const _Marker(icon: Icons.sticky_note_2_rounded, label: 'Note', color: AppColors.violetInk),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(call.time, style: AppText.mono(13, weight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(call.duration, style: AppText.mono(11.5, color: AppColors.inkFaint)),
              if (hasStatus) ...[
                const SizedBox(height: 7),
                StatusPill(
                  dense: true,
                  label: leadStatusLabel(NotesRepository.instance.statusFor(call.timestamp)),
                  color: leadStatusColor(NotesRepository.instance.statusFor(call.timestamp)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Monogram with a small call-direction badge clipped to its bottom-right.
class _AvatarWithType extends StatelessWidget {
  const _AvatarWithType({required this.initials, required this.type});

  final String initials;
  final String type;

  @override
  Widget build(BuildContext context) {
    final color = callTypeColor(type);
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        children: [
          Avatar(initials: initials, size: 44),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              child: Icon(callTypeIcon(type), size: 9, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.softFor(color),
        borderRadius: BorderRadius.circular(kRadiusPill),
      ),
      child: Row(
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
