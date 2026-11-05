import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../services/call_log_repository.dart';
import '../services/notes_repository.dart';
import '../services/reminder_service.dart';
import '../theme.dart';
import '../widgets/neu.dart';
import 'call_detail_screen.dart' show CallDetailScreen, leadStatusColor, reminderLabel;

/// Shows every call the owner has tagged with a lead status, so follow-ups live
/// in one place instead of being buried in the full call log.
class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  final _calls = CallLogRepository.instance;
  final _notes = NotesRepository.instance;
  final _reminders = ReminderService.instance;
  LeadStatus? _filter; // null = all leads

  static const _filters = [null, LeadStatus.newLead, LeadStatus.interested, LeadStatus.followup, LeadStatus.won, LeadStatus.lost];

  @override
  void initState() {
    super.initState();
    _notes.addListener(_onChanged);
    _calls.addListener(_onChanged);
    _reminders.addListener(_onChanged);
    _notes.load();
  }

  @override
  void dispose() {
    _notes.removeListener(_onChanged);
    _calls.removeListener(_onChanged);
    _reminders.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // One lead per call that has a status; newest first.
    final leads = _calls.calls.where((c) => _notes.hasStatus(c.timestamp)).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final shown = _filter == null ? leads : leads.where((c) => _notes.statusFor(c.timestamp) == _filter).toList();

    return RefreshIndicator(
      onRefresh: () => _notes.load(force: true),
      color: AppColors.blue,
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(kGutter, 14, kGutter, 28),
        children: [
          ScreenHeader(
            title: 'Leads',
            subtitle: leads.isEmpty ? 'Tagged calls you need to follow up' : '${leads.length} tagged follow-ups',
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f = _filters[i];
                final count = f == null ? leads.length : leads.where((c) => _notes.statusFor(c.timestamp) == f).length;
                return FilterChipButton(
                  label: f == null ? 'All  $count' : '${leadStatusLabel(f)}  $count',
                  active: f == _filter,
                  color: f == null ? AppColors.blue : leadStatusColor(f),
                  onTap: () => setState(() => _filter = f),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          if (shown.isEmpty)
            EmptyStateNote(
              icon: Icons.flag_outlined,
              title: leads.isEmpty ? 'No leads yet' : 'Nothing with this status',
              message: leads.isEmpty
                  ? 'Open a call and set its status (Interested, Follow-up and so on) to track it here.'
                  : 'Try another status filter.',
            )
          else
            ...shown.map((c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _LeadRow(call: c))),
        ],
      ),
    );
  }
}

class _LeadRow extends StatelessWidget {
  const _LeadRow({required this.call});

  final CallEntry call;

  @override
  Widget build(BuildContext context) {
    final status = NotesRepository.instance.statusFor(call.timestamp);
    final note = NotesRepository.instance.noteFor(call.timestamp);
    final reminder = ReminderService.instance.reminderFor(call.timestamp);
    final statusColor = leadStatusColor(status);

    return NeuCard(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CallDetailScreen(call: call))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(initials: call.initials),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(call.name, style: AppText.cardTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text('${call.day}  ·  ${call.time}', style: AppText.mono(12.5, color: AppColors.inkSoft)),
                  ],
                ),
              ),
              StatusPill(label: leadStatusLabel(status), color: statusColor),
            ],
          ),
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(note, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.body),
            ),
          ],
          if (reminder != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.alarm_rounded, size: 14, color: AppColors.amberInk),
                const SizedBox(width: 6),
                Text(
                  'Call back ${reminderLabel(reminder)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.amberInk),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
