import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:imot/common/themes/dark_theme.dart';
import 'package:imot/common/themes/light_theme.dart';

class AppTheme {
  static ThemeData light = lightTheme;
  static ThemeData dark = darkTheme;
  static AppBarTheme myAppBarTheme = const AppBarTheme(
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(
      color: Colors.white,
    ),
  );

  static ThemeData buildTheme(Brightness brightness) {
    var baseTheme = Get.isDarkMode ? dark : light;
    //Brightness.dark == brightness. ? dark : light;

    return baseTheme.copyWith(
      //useMaterial3: true,
      colorScheme: flexSchemeLight.copyWith(),
    );
  }
}

const ColorScheme flexSchemeLight = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xff095d9e),
  onPrimary: Color(0xffffffff),
  primaryContainer: Color(0xffa6cced),
  onPrimaryContainer: Color(0xff1d2328),
  secondary: Color(0xffdd520f),
  onSecondary: Color(0xffffffff),
  secondaryContainer: Color(0xffffdbcd),
  onSecondaryContainer: Color(0xff282523),
  tertiary: Color(0xff7cc8f8),
  onTertiary: Color(0xff000000),
  tertiaryContainer: Color(0xffc5e7ff),
  onTertiaryContainer: Color(0xff222728),
  error: Color(0xffb00020),
  onError: Color(0xffffffff),
  errorContainer: Color(0xfffcd8df),
  onErrorContainer: Color(0xff282526),
  outline: Color(0xff565656),
  //background: Color(0xfff3f6f9),
  background: Colors.white,
  onBackground: Color(0xff090909),
  surface: Color(0xfff3f6f9),
  onSurface: Color(0xff090909),
  surfaceVariant: Color(0xffe9f0f5),
  onSurfaceVariant: Color(0xff121213),
  inverseSurface: Color(0xff0f1315),
  onInverseSurface: Color(0xfff5f5f5),
  inversePrimary: Color(0xffa2d8ff),
  shadow: Color(0xff000000),
);

final TextTheme textTheme = TextTheme(
  headline1: GoogleFonts.prompt(
    fontSize: 97,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.5,
  ),
  headline2: GoogleFonts.prompt(
    fontSize: 61,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
  ),
  headline3: GoogleFonts.prompt(
    fontSize: 48,
    fontWeight: FontWeight.w400,
  ),
  headline4: GoogleFonts.prompt(
    fontSize: 34,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  ),
  headline5: GoogleFonts.prompt(
    fontSize: 24,
    fontWeight: FontWeight.w400,
  ),
  headline6: GoogleFonts.prompt(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  ),
  subtitle1: GoogleFonts.prompt(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
  ),
  subtitle2: GoogleFonts.prompt(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  ),
  bodyText1: GoogleFonts.prompt(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  ),
  bodyText2: GoogleFonts.prompt(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  ),
  button: GoogleFonts.prompt(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
  ),
  caption: GoogleFonts.prompt(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  ),
  overline: GoogleFonts.prompt(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.5,
  ),
);
