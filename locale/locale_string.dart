import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:imot/common/locale/index.dart';
//import 'package:imot/common/locale/en_us.dart';
//import 'package:imot/common/locale/th_th.dart';

class LocaleService extends Translations {
  // Default locale
  static Locale locale = const Locale('th', 'TH');

  // fallbackLocale saves the day when the locale gets in trouble
  static Locale fallbackLocale = const Locale('th', 'TH');

  // Supported languages
  // Needs to be same order with locales
  static final langs = [
    {'en': 'English'},
    {'th': 'Thai'},
  ];

  static final locales = [
    // Locale('en_US', 'US'),
    // Locale('th_TH', 'TH'),
    const Locale('en', 'US'), // English
    const Locale('th', 'TH'), // Thai
  ];

  // Gets locale from language, and updates the locale
  void changeLocale(String lang) {
    final locale = _getLocaleFromLanguage(lang);
    //Prefs.setLocale(locale!.languageCode);
    Get.updateLocale(locale!);
  }

  void initLocale() async {
    // locale =
    String? loca = 'th';
    // await Prefs.getLocale;
    if (loca == "") loca = 'th';

    var getLoca = langs.firstWhere((e) => e.keys.first == loca).values.first;
    changeLocale(getLoca);
    locale = Get.locale!;

    // return Get.locale;
  }

  // Finds language in `langs` list and returns it as Locale
  Locale? _getLocaleFromLanguage(String lang) {
    for (int i = 0; i < langs.length; i++) {
      if (lang == langs[i].values.first) return locales[i];
    }

    return Get.locale;
  }

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS, // lang/en_us.dart
        'th_TH': thTH, // lang/th_th.dart
      };
}
