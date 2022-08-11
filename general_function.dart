import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:imot/common/shared/enums/app_enum.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:path/path.dart' as p;

class GLFunc {
  static GLFunc? _instance;

  GLFunc._();

  static GLFunc get instance => _instance ??= GLFunc._();

  static FilteringTextInputFormatter numberOnly =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));
  static UnderlineInputBorder underLineBorder = const UnderlineInputBorder(
    borderRadius:
        // BorderRadius.only(
        //  topLeft: Radius.circular(5),
        //  topRight: Radius.circular(0),
        //  bottomLeft: Radius.circular(5),
        //  bottomRight: Radius.circular(0),
        //),
        BorderRadius.all(
      Radius.circular(5),
    ),
    borderSide: BorderSide.none,
  );
  static UnderlineInputBorder underLineBorderError = const UnderlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(5)),
    borderSide: BorderSide(color: Colors.red, width: 5),
  );

  static EdgeInsets viewInsets = EdgeInsets.fromWindowPadding(
    WidgetsBinding.instance.window.viewInsets,
    WidgetsBinding.instance.window.devicePixelRatio,
  );

  static String getNameFile(s) => p.basename(s);

  //static bool isKeyboardEnabled =
  //    KeyboardVisibilityProvider.isKeyboardVisible(Get.context!);

  static RoundedRectangleBorder borderRadius = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(5),
  );

  static Future<bool> isClientOnline() async {
    var result = await Connectivity().checkConnectivity();
    return !(result == ConnectivityResult.none &&
        result != ConnectivityResult.bluetooth);
  }

  Future<bool> requestPermission(
    Permission permission, {
    bool openSetting = false,
    bool isEnabled = false,
  }) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.permanentlyDenied) {
        //Get.defaultDialog(title: 'ddd');
        print('permanentlyDenied');
        if (openSetting) {
          return await openAppSettings();
        }
        return false;
      }
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  Future<bool> requestPermissionEnabled(
    Permission permission, {
    bool openSetting = false,
    bool isEnabled = false,
  }) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.permanentlyDenied) {
        //Get.defaultDialog(title: 'ddd');
        print('permanentlyDenied');
        if (openSetting) {
          return await openAppSettings();
        }
        return false;
      }
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  T jDecode<T>(String value) => json.decode(value);
  String jEncode(Object value) => json.encode(value);

  static T fromJson<T>(dynamic json) {
    if (json is Iterable) {
      return List<Map<String, dynamic>>.from(json).map((e) {
        return e;
      }).toList() as T;

      // return List<Map<String, dynamic>>.from(json).map((e) => Map.from(e)) as T;
      // _fromJsonList(json) as T;
    } else if (T == Map) {
      return fromJson(json) as T;
    } else if (T == Map<String, dynamic>) {
      return json;
    } else if (T == bool || T == String || T == int || T == double) {
      // primitives
      return json;
    } else {
      throw Exception("Unknown class");
    }
  }

  T? deserializeObject<T>(String str) {
    // if (T is List) {
    var tConvert = json.decode(str);

    return fromJson<T>(tConvert);
  }

  T? jMapDeepObject<T>(dynamic v) {
    String jsonStr = jEncode(v);
    print(T);
    // if(T is Lis>)
    // if (T is List) {
    return deserializeObject<T>(jsonStr);
    // }
    // return jDecode<T>(jsonStr);
  }

  static dynamic currencyFormat({dynamic total, String? format = '#,###'}) {
    // print('object total $total');
    double itemTotal = 0;
    if (total == null) return "";
    if (total is String) {
      itemTotal = double.tryParse(total) ?? 0;
    } else {
      if (total is int) {
        itemTotal = double.parse(total.toString());
      } else {
        itemTotal = total;
      }
    }

    // if (!GetUtils.isNum(itemTotal.toString())) {
    //   try {
    //     itemTotal = double.tryParse(total);
    //   } catch (e) {}
    // }
    // int? len = format?.indexOf(".");
    // String? newStr = len != -1
    //     ? format?.substring(format.indexOf(".") + 1, format.length)
    //     : "";

    var f = NumberFormat(format, "en_US");
    return f.format(itemTotal);

    // return NumberFormat.currency(
    //         decimalDigits: newStr?.length ?? 0, customPattern: format)
    //     .format(total);
  }

  static String formatCurency(dynamic s, [String symbol = '']) {
    // double value = s is double ? s : double.parse(s);

    try {
      return NumberFormat.currency(
        locale: Get.locale?.languageCode,
        decimalDigits: 2,
        symbol: symbol,
      ).format(s);
    } catch (e) {
      return '';
    }
  }

  static Text mandatoryLabel(labelText, {TextStyle? style}) {
    bool isWidget = labelText is Widget;
    return Text.rich(
      TextSpan(
        text: isWidget ? null : labelText,
        style: style,
        children: [
          if (isWidget) WidgetSpan(child: labelText),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  static copy(v, {bool showCopy = true, String? title}) {
    Clipboard.setData(ClipboardData(text: v));
    if (showCopy) {
      EasyLoading.showSuccess(
        v,
        maskType: EasyLoadingMaskType.black,
      );
    }
    // Get.snackbar(
    //   'Copy',
    //   '$v',
    //   backgroundColor: Colors.white,
    // );
  }

  /// Easy Loading
  Future<void> showLoading([String? message, bool dismiss = true]) async {
    // EasyLoading.instance

    EasyLoading.show(
      status: message?.tr ?? 'title.processing'.tr,
      dismissOnTap: dismiss,
      maskType: EasyLoadingMaskType.black,
    );
  }

  void hideLoading() async {
    Future.delayed(const Duration(milliseconds: 200));
    EasyLoading.dismiss();
  }

  Future<void> prepareSaveDir() async {
    var localPath = (await _findLocalPath(TargetPlatform.android))!;

    print(localPath);
    final savedDir = Directory(localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String?> _findLocalPath(TargetPlatform platform) async {
    if (platform == TargetPlatform.android) {
      return "/sdcard/download/";
    } else {
      var directory = await getApplicationDocumentsDirectory();
      return '${directory.path}${Platform.pathSeparator}Download';
    }
  }

  Future<Uint8List?> compressAndTryCatch({
    String? path,
    Uint8List? image,
    bool isFile = true,
  }) async {
    Uint8List? result;
    try {
      if (!isFile && image != null) {
        result = await FlutterImageCompress.compressWithList(
          minWidth: 900,
          minHeight: 1200,
          image,
          format: CompressFormat.jpeg,
          quality: 90,
        );
      } else {
        result = await FlutterImageCompress.compressWithFile(
          minWidth: 900,
          minHeight: 1200,
          path!,
          format: CompressFormat.jpeg,
          quality: 90,
        );
      }
    } on UnsupportedError catch (e) {
      print(e);

      if (!isFile) {
        result = await FlutterImageCompress.compressWithList(
          image!,
          minWidth: 900,
          minHeight: 1200,
          format: CompressFormat.jpeg,
          quality: 90,
        );
      } else {
        result = await FlutterImageCompress.compressWithFile(
          path!,
          minWidth: 900,
          minHeight: 1200,
          format: CompressFormat.jpeg,
          quality: 90,
        );
      }
    }
    return result;
  }

  T sumByKey<T>(data, key) => data
      .map((v) => v[key])
// .reduce((v, e) => v + e);
      .fold(0, (p, a) => (p) + (a ?? 0));
// const MethodChannel _channel = const MethodChannel('gmc01');

// Future<String> removeLastGMC(String strOriginal) async {
//   final String version =
//       await _channel.invokeMethod('removeLastGMC', strOriginal);
//   return version;
// }

  static Future<void> onShare({
    File? file,
    String? title,
    String? text,
  }) async {
    final RenderBox box = Get.context!.findRenderObject() as RenderBox;
    //await Share.share(data,
    //    sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);

    if (file != null) {
      await Share.shareFiles([file.path],
          text: text,
          subject: title,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } else {
      await Share.share(text!,
          subject: title,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }

  Future<void> deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
    final appDir = await getApplicationSupportDirectory();
    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }
  }

  void launchPhoneURL(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      //throw 'Could not launch $url';
      GLFunc.showSnackbar(
        message: 'ไม่สามารถเปิด $phoneNumber ได้',
        type: SnackType.INFO,
      );
      return;
    }
  }

  Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrlString(googleUrl)) {
      await launchUrlString(googleUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }

  Future<void> openMapQuery(String address) async {
    String query = Uri.encodeComponent(address);
    String googleUrl = "https://www.google.com/maps/search/?api=1&query=$query";

    if (await canLaunchUrlString(googleUrl)) {
      await launchUrlString(googleUrl, mode: LaunchMode.externalApplication);
    }
  }

  // ==========> SNAKBAR <===========================//

  static void showSnackbar({
    String? title,
    String message = 'default',
    Icon? icon,
    SnackType? type = SnackType.IEL,
    bool showIsEasyLoading = false,
    Duration? duration,
  }) {
    title = title ?? 'title.notify'.tr;
    Color color = Colors.white;
    // Icon? icon = icon;
    if (Get.isSnackbarOpen) {
      Get.back();
    }
    Color textColor = Colors.white;
    switch (type) {
      case SnackType.SUCCESS:
        color = const Color(0xFF5cb85c);
        icon = const Icon(
          Icons.check_circle,
          color: Colors.white,
        );
        break;
      case SnackType.INFO:
        color = const Color(0xFF5bc0de);
        icon = const Icon(
          Icons.info,
          color: Colors.white,
        );
        break;
      case SnackType.WARNING:
        color = const Color(0xFFffa700);
        icon = const Icon(
          Icons.warning,
          color: Colors.white,
        );
        break;
      case SnackType.ERROR:
        color = const Color(0xFFd9534f);
        icon = const Icon(
          Icons.error,
          color: Colors.white,
        );
        break;
      default:
        textColor = Colors.black87;
    }
    // Get.snackbar(
    //   '$title'.tr,
    //   message.tr,
    //   backgroundColor: Colors.red.shade400,
    //   // Colors.white,
    //   icon: icon,
    // );
    if (showIsEasyLoading) {
      switch (type) {
        case SnackType.SUCCESS:
          EasyLoading.showSuccess(message, duration: duration);
          break;
        case SnackType.INFO:
          EasyLoading.showInfo(message, duration: duration);
          break;

        //EasyLoading.showToast(message);
        //break;
        case SnackType.WARNING:
        case SnackType.ERROR:
          EasyLoading.showError(message, duration: duration);
          break;
        default:
          textColor = Colors.black87;
      }
      return;
    }
    if (Get.isSnackbarOpen) return;
    Get.showSnackbar(
      GetSnackBar(
        // title: ,
        titleText: Text(
          title.tr,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        messageText: Text(
          message,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),

        icon: icon,
        backgroundColor: color, // Colors.red.shade400,
        isDismissible: true,
        // dismissDirection: DismissDirection,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        snackStyle: SnackStyle.GROUNDED,
        //overlayBlur: 0.2,
      ),
    );
  }

  static void hideKeyboard() =>
      SystemChannels.textInput.invokeMethod('TextInput.hide');
  // test

  Future<String> saveAssetOnDisk(ImageProvider image, String fileName) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/$fileName';
    File newFile = File(filePath);

    if (!await newFile.exists()) {
      BitmapHelper bitmapHelper = await BitmapHelper.fromProvider(image);
      await newFile.writeAsBytes(bitmapHelper.content);
    }

    return filePath;
  }

  ///
  Future<String> saveFileOnDisk(Uint8List f, String fileName,
      [String? subFolder]) async {
    //String directory = await getLocalPath;

    String folder = '$subFolder';
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    if (subFolder != null) {
      folder = await createFolderInAppDocDir(subFolder);
    }

    folder = folder.replaceAll('//', '/');
    //var listSubFolder = subFolder?.split('/');

    String filePath = '$folder$fileName';

    File newFile = File(filePath);

    int size = 0;
    bool isOk = false;
    try {
      size = newFile.lengthSync();
      isOk = true;
    } catch (e) {
      size = f.lengthInBytes ~/ 1024;
      isOk = false;
    }

    if (size > 300) {
      var fileCompress = await compressAndTryCatch(
          path: !isOk ? null : filePath, image: f, isFile: isOk);
      f = fileCompress!;
    }

    if (!newFile.existsSync()) {
      await newFile.writeAsBytes(f, flush: true);
    }

    return filePath;
  }

  Future<String> createFolderInAppDocDir(String folderName) async {
    //Get this App Document Directory

    final appDocDir = await getLocalPath;
    //App Document Directory + folder name
    final Directory appDocDirFolder = Directory('$appDocDir/$folderName/');

    if (await appDocDirFolder.exists()) {
      //if folder already exists return path
      return appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory appDocDirNewFolder =
          await appDocDirFolder.create(recursive: true);
      return appDocDirNewFolder.path;
    }
  }

  Future<T?> showBottomSheet<T>(
    Widget widget, {
    double? defaultHeight = .75,
    bool isClose = true,
    Color? backgroundColor,
  }) async {
    defaultHeight = defaultHeight ?? 0.75;
    return Get.bottomSheet<T>(
      DraggableScrollableSheet(
        initialChildSize: defaultHeight, //set this as you want
        maxChildSize: defaultHeight, //set this as you want
        minChildSize: defaultHeight, //set this as you want
        expand: false,
        builder: (context, scrollController) {
          return SizedBox(
            //height: 200,
            // color: Colors.red.withOpacity(.2),
            // height: defaultHeight != null
            //     ? (Get.size.height * defaultHeight)
            //     : null,
            width: Get.size.width * 1,
            child: widget,
          );
        },
      ),
      isScrollControlled: true,
      enableDrag: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      persistent: true,
      ignoreSafeArea: true,
      backgroundColor: backgroundColor ?? Colors.white,
      isDismissible: isClose,
    );
  }

  Future get localPath async {
    // Application documents directory: /data/user/0/{package_name}/{app_name}
    final applicationDirectory = await getApplicationDocumentsDirectory();

    // External storage directory: /storage/emulated/0
    final externalDirectory = await getExternalStorageDirectory();

    // Application temporary directory: /data/user/0/{package_name}/cache
    final tempDirectory = await getTemporaryDirectory();

    return applicationDirectory.path;
  }

  Future<String> get getLocalPath async {
    //Get external storage directory ios & Android
    if (Platform.isIOS) {
      print('ios++++++++++++');
      // var directory = await getLibraryDirectory();
      // return directory.path;
      var directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
    print('Android++++++++++++');
    var directory = await getExternalStorageDirectory();
    //Check if external storage not available. If not available use
    //internal applications directory
    directory ??= await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await getLocalPath;
    return File('$path/sample.txt');
  }

  Future<File> write(String data) async {
    final file = await _localFile;
    // Write the file in append mode so it would append the data to
    //existing file
    return file.writeAsString('$data\n', mode: FileMode.append);
  }

  void lockScreenPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void unlockScreenPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<String> getPlatformVersion() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var sdkInt = androidInfo.version.sdkInt;
      return 'Android-$sdkInt';
    }

    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var systemName = iosInfo.systemName;
      var version = iosInfo.systemVersion;
      return '$systemName-$version';
    }

    return 'unknow';
  }

  String printDuration(Duration? duration) {
    if (duration == null) return '00:00';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      //print("${(received / total * 100).toStringAsFixed(0)}%");
      //NotificationUtils.showProgressNotification(1);
      var percen = min<int>((received / total * 100).round(), 100);
      print("$percen%");
      //AwesomeNotifications().cancel(1);
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'Notify_Job',
          title: 'ดาวน์โหลด',
          //body: 'กำลังดาวโ',
          category: NotificationCategory.Progress,
          body: '${percen.toStringAsFixed(0)}%"',
          hideLargeIconOnExpand: false,
          notificationLayout: NotificationLayout.ProgressBar,
          criticalAlert: true,
          progress: percen,
          //min((received / total * 100).round(), 100),
          //payload: {
          //  'file': 'filename.txt',
          //  'path': '-rmdir c://ruwindows/system32/huehuehue'
          //},
          locked: false,
        ),
      );
    }
  }

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      print("Cannot get download folder path");
    }
    return directory?.path;
  }

  Future<String> downloadAndSaveImageOnDisk(
    String url,
    String fileName, {
    bool isLoad = false,
    Function(int, int)? onReceiveProgress,
  }) async {
    //var directory = await getApplicationDocumentsDirectory();
    var pathFolder = await createFolderInAppDocDir('download');
    var filePath = '$pathFolder$fileName';
    var file = File(filePath);
    //return '';

    //if (!await file.exists()) {
    if (isLoad) {
      var response = await Dio().get(
        url,
        //onReceiveProgress: showDownloadProgress,
        onReceiveProgress: onReceiveProgress ??
            (received, total) {
              if (total != -1) {
                print("${(received / total * 100).toStringAsFixed(0)}%");
              }
            },
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      List<int> bytes = response.data.buffer.asUint8List(
          response.data.offsetInBytes, response.data.lengthInBytes);
      await File(filePath).writeAsBytes(bytes);
      //await file.writeAsBytes(response.data);
      print('object');
    } else {
      var response = await Dio().get(url);
      await file.writeAsBytes(response.data);
    }
    //}

    return filePath;
  }

  String fileSize(dynamic sizeInput, [int round = 2]) {
    /**
   * [size] can be passed as number or as string
   *
   * the optional parameter [round] specifies the number
   * of digits after comma/point (default is 2)
   */
    int divider = 1024;
    int size;
    try {
      size = int.parse(sizeInput.toString());
    } catch (e) {
      throw ArgumentError("Can not parse the size parameter: $e");
    }

    if (size < divider) {
      return "$size B";
    }

    if (size < divider * divider && size % divider == 0) {
      return "${(size / divider).toStringAsFixed(0)} KB";
    }

    if (size < divider * divider) {
      return "${(size / divider).toStringAsFixed(round)} KB";
    }

    if (size < divider * divider * divider && size % divider == 0) {
      return "${(size / (divider * divider)).toStringAsFixed(0)} MB";
    }

    if (size < divider * divider * divider) {
      return "${(size / divider / divider).toStringAsFixed(round)} MB";
    }

    if (size < divider * divider * divider * divider && size % divider == 0) {
      return "${(size / (divider * divider * divider)).toStringAsFixed(0)} GB";
    }

    if (size < divider * divider * divider * divider) {
      return "${(size / divider / divider / divider).toStringAsFixed(round)} GB";
    }

    if (size < divider * divider * divider * divider * divider &&
        size % divider == 0) {
      num r = size / divider / divider / divider / divider;
      return "${r.toStringAsFixed(0)} TB";
    }

    if (size < divider * divider * divider * divider * divider) {
      num r = size / divider / divider / divider / divider;
      return "${r.toStringAsFixed(round)} TB";
    }

    if (size < divider * divider * divider * divider * divider * divider &&
        size % divider == 0) {
      num r = size / divider / divider / divider / divider / divider;
      return "${r.toStringAsFixed(0)} PB";
    } else {
      num r = size / divider / divider / divider / divider / divider;
      return "${r.toStringAsFixed(round)} PB";
    }
  }

  Color getRandomColor() {
    return Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
        .withOpacity(1.0);
  }

  int getRandomNumer([int numOf = 10000]) {
    return math.Random().nextInt(numOf);
  }

  /// Google map

}
