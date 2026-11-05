import 'package:flutter/material.dart';
import '../theme.dart';

/// Shared surface decorations. The names are historical (the app started out
/// neumorphic); they now render a flat, high-contrast card system.
BoxDecoration neuRaised({double radius = kRadiusCard, Color color = AppColors.surface}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.line),
    boxShadow: AppShadows.card,
  );
}

/// Small inert surface - icon tiles, avatars, secondary chips.
BoxDecoration neuRaisedSm({double radius = kRadiusIcon, Color color = AppColors.surfaceSoft}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.line),
  );
}

/// Input / sunken surface.
BoxDecoration neuPressed({double radius = kRadiusInput, Color color = AppColors.surfaceSoft}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.line),
  );
}

/// A tinted square holding a single icon, e.g. a stat tile glyph.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    required this.color,
    this.size = 38,
    this.iconSize = 19,
    this.radius = kRadiusIcon,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.softFor(color),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}

class NeuCard extends StatelessWidget {
  const NeuCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = kRadiusCard,
    this.pressed = false,
    this.onTap,
    this.color = AppColors.surface,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Renders the sunken (input-style) surface instead of a raised card.
  final bool pressed;
  final VoidCallback? onTap;
  final Color color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final decoration = pressed
        ? neuPressed(radius: radius, color: AppColors.surfaceSoft)
        : neuRaised(radius: radius, color: color);

    return DecoratedBox(
      decoration: borderColor == null
          ? decoration
          : decoration.copyWith(border: Border.all(color: borderColor!, width: 1.4)),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          splashColor: onTap == null ? Colors.transparent : AppColors.blue.withValues(alpha: 0.07),
          highlightColor: onTap == null ? Colors.transparent : AppColors.blue.withValues(alpha: 0.04),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Circular icon button on a card-like surface. Used for back buttons and
/// header affordances.
class NeuCircleIcon extends StatelessWidget {
  const NeuCircleIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 42,
    this.iconSize = 19,
    this.onTap,
    this.background,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final VoidCallback? onTap;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.small,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(child: Icon(icon, size: iconSize, color: color)),
        ),
      ),
    );
  }
}

class NeuPrimaryButton extends StatelessWidget {
  const NeuPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = AppColors.blue,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadiusInput),
        boxShadow: enabled ? AppShadows.tinted(color) : const [],
      ),
      child: Material(
        color: enabled ? color : AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(kRadiusInput),
        child: InkWell(
          borderRadius: BorderRadius.circular(kRadiusInput),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: enabled ? Colors.white : AppColors.inkFaint),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: enabled ? Colors.white : AppColors.inkFaint,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined secondary action.
class NeuSecondaryButton extends StatelessWidget {
  const NeuSecondaryButton({super.key, required this.label, this.onPressed, this.icon, this.color = AppColors.blue});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(kRadiusInput),
      child: InkWell(
        borderRadius: BorderRadius.circular(kRadiusInput),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadiusInput),
            border: Border.all(color: AppColors.lineStrong),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
              ],
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color, this.dense = false});

  final String label;
  final Color color;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: dense ? 3 : 5),
      decoration: BoxDecoration(
        color: AppColors.softFor(color),
        borderRadius: BorderRadius.circular(kRadiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: dense ? 10.5 : 11.5, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.1),
      ),
    );
  }
}

/// Screen title row with an optional trailing widget - keeps every screen
/// heading on the same baseline and spacing.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.screenTitle),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle!, style: AppText.caption),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Small uppercase section divider with an optional action on the right.
class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label, this.action, this.onAction});

  final String label;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.toUpperCase(), style: AppText.sectionLabel),
          if (action != null)
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(action!, style: AppText.link),
              ),
            ),
        ],
      ),
    );
  }
}

class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({super.key, required this.labels, required this.selected, required this.onSelect});

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(kRadiusInput),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / labels.length;
          return Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: labels.length == 1
                    ? Alignment.center
                    : Alignment(-1 + 2 * (selected / (labels.length - 1)), 0),
                child: Container(
                  width: tabWidth,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(kRadiusInput - 4),
                    boxShadow: AppShadows.small,
                  ),
                ),
              ),
              Row(
                children: List.generate(labels.length, (i) {
                  final active = i == selected;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onSelect(i),
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        height: 34,
                        child: Center(
                          child: Text(
                            labels[i],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                              color: active ? AppColors.blueInk : AppColors.inkSoft,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ChipRow extends StatelessWidget {
  const ChipRow({super.key, required this.labels, required this.selected, required this.onSelect});

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) => FilterChipButton(
          label: labels[i],
          active: i == selected,
          onTap: () => onSelect(i),
        ),
      ),
    );
  }
}

/// Pill-shaped filter chip: solid in its colour when active, outlined when not.
class FilterChipButton extends StatelessWidget {
  const FilterChipButton({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
    this.color = AppColors.blue,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? color : AppColors.surface,
      borderRadius: BorderRadius.circular(kRadiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(kRadiusPill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadiusPill),
            border: Border.all(color: active ? color : AppColors.line),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppColors.inkSoft,
            ),
          ),
        ),
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    this.hint = 'Search',
    this.controller,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(kRadiusInput),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.small,
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 20, color: AppColors.inkFaint),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              readOnly: readOnly,
              onTap: onTap,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 14.5, color: AppColors.ink, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.inkFaint, fontWeight: FontWeight.w400, fontSize: 14.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Text field used inside forms and sheets - labelled and bordered.
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.inkSoft)),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(kRadiusInput),
            border: Border.all(color: AppColors.lineStrong),
          ),
          child: child,
        ),
      ],
    );
  }
}

/// Drag handle shown at the top of every bottom sheet.
class SheetGrabber extends StatelessWidget {
  const SheetGrabber({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 38,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: AppColors.lineStrong, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}

class EmptyStateNote extends StatelessWidget {
  const EmptyStateNote({super.key, required this.icon, required this.message, this.title});

  final IconData icon;
  final String message;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.surfaceSoft, shape: BoxShape.circle),
            child: Icon(icon, size: 24, color: AppColors.inkFaint),
          ),
          const SizedBox(height: 14),
          if (title != null) ...[
            Text(title!, textAlign: TextAlign.center, style: AppText.cardTitle),
            const SizedBox(height: 5),
          ],
          Text(message, textAlign: TextAlign.center, style: AppText.caption),
        ],
      ),
    );
  }
}

/// Monogram avatar. The colour is derived from the initials so a contact keeps
/// the same colour everywhere in the app.
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.initials, this.size = 44, this.fontSize = 15});

  final String initials;
  final double size;
  final double fontSize;

  static const _palette = [
    AppColors.blueInk,
    AppColors.violetInk,
    AppColors.greenInk,
    AppColors.amberInk,
    AppColors.redInk,
  ];

  Color get _color {
    if (initials.isEmpty) return AppColors.inkSoft;
    var hash = 0;
    for (final unit in initials.codeUnits) {
      hash = (hash + unit) % 255;
    }
    return _palette[hash % _palette.length];
  }

  /// The repositories use '#' when a call has no saved contact name.
  bool get _unknown => initials.isEmpty || initials == '#';

  @override
  Widget build(BuildContext context) {
    final color = _unknown ? AppColors.inkFaint : _color;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _unknown ? AppColors.surfaceSoft : AppColors.softFor(color),
        borderRadius: BorderRadius.circular(size * 0.34),
      ),
      child: _unknown
          ? Icon(Icons.person_rounded, size: size * 0.5, color: AppColors.inkFaint)
          : Text(
              initials,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.2),
            ),
    );
  }
}

Color callTypeColor(String type) {
  switch (type) {
    case 'incoming':
      return AppColors.greenInk;
    case 'outgoing':
      return AppColors.blueInk;
    default:
      return AppColors.redInk;
  }
}

IconData callTypeIcon(String type) {
  switch (type) {
    case 'incoming':
      return Icons.call_received_rounded;
    case 'outgoing':
      return Icons.call_made_rounded;
    default:
      return Icons.call_missed_rounded;
  }
}
