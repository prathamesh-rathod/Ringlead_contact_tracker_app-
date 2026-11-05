import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../services/call_log_repository.dart';
import '../services/notes_repository.dart';
import '../services/recording_repository.dart';
import '../theme.dart';
import '../widgets/call_log_status_banner.dart';
import '../widgets/call_tile.dart';
import '../widgets/neu.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => CallsScreenState();
}

class CallsScreenState extends State<CallsScreen> {
  int _filter = 0;
  String _query = '';
  final _repo = CallLogRepository.instance;

  static const _filterLabels = ['All', 'Incoming', 'Outgoing', 'Missed'];
  static const _filterValues = ['all', 'incoming', 'outgoing', 'missed'];

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChanged);
    RecordingRepository.instance.addListener(_onRepoChanged);
    NotesRepository.instance.addListener(_onRepoChanged);
    if (_repo.status == CallLogStatus.idle) _repo.refresh();
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    RecordingRepository.instance.removeListener(_onRepoChanged);
    NotesRepository.instance.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  void setFilterByValue(String value) {
    final i = _filterValues.indexOf(value);
    if (i != -1) setState(() => _filter = i);
  }

  @override
  Widget build(BuildContext context) {
    final allCalls = _repo.calls;
    final matches = allCalls.where((c) {
      final matchesType = _filter == 0 || c.type == _filterValues[_filter];
      final q = _query.trim().toLowerCase();
      final matchesQuery = q.isEmpty || c.name.toLowerCase().contains(q) || c.number.contains(q);
      return matchesType && matchesQuery;
    }).toList();

    final grouped = <String, List<CallEntry>>{};
    for (final c in matches) {
      grouped.putIfAbsent(c.day, () => []).add(c);
    }

    return RefreshIndicator(
      onRefresh: _repo.refresh,
      color: AppColors.blue,
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(kGutter, 14, kGutter, 28),
        children: [
          ScreenHeader(
            title: 'Calls',
            subtitle: _repo.lastSyncedLabel ?? 'Your phone call history',
            trailing: NeuCircleIcon(
              icon: Icons.refresh_rounded,
              color: AppColors.ink,
              size: 42,
              iconSize: 20,
              onTap: _repo.refresh,
            ),
          ),
          const SizedBox(height: 16),
          SearchField(hint: 'Search name or number', onChanged: (v) => setState(() => _query = v)),
          const SizedBox(height: 12),
          SegmentedTabs(labels: _filterLabels, selected: _filter, onSelect: (i) => setState(() => _filter = i)),
          const SizedBox(height: 18),
          if (_repo.status == CallLogStatus.loading && allCalls.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Center(child: CircularProgressIndicator(color: AppColors.blue, strokeWidth: 2.6)),
            )
          else if (_repo.status == CallLogStatus.permissionDenied ||
              _repo.status == CallLogStatus.unsupported ||
              _repo.status == CallLogStatus.error)
            CallLogStatusBanner(status: _repo.status, errorMessage: _repo.errorMessage, onRetry: _repo.refresh)
          else if (matches.isEmpty)
            EmptyStateNote(
              icon: allCalls.isEmpty ? Icons.history_rounded : Icons.filter_alt_off_rounded,
              title: allCalls.isEmpty ? 'No calls yet' : 'Nothing matches',
              message: allCalls.isEmpty
                  ? 'Make or receive a call and it will show up here automatically.'
                  : 'No calls match this filter or search.',
            )
          else
            for (final day in grouped.keys) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 9, top: 2),
                child: Row(
                  children: [
                    Text(day.toUpperCase(), style: AppText.sectionLabel),
                    const SizedBox(width: 8),
                    Expanded(child: Container(height: 1, color: AppColors.line)),
                    const SizedBox(width: 8),
                    Text('${grouped[day]!.length}', style: AppText.tiny),
                  ],
                ),
              ),
              ...grouped[day]!.map(
                (call) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CallListTile(call: call),
                ),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}
