import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:imot/common/app_config.dart';
import 'package:imot/common/worker/worker_utils.dart';
import 'package:imot/common/cache/box_cache.dart';
import 'package:imot/common/easy_loading_config.dart';
import 'package:imot/common/firebase/firebase_notifications.dart';
import 'package:imot/common/general_function.dart';
import 'package:imot/common/locale/locale_string.dart';
import 'package:imot/common/themes/app_theme.dart';
import 'dart:developer' as developer;
//import 'utilities/prefs.dart';
import 'package:imot/pages/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:android_intent_plus/android_intent.dart';

void initServices() async {
  print('starting services ...');
  //Get.putAsync(() => MainService().init());
}

void main() async {
  //IsoLateUtil().initIsolate();
  //Get.put(AuthService());
  await GetStorage.init();
  await dotenv.load(fileName: 'assets/config/.env.uat');
  WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
  //final db = AppDatabase.provider;

  final prefs = await SharedPreferences.getInstance();
  prefs.reload();

  //Get.put(LifeCycleController());
  //final db = AppDatabase.provider;

  //SendPort mainToIsolateStream = await IsoLateUtil().initIsolate();

  //mainToIsolateStream.send('hello');

  //ReceivePort port = ReceivePort();

  ////IsolateNameServer.registerPortWithName(port.sendPort, 'mMessage');
  //final isolate = await Isolate.spawn((SendPort d) {
  //  d.send('message');
  //}, port.sendPort);

  //port.listen((dynamic data) async {
  //  print('got $data on UI');
  //});

  var appConfig = AppConfig(
    appEnvironment: AppEnvironment.UAT,
    appName: dotenv.get('APP_NAME'),
    description: dotenv.get('DESCRIPTION'),
    baseUrl: dotenv.get('BASE_URL_API'),
    themeData: AppTheme.light,
    child: const MyApp(),
    showPerformanceOverlay: false,
    variables: {},
  );

  if (Platform.isAndroid) {
    binding.renderView.automaticSystemUiAdjustment = false;
  } else {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  }
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  //await BoxCacheUtil.init();

  // Only call clearSavedSettings() during testing to reset internal values.
  //await Upgrader.clearSavedSettings(); // REMOVE this for release builds

  //await Firebase.initializeApp();
  if (GetPlatform.isMobile) {
    //if (!(await GLFunc.instance.requestPermission(Permission.notification))) {
    //  return;
    //}

    FirebaseNotifications().initChannel();
    if (await GLFunc.isClientOnline()) {
      await FirebaseNotifications().init();
      //await FirebaseRemoteConfigUtil().setupRemoteConfig();

    } else {
      print('no network');
    }

    //FirebaseNotifications.requestUserPermissions(Get.context!,channelKey: '');
    //final prefs = await SharedPreferences.getInstance();
    //prefs.reload();

    //await BGServices().initializeBackgrounfService();
    //BGServices().manualJob();
    CronUtils().startAll();
  } else if (GetPlatform.isDesktop) {}
  //await ScreenUtil.ensureScreenSize();
  //final xToken = await FirebaseNotifications().generateToken();
  //print('FCM TOKEN ====> $xToken');
  LocaleService().initLocale();

  BoxCacheUtil.box.write('env', 'uat');

  EasyLoadingConfig.configLoading();

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['assets/fonts'], license);
  });

  runZonedGuarded(
    () {
      GLFunc.instance.lockScreenPortrait().then((_) {
        ScreenUtil.ensureScreenSize();
        var appUUid = BoxCacheUtil.appUuId();
        if (appUUid == null) {
          BoxCacheUtil.setAppUuid();
        }
        initServices();
        runApp(appConfig.child);

        FlutterNativeSplash.remove();
      });
    },
    (dynamic error, dynamic stack) {
      developer.log("Something went wrong!", error: error, stackTrace: stack);
    },
  );
  if (GetPlatform.isMobile) {
    FlutterImageCompress.showNativeLog = true;
  }
}
