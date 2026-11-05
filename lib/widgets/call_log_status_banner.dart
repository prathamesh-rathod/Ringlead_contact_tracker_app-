import 'package:flutter/material.dart';
import '../services/call_log_repository.dart';
import '../theme.dart';
import 'neu.dart';

/// Shown in place of the call list when the device call log isn't readable yet —
/// permission not granted, platform doesn't support it (iOS/desktop), or a fetch error.
class CallLogStatusBanner extends StatelessWidget {
  const CallLogStatusBanner({super.key, required this.status, required this.onRetry, this.errorMessage});

  final CallLogStatus status;
  final VoidCallback onRetry;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final Color color;
    late final String title;
    late final String body;
    bool showRetry = true;
    String retryLabel = 'Grant access';

    switch (status) {
      case CallLogStatus.permissionDenied:
        icon = Icons.lock_outline_rounded;
        color = AppColors.amberInk;
        title = 'Call log access needed';
        body = 'Ringlead reads your call history to log calls automatically. Grant access to continue.';
      case CallLogStatus.unsupported:
        icon = Icons.phone_android_rounded;
        color = AppColors.inkSoft;
        title = 'Not available on this device';
        body = 'Automatic call logging only works on Android — the OS blocks this on iOS entirely.';
        showRetry = false;
      case CallLogStatus.error:
        icon = Icons.error_outline_rounded;
        color = AppColors.redInk;
        title = 'Could not load calls';
        body = errorMessage ?? 'Something went wrong while reading the call log.';
        retryLabel = 'Retry';
      default:
        icon = Icons.info_outline_rounded;
        color = AppColors.inkSoft;
        title = 'No data yet';
        body = '';
    }

    return NeuCard(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
      child: Column(
        children: [
          IconTile(icon: icon, color: color, size: 54, iconSize: 25, radius: 27),
          const SizedBox(height: 14),
          Text(title, textAlign: TextAlign.center, style: AppText.cardTitle),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(body, textAlign: TextAlign.center, style: AppText.caption),
          ],
          if (showRetry) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: NeuPrimaryButton(label: retryLabel, onPressed: onRetry),
            ),
          ],
        ],
      ),
    );
  }
}
