import 'package:flutter/material.dart';

/// Ringlead design tokens.
///
/// One clean, high-contrast light scheme: white surfaces on a soft neutral
/// canvas, hairline borders, a single brand blue and muted semantic tints.
class AppColors {
  AppColors._();

  // Canvas + surfaces
  static const canvas = Color(0xFFF5F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFF1F4FA);
  static const surfaceSunken = Color(0xFFEFF2F8);

  // Text
  static const ink = Color(0xFF121826);
  static const inkSoft = Color(0xFF5B6678);
  static const inkFaint = Color(0xFF97A1B2);

  // Lines
  static const line = Color(0xFFE4E9F2);
  static const lineStrong = Color(0xFFD3DAE8);

  // Brand
  static const blue = Color(0xFF2F6BFF);
  static const blueInk = Color(0xFF1B4FD8);
  static const blueSoft = Color(0xFFEAF0FF);

  static const green = Color(0xFF18B26B);
  static const greenInk = Color(0xFF0E8C54);
  static const greenSoft = Color(0xFFE6F7EF);

  static const red = Color(0xFFEF4B4B);
  static const redInk = Color(0xFFCE2F35);
  static const redSoft = Color(0xFFFDECEC);

  static const amber = Color(0xFFF5A524);
  static const amberInk = Color(0xFFB9730A);
  static const amberSoft = Color(0xFFFEF4E2);

  static const violet = Color(0xFF7C5CFF);
  static const violetInk = Color(0xFF5B3FD6);
  static const violetSoft = Color(0xFFF0ECFF);

  /// The pale wash that pairs with a semantic ink colour (icon tiles, pills).
  static Color softFor(Color color) {
    if (color == greenInk || color == green) return greenSoft;
    if (color == redInk || color == red) return redSoft;
    if (color == amberInk || color == amber) return amberSoft;
    if (color == violetInk || color == violet) return violetSoft;
    if (color == blueInk || color == blue) return blueSoft;
    if (color == inkFaint || color == inkSoft) return surfaceSoft;
    return Color.alphaBlend(color.withValues(alpha: 0.10), surface);
  }
}

/// Elevation is kept deliberately shallow — one card shadow, one lifted shadow.
class AppShadows {
  AppShadows._();

  static const card = <BoxShadow>[
    BoxShadow(color: Color(0x0A1A2B4F), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x0F1A2B4F), offset: Offset(0, 6), blurRadius: 16, spreadRadius: -4),
  ];

  static const small = <BoxShadow>[
    BoxShadow(color: Color(0x0D1A2B4F), offset: Offset(0, 1), blurRadius: 3),
  ];

  static const nav = <BoxShadow>[
    BoxShadow(color: Color(0x141A2B4F), offset: Offset(0, -2), blurRadius: 14),
  ];

  static List<BoxShadow> tinted(Color color) => [
        BoxShadow(color: color.withValues(alpha: 0.28), offset: const Offset(0, 6), blurRadius: 16, spreadRadius: -6),
      ];
}

class AppText {
  AppText._();

  static const greeting = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.inkSoft,
  );

  static const screenTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    letterSpacing: -0.4,
    height: 1.15,
  );

  static const h1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    letterSpacing: -0.4,
    height: 1.2,
  );

  static const sectionLabel = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.9,
    color: AppColors.inkFaint,
  );

  static const cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    letterSpacing: -0.1,
  );

  static const body = TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.inkSoft);

  static const caption = TextStyle(fontSize: 12.5, height: 1.45, color: AppColors.inkSoft);

  static const tiny = TextStyle(fontSize: 11.5, color: AppColors.inkFaint);

  static const statNum = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    letterSpacing: -1,
    height: 1.1,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const link = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.blue);

  static TextStyle mono(double size, {FontWeight weight = FontWeight.w500, Color color = AppColors.ink}) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: 0,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}

const kRadiusCard = 18.0;
const kRadiusInput = 14.0;
const kRadiusIcon = 12.0;
const kRadiusPill = 999.0;

/// Page gutter used by every scrolling screen so columns line up app-wide.
const kGutter = 18.0;

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.blue,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.blue,
    surface: AppColors.surface,
    error: AppColors.redInk,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.canvas,
    fontFamily: 'Roboto',
    splashFactory: InkSparkle.splashFactory,
    textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.blue),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1, space: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.blue),
    iconTheme: const IconThemeData(color: AppColors.inkSoft),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.canvas,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
      iconTheme: IconThemeData(color: AppColors.ink, size: 20),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      contentTextStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.blue,
        textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
      ),
    ),
    timePickerTheme: const TimePickerThemeData(backgroundColor: AppColors.surface),
    datePickerTheme: const DatePickerThemeData(backgroundColor: AppColors.surface),
  );
}
