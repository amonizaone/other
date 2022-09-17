//import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:imot/common/themes/app_theme.dart';

//ThemeData lightTheme = ThemeData(
//  useMaterial3: true,
//  brightness: Brightness.light,
//  //primaryColor: Colors.black87,
//  primarySwatch: Colors.blue,
//  //fontFamily: 'Prompt',
//  appBarTheme: const AppBarTheme(
//    systemOverlayStyle: SystemUiOverlayStyle.light, // 2
//    iconTheme: IconThemeData(color: Colors.white),
//    actionsIconTheme: IconThemeData(
//      color: Colors.white,
//    ),
//    //foregroundColor: Colors.white,
//    //iconTheme: IconThemeData(
//    //  color: Colors.white, //change your color here
//    //),

//    titleTextStyle: TextStyle(
//      color: Colors.white,
//      fontSize: 18,
//      fontWeight: FontWeight.w500,
//    ),
//  ),
//  //iconTheme: IconThemeData(
//  //  color: Colors.black87,
//  //),
//  scaffoldBackgroundColor: Colors.white,
//  //backgroundColor: Utils.BACKGROUND_THEME, //Colors.grey.shade200,
//  highlightColor: Colors.transparent,
//  splashColor: Colors.transparent,
//  //textTheme: textTheme,

//  textTheme: textTheme,
//  //GoogleFonts.promptTextTheme(textTheme),

//  //textTheme: GoogleFonts.sacramentoTextTheme(),
//  visualDensity: VisualDensity.adaptivePlatformDensity,

//  cardTheme: const CardTheme(
//    shape: RoundedRectangleBorder(
//      borderRadius: BorderRadius.all(
//        Radius.circular(5.0),
//      ),
//    ),
//  ),
//  dialogTheme: const DialogTheme(
//    shape: RoundedRectangleBorder(
//      borderRadius: BorderRadius.all(
//        Radius.circular(15),
//      ),
//    ),
//  ),
//  //toolbarTextStyle: TextStyle(
//  //  fontSize: 18,
//  //  fontWeight: FontWeight.w500,
//  //  color: kRoyalBlueDark,
//  //),
//  //titleTextStyle: TextStyle(
//  //  fontSize: 18,
//  //  fontWeight: FontWeight.w500,
//  //  color: kRoyalBlueDark,
//  //),
//  //elevation: 0,
//  //backgroundColor: kPowderBlue,
//  //iconTheme: const IconThemeData(color: kRoyalBlueDark),

//  // appBarTheme: AppBarTheme(
//  //   elevation: 0, // This removes the shadow from all App Bars.
//  // ),
//);

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imot/common/app_colors.dart';
import 'package:imot/common/themes/app_theme.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

ThemeData lightTheme = FlexThemeData.light(
  useMaterial3: true,
  scheme: FlexScheme.blue,
  surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
  blendLevel: 20,
  appBarOpacity: 0.95,
  //appBarBackground: Colors.red,
  colorScheme: flexSchemeLight,
  tooltipsMatchBackground: true,

  //brightness: Brightness.light,
  //primarySwatch: Colors.blue,
  //appBarTheme: const AppBarTheme(
  //  systemOverlayStyle: SystemUiOverlayStyle.light, // 2
  //  iconTheme: IconThemeData(color: Colors.white),
  //  actionsIconTheme: IconThemeData(
  //    color: Colors.white,
  //  ),
  //  titleTextStyle: TextStyle(
  //    color: Colors.white,
  //    fontSize: 18,
  //    fontWeight: FontWeight.w500,
  //  ),
  //),
  //scaffoldBackgroundColor: Colors.white,
  scaffoldBackground: Colors.white,
  appBarStyle: FlexAppBarStyle.surface,

  //highlightColor: Colors.transparent,
  //splashColor: Colors.transparent,

  //textTheme: textTheme,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  subThemesData: FlexSubThemesData(
    useFlutterDefaults: true,
    blendOnLevel: 20,
    blendOnColors: false,
    toggleButtonsRadius: 40.0,
    //inputDecoratorSchemeColor: SchemeColor.background,
    fabRadius: 40.0,
    dialogRadius: 15.0,
    timePickerDialogRadius: 15.0,
    inputDecoratorFillColor: AppColors.blueColor.withOpacity(.5),

    cardRadius: 5.0,
    //inputDecoratorSchemeColor: SchemeColor.primary,
    //inputDecoratorUnfocusedHasBorder: true,
    //useTextTheme: true,
    cardElevation: 0.5,
    //navigationBarBackgroundSchemeColor: SchemeColor.onPrimary,
    //appBarBackgroundSchemeColor: SchemeColor.onPrimary,
    //bottomNavigationBarBackgroundSchemeColor: SchemeColor.onPrimary,

    //dialogElevation: 0,
  ),
  appBarElevation: 0,

  fontFamily: GoogleFonts.prompt().fontFamily,
  tones: FlexTones.material(Brightness.light),

  //typography: Typography.material2021(),
  //cardTheme: const CardTheme(
  //  shape: RoundedRectangleBorder(
  //    borderRadius: BorderRadius.all(
  //      Radius.circular(5.0),
  //    ),
  //  ),
  //),
  //dialogTheme: const DialogTheme(
  //  shape: RoundedRectangleBorder(
  //    borderRadius: BorderRadius.all(
  //      Radius.circular(15),
  //    ),
  //  ),
  //),
);
