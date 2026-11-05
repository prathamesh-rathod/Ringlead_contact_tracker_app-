import 'package:flutter/material.dart';
import '../models/api_exception.dart';
import '../services/subscription_repository.dart';
import '../theme.dart';
import '../widgets/neu.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _repo = SubscriptionRepository.instance;
  SubscriptionInfo? _subscription;
  bool _loading = true;
  bool _changingPlan = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final info = await _repo.getMine();
      setState(() => _subscription = info);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _switchPlan(String plan) async {
    if (_subscription == null || _subscription!.plan == plan) return;
    setState(() => _changingPlan = true);
    try {
      final confirmedPlan = await _repo.updateMine(plan);
      setState(() => _subscription = SubscriptionInfo(plan: confirmedPlan, isActive: _subscription!.isActive));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(confirmedPlan == 'pro' ? 'Upgraded to Pro' : 'Switched to Free')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _changingPlan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Subscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.blue, strokeWidth: 2.6));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const IconTile(icon: Icons.cloud_off_rounded, color: AppColors.redInk, size: 52, iconSize: 24, radius: 26),
              const SizedBox(height: 14),
              Text(_error!, textAlign: TextAlign.center, style: AppText.caption),
              const SizedBox(height: 18),
              NeuPrimaryButton(label: 'Retry', onPressed: _load),
            ],
          ),
        ),
      );
    }

    final isPro = _subscription?.isPro ?? false;

    return ListView(
      padding: const EdgeInsets.fromLTRB(kGutter, 6, kGutter, 28),
      children: [
        const Text(
          'Choose the plan that fits how many leads you close.',
          textAlign: TextAlign.center,
          style: AppText.caption,
        ),
        const SizedBox(height: 20),
        _PlanCard(
          name: 'Free',
          price: '₹0',
          tagline: 'For getting started',
          features: const [
            _Feature('Up to 50 calls per month', true),
            _Feature('Manual call logging', true),
            _Feature('Basic lead cards', true),
            _Feature('Automatic call recording', false),
            _Feature('WhatsApp template broadcast', false),
          ],
          isCurrent: !isPro,
          highlighted: false,
          busy: _changingPlan,
          onSelect: () => _switchPlan('free'),
        ),
        const SizedBox(height: 16),
        _PlanCard(
          name: 'Pro',
          price: '₹499',
          tagline: 'For busy sales teams',
          features: const [
            _Feature('Unlimited calls', true),
            _Feature('Automatic call recording', true),
            _Feature('Advanced lead management', true),
            _Feature('WhatsApp template broadcast', true),
            _Feature('Priority support', true),
          ],
          isCurrent: isPro,
          highlighted: true,
          busy: _changingPlan,
          onSelect: () => _switchPlan('pro'),
        ),
        const SizedBox(height: 18),
        const Text(
          'Plans renew monthly. Cancel any time.',
          textAlign: TextAlign.center,
          style: AppText.tiny,
        ),
      ],
    );
  }
}

class _Feature {
  const _Feature(this.text, this.included);
  final String text;
  final bool included;
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.price,
    required this.tagline,
    required this.features,
    required this.isCurrent,
    required this.highlighted,
    required this.busy,
    required this.onSelect,
  });

  final String name;
  final String price;
  final String tagline;
  final List<_Feature> features;
  final bool isCurrent;
  final bool highlighted;
  final bool busy;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      padding: const EdgeInsets.all(18),
      borderColor: highlighted ? AppColors.blue : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
                        ),
                        const SizedBox(width: 8),
                        if (isCurrent) const StatusPill(dense: true, label: 'CURRENT', color: AppColors.greenInk),
                        if (!isCurrent && highlighted) const StatusPill(dense: true, label: 'POPULAR', color: AppColors.blueInk),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(tagline, style: AppText.tiny),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: price,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.6),
                  children: const [
                    TextSpan(
                      text: '/mo',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.inkFaint),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),
          for (final f in features) _FeatureLine(text: f.text, included: f.included),
          const SizedBox(height: 16),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(kRadiusInput),
              ),
              child: const Text(
                'Your current plan',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.inkSoft),
              ),
            )
          else if (busy)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              child: const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.blue),
              ),
            )
          else if (name == 'Pro')
            NeuPrimaryButton(label: 'Upgrade to Pro', icon: Icons.workspace_premium_rounded, onPressed: onSelect)
          else
            NeuSecondaryButton(label: 'Switch to Free', color: AppColors.inkSoft, onPressed: onSelect),
        ],
      ),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine({required this.text, required this.included});

  final String text;
  final bool included;

  @override
  Widget build(BuildContext context) {
    final color = included ? AppColors.greenInk : AppColors.inkFaint;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: included ? AppColors.greenSoft : AppColors.surfaceSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(included ? Icons.check_rounded : Icons.close_rounded, size: 13, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: included ? AppColors.ink : AppColors.inkFaint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
