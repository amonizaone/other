import 'package:flutter/material.dart';
import 'package:imot/common/themes/app_theme.dart';

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: 'Prompt',
  scaffoldBackgroundColor: Colors.black87,
  highlightColor: Colors.transparent,
  backgroundColor: const Color(0xFFF6F7FF), //Colors.grey.shade200,
  splashColor: Colors.transparent,
  textTheme: textTheme,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  // appBarTheme: AppBarTheme(
  //   elevation: 0, // This removes the shadow from all App Bars.
  // ),
);



//import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:google_fonts/google_fonts.dart';
//import 'package:imot/common/themes/app_theme.dart';
//import 'package:flex_color_scheme/flex_color_scheme.dart';

//ThemeData darkTheme = FlexThemeData.dark(
//  useMaterial3: true,
//  scheme: FlexScheme.blumineBlue,
//  surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
//  blendLevel: 20,
//  appBarOpacity: 0.95,
//  //appBarBackground: Colors.red,

//  //brightness: Brightness.light,
//  //primarySwatch: Colors.blue,
//  //appBarTheme: const AppBarTheme(
//  //  systemOverlayStyle: SystemUiOverlayStyle.light, // 2
//  //  iconTheme: IconThemeData(color: Colors.white),
//  //  actionsIconTheme: IconThemeData(
//  //    color: Colors.white,
//  //  ),
//  //  titleTextStyle: TextStyle(
//  //    color: Colors.white,
//  //    fontSize: 18,
//  //    fontWeight: FontWeight.w500,
//  //  ),
//  //),
//  //scaffoldBackgroundColor: Colors.white,
//  scaffoldBackground: Colors.white,
//  appBarStyle: FlexAppBarStyle.background,
//  tabBarStyle: FlexTabBarStyle.flutterDefault,
//  //highlightColor: Colors.transparent,
//  //splashColor: Colors.transparent,

//  textTheme: textTheme,
//  visualDensity: VisualDensity.adaptivePlatformDensity,
//  subThemesData: const FlexSubThemesData(
//    useFlutterDefaults: true,
//    blendOnLevel: 20,
//    blendOnColors: false,
//    toggleButtonsRadius: 40.0,
//    //inputDecoratorSchemeColor: SchemeColor.background,
//    fabRadius: 40.0,
//    dialogRadius: 15.0,
//    timePickerDialogRadius: 15.0,

//    cardRadius: 5.0,
//    //dialogElevation: 0,
//  ),
//  fontFamily: GoogleFonts.prompt().fontFamily,

//  //cardTheme: const CardTheme(
//  //  shape: RoundedRectangleBorder(
//  //    borderRadius: BorderRadius.all(
//  //      Radius.circular(5.0),
//  //    ),
//  //  ),
//  //),
//  //dialogTheme: const DialogTheme(
//  //  shape: RoundedRectangleBorder(
//  //    borderRadius: BorderRadius.all(
//  //      Radius.circular(15),
//  //    ),
//  //  ),
//  //),
//);

