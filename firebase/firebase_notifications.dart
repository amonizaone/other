import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imot/common/app_colors.dart';
import 'package:imot/common/cache/box_cache.dart';
import 'package:imot/common/dialog_utils.dart';
import 'package:imot/common/firebase/notification_util.dart';
import 'package:imot/common/general_function.dart';
import 'package:imot/common/services/auth_service.dart';
import 'package:imot/common/services/job_service.dart';
//import 'package:imot/common/routers/app_routes.dart';
import 'package:imot/common/shared/enums/app_enum.dart';
import 'package:imot/common/widgets/buttons/button_component.dart';
import 'package:imot/controllers/job_detail_controller.dart';
import 'package:imot/controllers/job_location_controller.dart';
import 'package:imot/controllers/jobs_controller.dart';
import 'package:imot/database/database.dart';
import 'package:drift/drift.dart' as d;
import 'package:imot/pages/app/app.dart';
import 'package:imot/pages/job_detail_page.dart';
import 'package:imot/pages/root/rootInit.dart';
import 'package:imot/repositories/job/job_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');

  Map<String, dynamic> messageMap = message.toMap();

  //if (!AwesomeStringUtils.isNullOrEmpty(message.notification?.title,
  //        considerWhiteSpaceAsEmpty: true) ||
  //    !AwesomeStringUtils.isNullOrEmpty(message.notification?.body,
  //        considerWhiteSpaceAsEmpty: true)) {
  //  print('message also contained a notification: ${message.notification}');

  //  String? imageUrl;
  //  imageUrl ??= message.notification!.android?.imageUrl;
  //  imageUrl ??= message.notification!.apple?.imageUrl;

  //  Map<String, dynamic> notificationAdapter = {
  //    NOTIFICATION_CHANNEL_KEY: 'Notify_Other',
  //    NOTIFICATION_ID: message.data[NOTIFICATION_CONTENT]?[NOTIFICATION_ID] ??
  //        message.messageId ??
  //        Random().nextInt(2147483647),
  //    NOTIFICATION_TITLE: message.data[NOTIFICATION_CONTENT]
  //            ?[NOTIFICATION_TITLE] ??
  //        message.notification?.title,
  //    NOTIFICATION_BODY: message.data[NOTIFICATION_CONTENT]
  //            ?[NOTIFICATION_BODY] ??
  //        message.notification?.body,
  //    NOTIFICATION_LAYOUT:
  //        AwesomeStringUtils.isNullOrEmpty(imageUrl) ? 'Default' : 'BigPicture',
  //    NOTIFICATION_BIG_PICTURE: imageUrl
  //  };

  //  AwesomeNotifications().createNotificationFromJsonData(notificationAdapter);
  //} else {
  Map<String, dynamic>? content;
  Map<String, dynamic>? payload;

  NotificationContent? notiContent;

  if (message.data['content'] is String) {
    try {
      content = GLFunc.instance.jDecode(message.data['content']);
    } catch (e) {
      content = message.data['content'];
    }
  } else {
    content = message.data['content'];
  }

  if (GetPlatform.isAndroid) {
    content!['customSound'] = 'resource://raw/message_tone_3';
    content['icon'] = 'resource://drawable/res_app_icon';
  }

  content?['notificationLayout'] = NotificationLayout.BigText;
  content?['hideLargeIconOnExpand'] = false;

  try {
    if (message.data.containsKey('payload')) {
      payload = GLFunc.instance.jDecode(message.data['payload']);
      content?['payload'] = payload!;
    }
  } finally {}

  notiContent = NotificationContent(
    id: content?['id'] ?? DateTime.now().millisecond,
    channelKey: content?['channelKey'] ?? 'Notify_Other',
    criticalAlert: true,
    wakeUpScreen: false,
  ).fromMap(content!);

  // LogUtil.printLog(message.data['content']);
  if (GetPlatform.isAndroid) {
    content['customSound'] = 'resource://raw/message_tone_3';
    content['icon'] = 'resource://drawable/res_app_icon';
  }

  content['notificationLayout'] = NotificationLayout.BigText;
  content['hideLargeIconOnExpand'] = false;
  //Map<String, String> mapPayload = {};
  //if (payload != null) {
  //  for (var e in payload.entries) {
  //    String key = e.key;
  //    String value = e.value.toString();
  //    mapPayload.addAll({key: value});
  //  }
  //}

  await FirebaseNotifications().mapEventDialog(
    payload,
    notificationContent: notiContent,
    isAppOpen: false,
    isbackground: true,
  );
  //if (payload?['eventType'] == 'JOB_ASSIGN') {
  //  showDialogAssignJob(
  //    (payload?['refNo'] ?? ''),
  //    content['id'] ?? DateTime.now().millisecond,
  //  );
  //} else if (payload?['eventType'] == 'SIGNOUT') {
  //  if (!Get.isRegistered<AuthService>()) {
  //    Get.lazyPut(() => AuthService());
  //  }

  //  Get.find<AuthService>().signOut();
  //}

  AwesomeNotifications().createNotification(content: notiContent!);

  // AwesomeNotifications().createNotification(content: notiContent!);

  //AwesomeNotifications().createNotificationFromJsonData(messageMap['data']);
  //}
}

class FirebaseNotifications {
  // FirebaseNotifications(){

  // }

  // AndroidNotificationChannel? channel;
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();
  //FIX

  static final FirebaseNotifications _firebaseNotifications =
      FirebaseNotifications._internal();

  factory FirebaseNotifications() {
    return _firebaseNotifications;
  }

  FirebaseNotifications._internal();

  static String? token;
  static bool? initApp;
  static int _messageCount = 0;

  /// Create a [AndroidNotificationChannel] for heads up notifications
  ///
  Future<void> initChannel() async {
    AwesomeNotifications().initialize(
      'resource://drawable/res_app_icon',
      //null,
      [
        NotificationChannel(
          channelKey: 'Notify_Job',
          channelName: 'Job notifications',
          channelDescription: 'แจ้งเตือนเมื่อมีงานเข้าถึงคุณ',
          defaultColor: Colors.white,
          importance: NotificationImportance.High,
          ledColor: Colors.red,
          channelShowBadge: true,
          playSound: true,
          soundSource: 'resource://raw/message_tone_3',
        ),
        NotificationChannel(
          channelKey: 'Notify_Other',
          channelName: 'Other notifications',
          channelDescription: 'แจ้งเตือนอื่น',
          defaultColor: Colors.blue,
          importance: NotificationImportance.High,
          ledColor: Colors.white,
          channelShowBadge: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
            channelGroupkey: 'Notify_Job',
            channelGroupName: 'Job notifications'),
        NotificationChannelGroup(
            channelGroupkey: 'Notify_Other',
            channelGroupName: 'Other notifications'),
      ],
      debug: true,
    );
  }

  Future<void> init() async {
    await Firebase.initializeApp();
    initApp = true;
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    //var rr = await messaging.getNotificationSettings();

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      provisional: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      //provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    //print('User granted permission: ${settings.authorizationStatus}');
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    var registerToken = await generateToken();
    print('==========> FCM TOKEN : $registerToken');

    BoxCacheUtil.setFCMToken(registerToken);

    // _requestPermissions();
    //messageOnBackground();
    //firebaseMessagingBackgroundHandler2(message);
    //FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler2);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    //AwesomeNotifications().ac
    AwesomeNotifications().actionStream.listen(
      (ReceivedAction receivedNotification) async {
        print('receivedActionStream');
        print(receivedNotification);
        if (receivedNotification.payload != null) {
          var playLoad = receivedNotification.payload;
          if (playLoad?['refNo'] == null) return;
          String jobNo = playLoad!['refNo']!;

          if (Get.isRegistered<JobsController>()) {
            Get.find<JobsController>().getJobAssign();
          }

          //FirebaseNotifications()
          //    .showDialogAssignJob(jobNo, receivedNotification.id ?? 0);
          var mapData = NotificationContent(
                  id: receivedNotification.id!,
                  channelKey: receivedNotification.channelKey!)
              .fromMap(receivedNotification.toMap());
          await mapEventDialog(
            receivedNotification.payload,
            notificationContent: mapData,
            isAppOpen: false,
          );
        }

        //Navigator.of(context).pushName(
        //    context, '/NotificationPage', arguments: {
        //  id: receivedNotification.id
        //} // your page params. I recomend to you to pass all *receivedNotification* object
        //    );
      },
    );
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        print('broadcast received for message app');

        //bool isContent = false;
        Map<String, dynamic>? content;
        Map<String, dynamic>? payload;

        NotificationContent? notiContent;

        if (message.data['content'] is String) {
          try {
            content = GLFunc.instance.jDecode(message.data['content']);
          } catch (e) {
            content = message.data['content'];
          }
        } else {
          content = message.data['content'];
        }

        if (GetPlatform.isAndroid) {
          content!['customSound'] = 'resource://raw/message_tone_3';
          content['icon'] = 'resource://drawable/res_app_icon';
        }

        content?['notificationLayout'] = NotificationLayout.BigText;
        content?['hideLargeIconOnExpand'] = false;

        try {
          if (message.data.containsKey('payload')) {
            payload = GLFunc.instance.jDecode(message.data['payload']);
            content?['payload'] = payload!;
          }
        } finally {}

        notiContent = NotificationContent(
          id: content?['id'] ?? DateTime.now().millisecond,
          channelKey: content?['channelKey'] ?? 'Notify_Other',
          autoDismissible: true,
        ).fromMap(content!);

        if (payload?['eventType'] == 'JOB_ASSIGN') {
          showDialogAssignJob(
            (payload?['refNo'] ?? ''),
            content['id'] ?? DateTime.now().millisecond,
          );
        }
        await mapEventDialog(payload, notificationContent: notiContent);
        if (BoxCacheUtil.authenticated) {
          AwesomeNotifications().createNotification(content: notiContent!);
        }

        //NotificationUtils.showNotificationWithNoSound(id)
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('A new onMessageOpenedApp event was published!');
      // Navigator.pushNamed(context, '/message',
      //     arguments: MessageArguments(message, true));
      Map<String, dynamic>? payload;
      Map<String, dynamic>? content;
      if (message.data.containsKey('payload')) {
        payload = GLFunc.instance.jDecode(message.data['payload']);
      }

      content = GLFunc.instance.jDecode(message.data['content']);

      //await mapEventDialog(payload, notificationContent: null);
      if (payload != null) {
        //String jobNo = payload['refNo']!;
        //if (payload['eventType'] == 'JOB_ASSIGN') {
        //  FirebaseNotifications()
        //      .showDialogAssignJob(jobNo, content?['id'] ?? 1);
        //}

        var notiContent = NotificationContent(
          id: content?['id'] ?? DateTime.now().millisecond,
          channelKey: content?['channelKey'] ?? 'Notify_Job',
        ).fromMap(content!);

        await mapEventDialog(
          payload,
          notificationContent: notiContent,
          isAppOpen: false,
        );
      }
    });

    //FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //  print('Message clicked!');
    //});
  }

  Future<void> mapEventDialog(
    Map<String, dynamic>? payload, {
    NotificationContent? notificationContent,
    bool isAppOpen = true,
    bool isbackground = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    prefs.remove('event.triger');
    var vehicle = BoxCacheUtil.getVehicle;
    if (payload != null) {
      prefs.setString('event.triger', GLFunc.instance.jEncode(payload));
      if (notificationContent != null) {
        prefs.setString('event.triger.noti',
            GLFunc.instance.jEncode(notificationContent.toMap()));
      }
      print('prefs:${prefs.get('event.triger')}');
    }
    if (!isAppOpen) {
      return;
    }
    //print(Get.currentRoute);
    var db = AppDatabase.provider;

    print(payload);
    DashboardEntry? dash;
    try {
      dash = await db.summaryDashboard();
    } catch (e) {
      print('dash error:$e');
    }

    if (payload != null) {
      //BoxCacheUtil.box.write('event.triger', payload);
      //var rr = BoxCacheUtil.box.read('event.triger');

      //var tt = prefs.getString('event.triger');
      String event = payload['eventType'].toString();
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      switch (event) {
        case 'event.reject':
        case 'event.accept':
          if (!Get.isRegistered<JobsController>()) {
            Get.put(JobsController());
          }

          if (Get.currentRoute != '/') {
            Get.off(() => const RootInitPage());
          }
          var jCtrl = Get.find<JobsController>();
          if (event == 'event.reject') {
            jCtrl.removeJobPending(payload['jobNo']);
          } else {
            var getAccept =
                await db.getJobHeadersSingle(jobNo: payload['jobNo']);
            if (getAccept != null) {
              isAppOpen = false;
            }
          }

          if (dash != null) {
            if (event == 'event.accept') {
              dash = dash.copyWith(
                totalAccept: dash.totalAccept + 1,
                //jobNo: const d.Value(''),
              );
              await db.updateTable(db.dashboardEntries, dash);
            }

            try {
              jCtrl.removeJobPending(payload['jobNo']);

              var getJobs =
                  await JobRepository().fetchDataJobDetail(payload['jobNo']);
              if (getJobs != null && getJobs.results != null) {
                var mapData =
                    Map<String, dynamic>.from(getJobs.results!['item']);
                //var jobActive = JobHeader.fromMap(mapData);
                var jobInsert = JobHeaderEntry.fromJson(mapData);

                jobInsert = jobInsert.copyWith(
                  userId: d.Value(
                    BoxCacheUtil.getAuthUser!.id,
                  ),
                );
                List<Map<String, dynamic>> itemToUpdate = [];
                if (mapData.containsKey('details')) {
                  itemToUpdate = List.from(mapData['details']);

                  //itemToUpdate =itemToUpdate.map((e) {
                  //  return e;
                  //}).toList();
                  //if ((locations ?? []).isNotEmpty) {
                  //  newDe['listOfLocation'] = locations!
                  //      .where((x) => x.jobDetailId == e.id)
                  //      .map((e) => e.toMap())
                  //      .toList();
                  //} else {
                  //  newDe['listOfLocation'] =
                  //      e.locations.map((e) => e.toMap()).toList();

                  //  newDe.remove('locations');
                  //}
                }

                await db.jobHeaderEntries.insertOnConflictUpdate(jobInsert);

                await JobService().addDetail(itemToUpdate);
              }
            } catch (e) {
              print('errro auto insert data');
            }
          }

          if (isAppOpen && !isbackground) {
            dialogUtils.dialogCustom(
                barrierDismissible: false,
                onWillPop: false,
                content: Column(
                  children: [
                    Icon(
                      Icons.info,
                      size: 60,
                      color: Colors.blue.shade400,
                    ),
                    Text(
                      notificationContent!.body.toString(),
                      style: const TextStyle(
                        fontSize: 15.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    //Padding(
                    //  padding: const EdgeInsets.all(8),
                    //  child: SizedBox(
                    //    width: Get.size.width,
                    //    child: ButtonWidgets.okButtonOutline(
                    //      onTab: () {
                    //        if (Get.currentRoute == '/') {
                    //          //Get.find<JobsController>().getJobAssign();
                    //        }
                    //        Get.back();
                    //      },
                    //    ),
                    //  ),
                    //)
                  ],
                ),
                actions: [
                  ButtonWidgets.okButtonOutline(onTab: () {
                    if (Get.currentRoute == '/') {
                      //Get.find<JobsController>().getJobAssign();
                    }
                    Get.back();
                    //prefs.containsKey('event.triger');
                    if (event == 'event.accept') {
                      Get.off(
                        () => JobDetailPage(),
                        transition: Transition.rightToLeft,
                        //binding: JobBinding(),
                        arguments: {
                          'title': payload['jobNo'],
                          'jobNo': payload['jobNo'],
                          "status": 'ACCEPT_WEB',
                        },
                      );
                    }
                    NotificationUtils.cancelNotification(
                        notificationContent.id!);
                  }),
                ]);
          }

          break;
        case 'event.start':
        case 'event.finish':
          if (event == 'event.finish') {
            //
            if (await AppDatabase.provider
                    .getJobHeadersSingle(jobNo: payload['jobNo']) !=
                null) {
              await AppDatabase.provider.deleteJobLocal(payload['jobNo']);

              var dash = await db.summaryDashboard();
              dash = dash!.copyWith(
                total: 0,
                totalDelvery: 0,
                totalPickup: 0,
                totalAccept: dash.totalAccept,
                jobNo: const d.Value(''),
              );
              await db.updateTable(db.dashboardEntries, dash);
            }
          } else {
            if (!Get.isRegistered<JobsController>()) {
              Get.put(JobsController());
            }
            Get.find<JobsController>().fetchPage();
          }
          if (!isbackground) {
            if (Get.currentRoute != '/' && appActive) {
              Get.off(() => const RootInitPage());
            }
            // licensePlate

            if (payload['licensePlate'] == vehicle?.licensePlate &&
                vehicle?.licensePlate != null) {
              Future.delayed(const Duration(milliseconds: 500)).then((_) {
                dialogUtils.dialogCustom(
                  barrierDismissible: false,
                  onWillPop: false,
                  content: Column(
                    children: [
                      Icon(
                        Icons.info,
                        size: 60,
                        color: Colors.blue.shade400,
                      ),
                      Text(
                        notificationContent!.body.toString(),
                        style: const TextStyle(
                          fontSize: 15.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  actions: [
                    ButtonWidgets.okButtonOutline(
                      onTab: () async {
                        //prefs.containsKey('event.triger');
                        Get.back();
                        if (Get.currentRoute == '/') {
                        } else if (Get.currentRoute != '/') {
                          Get.off(() => const RootInitPage());
                        }
                        NotificationUtils.cancelNotification(
                            notificationContent.id!);
                      },
                    ),
                  ],
                );
              });
            }
          }
          break;
        case 'event.remove.assignment':
        case 'event.remove':
          if (event == 'event.remove') {
            //var getJob = await (db.jobHeaderEntries.select()
            //      ..where((x) => x.jobNo.equals('${payload['jobNo']}')))
            //    .getSingleOrNull();

            //if (getJob != null) {}

            await AppDatabase.provider.deleteJobLocal(payload['jobNo']);

            if (dash != null) {
              dash = dash.copyWith(
                totalAccept: dash.totalAccept != 0 ? dash.totalAccept - 1 : 0,
                jobNo: const d.Value(''),
              );
              await db.updateTable(db.dashboardEntries, dash);
            }
            if (Get.currentRoute != '/') {
              Get.off(() => const RootInitPage());
            }
          } else {
            var getDetail = await db.getJobDetailSingle(id: payload['id']);
            if (getDetail != null) {
              db.jobDetailEntries
                  .deleteWhere((x) => x.id.equals(getDetail.id!));
              db.jobLocationEntries
                  .deleteWhere((x) => x.jobDetailId.equals(getDetail.id!));

              if (Get.currentRoute == '/JobDetailPage') {
                Get.find<JobDetailController>(tag: 'detail-${payload['jobNo']}')
                    .initAssignentLoad();
              } else if (Get.currentRoute == '/LocationPage') {
                Get.back();
              }
            }
          }
          //event.remove.assignment

          if (!isbackground) {
            if (payload['licensePlate'] == vehicle?.licensePlate &&
                vehicle?.licensePlate != null) {
              dialogUtils.dialogCustom(
                barrierDismissible: false,
                onWillPop: false,
                content: Column(
                  children: [
                    Icon(
                      Icons.info,
                      size: 60,
                      color: Colors.blue.shade400,
                    ),
                    Text(
                      notificationContent!.body.toString(),
                      style: const TextStyle(
                        fontSize: 15.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  ButtonWidgets.okButtonOutline(
                    onTab: () {
                      //final prefs = await SharedPreferences.getInstance();
                      //prefs.containsKey('event.triger');
                      Get.back();
                      if (Get.currentRoute == '/') {
                      } else if (Get.currentRoute != '/') {
                        Get.off(() => const RootInitPage());
                      }

                      NotificationUtils.cancelNotification(
                          notificationContent.id!);
                    },
                  ),
                ],
              );
            } else {
              GLFunc.showSnackbar(
                showIsEasyLoading: true,
                message: notificationContent!.body.toString(),
                type: SnackType.IEL,
              );
            }
          }

          break;
        case 'event.signout':
          NotificationUtils.cancelNotification(notificationContent!.id!);
          if (!Get.isRegistered<AuthService>()) {
            Get.lazyPut(() => AuthService());
          }
          Get.find<AuthService>().signOut();
          break;
        case 'JOB_ASSIGN':
          //if (payload['licensePlate'] == vehicle?.licensePlate &&
          //    vehicle?.licensePlate != null) {
          showDialogAssignJob(
            (payload['refNo'] ?? ''),
            notificationContent?.id ?? DateTime.now().millisecond,
          );
          if (notificationContent != null) {
            NotificationUtils.cancelNotification(notificationContent.id!);
          }

          if (Get.currentRoute == '/') {
            Get.find<JobsController>().trigerReload();
          }
          //}

          break;
        default:
      }
    }
  }

  void showDialogAssignJob(String jobNo, [int id = 0]) {
    var auth = BoxCacheUtil.getAuthUser;
    //await Prefs.getAuthUser;
    if (Get.isDialogOpen!) {
      Get.back();
    }
    if (auth == null) {
      GLFunc.showSnackbar(
        message: 'กรุณาเข้าสู่ระบบเพื่อเริ่มงาน',
        showIsEasyLoading: true,
        type: SnackType.INFO,
      );
      return;
    }

    DialogUtils().dialogCustom(
      barrierDismissible: true,
      title: Text('title.notify'.tr),
      content: SizedBox(
        width: Get.size.width * .6,
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                jobNo,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'เลขที่ใบงาน',
                style: TextStyle(
                  fontSize: 15.5,
                  //fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              'คุณ ${auth.userThName} มีงานเข้ามาใหม่',
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('โปรดตรวจสอบรายละเอียดก่อนรับงาน'),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenColor01,
              ),
              onPressed: () async {
                //String? jobNo = message.data['refNo'];

                //Get.back(closeOverlays: true);

                //var finJob = Get.find<JobsController>(tag: 'detail-$jobNo');
                //try {
                //  //Get.delete(tag: 'detail-$jobNo');
                //  //Get.reload(tag: 'detail-$jobNo', force: true);
                //  Get.reload<JobDetailController>();
                //} catch (e) {}

                final prefs = await SharedPreferences.getInstance();
                //prefs.containsKey('event.triger');
                prefs.remove('event.triger');
                if (GetUtils.isNullOrBlank(jobNo)!) {
                  GLFunc.showSnackbar(
                    message: 'ผิดพลาด ไม่พบใบสั่งงาน',
                    type: SnackType.ERROR,
                  );
                  return;
                }
                //var mapDataToUpdat = JobUpdateStatusFormModel();

                Get.back();
                try {
                  NotificationUtils.cancelNotification(id);
                } catch (e) {}
                Get.off(const RootInitPage());
                if (Get.currentRoute != '/') {
                  await Future.delayed(const Duration(milliseconds: 200));
                  await Get.to(
                    () => JobDetailPage(),
                    transition: Transition.rightToLeft,
                    arguments: {
                      'title': jobNo,
                      'jobNo': jobNo,
                      "status": JobStatus.ASSIGN.name,
                    },
                  );
                } else {
                  await Get.to(
                    () => JobDetailPage(),
                    transition: Transition.rightToLeft,
                    arguments: {
                      'title': jobNo,
                      'jobNo': jobNo,
                      "status": JobStatus.ASSIGN.name,
                    },
                  );
                }

                //JobRepository().putJobUpdateStatus(mapDataToUpdat);
              },
              child: Text(
                'แสดงรายละเอียด'.tr,
                style: const TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  static Future<List<NotificationPermission>> requestUserPermissions(
      BuildContext context,
      {
      // if you only intends to request the permissions until app level, set the channelKey value to null
      required String? channelKey,
      required List<NotificationPermission> permissionList}) async {
    // Check if the basic permission was conceived by the user
    //if (!await requestBasicPermissionToSendNotifications(context)) {
    //  return [];
    //}

    // Check which of the permissions you need are allowed at this time
    List<NotificationPermission> permissionsAllowed =
        await AwesomeNotifications().checkPermissionList(
            channelKey: channelKey, permissions: permissionList);

    // If all permissions are allowed, there is nothing to do
    if (permissionsAllowed.length == permissionList.length) {
      return permissionsAllowed;
    }

    // Refresh the permission list with only the disallowed permissions
    List<NotificationPermission> permissionsNeeded =
        permissionList.toSet().difference(permissionsAllowed.toSet()).toList();

    // Check if some of the permissions needed request user's intervention to be enabled
    List<NotificationPermission> lockedPermissions =
        await AwesomeNotifications().shouldShowRationaleToRequest(
            channelKey: channelKey, permissions: permissionsNeeded);

    // If there is no permissions depending on user's intervention, so request it directly
    if (lockedPermissions.isEmpty) {
      // Request the permission through native resources.
      await AwesomeNotifications().requestPermissionToSendNotifications(
          channelKey: channelKey, permissions: permissionsNeeded);

      // After the user come back, check if the permissions has successfully enabled
      permissionsAllowed = await AwesomeNotifications().checkPermissionList(
          channelKey: channelKey, permissions: permissionsNeeded);
    } else {
      // If you need to show a rationale to educate the user to conceived the permission, show it
      await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                backgroundColor: const Color(0xfffbfbfb),
                title: const Text(
                  'Awesome Notificaitons needs your permission',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/animated-clock.gif',
                      height: MediaQuery.of(context).size.height * 0.3,
                      fit: BoxFit.fitWidth,
                    ),
                    Text(
                      'To proceede, you need to enable the permissions above${channelKey?.isEmpty ?? true ? '' : ' on channel $channelKey'}:',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      lockedPermissions
                          .join(', ')
                          .replaceAll('NotificationPermission.', ''),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Deny',
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      )),
                  TextButton(
                    onPressed: () async {
                      // Request the permission through native resources. Only one page redirection is done at this point.
                      await AwesomeNotifications()
                          .requestPermissionToSendNotifications(
                              channelKey: channelKey,
                              permissions: lockedPermissions);

                      // After the user come back, check if the permissions has successfully enabled
                      permissionsAllowed = await AwesomeNotifications()
                          .checkPermissionList(
                              channelKey: channelKey,
                              permissions: lockedPermissions);

                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Allow',
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ));
    }

    // Return the updated list of allowed permissions
    return permissionsAllowed;
  }

  Future<String?> generateToken() async {
    final tokenKey = await FirebaseMessaging.instance.getToken();
    // print('FCM TOKEN =================== $tokenKey');
    token = tokenKey;
    return tokenKey;
  }

  Future<void> messageOnBackground() async {
    //{void Function(Map<String, dynamic>? v)? callback}
    //FirebaseMessaging.onBackgroundMessage((remoteMs) {
    //  return firebaseMessagingBackgroundHandler2(remoteMs, callback: callback);
    //});
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();
    //FirebaseMessaging.onBackgroundMessage((message) async {
    //  Logger.write("_messaging onBackgroundMessage: $message");
    //  //firebaseMessagingBackgroundHandler2(message);
    //});

    //FirebaseMessaging.onMessage.listen((remote) {
    //  Logger.write("_messaging onMessage: $remote");
    //  firebaseMessagingBackgroundHandler2(remote);
    //});

    //FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler2);
  }

  //Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //  // If you're going to use other Firebase services in the background, such as Firestore,
  //  // make sure you call `initializeApp` before using other Firebase services.
  //  if (initApp == false) await init();
  //  // await Firebase.initializeApp();

  //  print('Handling a background message ${message.messageId}');

  //  // if (!AwesomeStringUtils.isNullOrEmpty(message.notification?.title,
  //  //         considerWhiteSpaceAsEmpty: true) ||
  //  //     !AwesomeStringUtils.isNullOrEmpty(message.notification?.body,
  //  //         considerWhiteSpaceAsEmpty: true)) {
  //  //   print('message also contained a notification: ${message.notification}');

  //  //   String? imageUrl;
  //  //   imageUrl ??= message.notification!.android?.imageUrl;
  //  //   imageUrl ??= message.notification!.apple?.imageUrl;

  //  //   Map<String, dynamic> notificationAdapter = {
  //  //     // NOTIFICATION_CHANNEL_KEY: 'Notify_Job',
  //  //     NOTIFICATION_ID: message.data[NOTIFICATION_CONTENT]?[NOTIFICATION_ID] ??
  //  //         message.messageId ??
  //  //         Random().nextInt(2147483647),
  //  //     NOTIFICATION_TITLE: message.data[NOTIFICATION_CONTENT]
  //  //             ?[NOTIFICATION_TITLE] ??
  //  //         message.notification?.title,
  //  //     NOTIFICATION_BODY: message.data[NOTIFICATION_CONTENT]
  //  //             ?[NOTIFICATION_BODY] ??
  //  //         message.notification?.body,
  //  //     NOTIFICATION_LAYOUT:
  //  //         AwesomeStringUtils.isNullOrEmpty(imageUrl) ? 'Default' : 'BigPicture',
  //  //     NOTIFICATION_BIG_PICTURE: imageUrl,
  //  //     // NOTIFICATION_ENABLE_VIBRATION:
  //  //     //     message.data[NOTIFICATION_ENABLE_VIBRATION],
  //  //   };

  //  //   AwesomeNotifications().createNotificationFromJsonData(notificationAdapter);
  //  // } else {

  //  // }
  //  AwesomeNotifications().createNotificationFromJsonData(message.data);
  //}

//import 'package:flutter_localizations/flutter_localizations.dart';
  /// Define a top-level named handler which background/terminated messages will
  /// call.
  ///
  /// To verify things are working, check out the native platform logs.
  //Future<void> firebaseMessagingBackgroundHandler2(
  //  RemoteMessage message,
  //) async {
  //  // If you're going to use other Firebase services in the background, such as Firestore,
  //  // make sure you call `initializeApp` before using other Firebase services.
  //  //await Firebase.initializeApp();

  //  print('Handling a background message ${message.messageId}');

  //  if (!AwesomeStringUtils.isNullOrEmpty(message.notification?.title,
  //          considerWhiteSpaceAsEmpty: true) ||
  //      !AwesomeStringUtils.isNullOrEmpty(message.notification?.body,
  //          considerWhiteSpaceAsEmpty: true)) {
  //    print('message also contained a notification: ${message.notification}');

  //    String? imageUrl;
  //    imageUrl ??= message.notification!.android?.imageUrl;
  //    imageUrl ??= message.notification!.apple?.imageUrl;

  //    Map<String, dynamic> notificationAdapter = {
  //      NOTIFICATION_CHANNEL_KEY: 'Noty_Other',
  //      NOTIFICATION_ID: message.data[NOTIFICATION_CONTENT]?[NOTIFICATION_ID] ??
  //          message.messageId ??
  //          Random().nextInt(2147483647),
  //      NOTIFICATION_TITLE: message.data[NOTIFICATION_CONTENT]
  //              ?[NOTIFICATION_TITLE] ??
  //          message.notification?.title,
  //      NOTIFICATION_BODY: message.data[NOTIFICATION_CONTENT]
  //              ?[NOTIFICATION_BODY] ??
  //          message.notification?.body,
  //      NOTIFICATION_LAYOUT: AwesomeStringUtils.isNullOrEmpty(imageUrl)
  //          ? 'Default'
  //          : 'BigPicture',
  //      NOTIFICATION_BIG_PICTURE: imageUrl,
  //      // NOTIFICATION_ENABLE_VIBRATION:
  //      //     message.data[NOTIFICATION_ENABLE_VIBRATION],
  //    };

  //    AwesomeNotifications()
  //        .createNotificationFromJsonData(notificationAdapter);
  //  } else {
  //    //var remoteData = message.data;
  //    //Map<String, dynamic> item = remoteData;
  //    var itemContent = json.decode(message.data['content']);
  //    itemContent['channelKey'] = 'Notify_Job';
  //    itemContent['id'] = GLFunc.instance.getRandomNumer();
  //    message.data['content'] = itemContent;
  //    AwesomeNotifications().createNotificationFromJsonData(message.data);
  //  }
  //  //if (callback != null) callback(message.data);
  //}

  Future<void> cancelNotifications() async {
    // await flutterLocalNotificationsPlugin.cancel(NOTIFICATION_ID);
  }

  Future<void> initMessageChannel() async {
    // channel = const AndroidNotificationChannel(
    //   'high_importance_channel', // id
    //   'High Importance Notifications', // title
    //   description: 'This channel is used for important notifications.',
    //   importance: Importance.high,
    // );

    // // flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // /// Create an Android Notification Channel.
    // ///
    // /// We use this channel in the `AndroidManifest.xml` file to override the
    // /// default FCM channel to enable heads up notifications.
    // await flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()
    //     ?.createNotificationChannel(channel!);

    // /// Update the iOS foreground notification presentation options to allow
    // /// heads up notifications.
    // await FirebaseMessaging.instance
    //     .setForegroundNotificationPresentationOptions(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   RemoteNotification? notification = message.notification;
    //   AndroidNotification? android = message.notification?.android;
    //   if (notification != null && android != null && !kIsWeb) {
    //     flutterLocalNotificationsPlugin.show(
    //         notification.hashCode,
    //         notification.title,
    //         notification.body,
    //         NotificationDetails(
    //           android: AndroidNotificationDetails(
    //             channel!.id,
    //             channel!.name,
    //             //  ,
    //             channelDescription: channel!.description,
    //             // TODO add a proper drawable resource to android, for now using
    //             //      one that already exists in example app.
    //             icon: 'launch_background',
    //           ),
    //         ));
    //   }
    // });

    // FirebaseMessaging.onMessageOpenedApp.listen(
    //   (RemoteMessage message) {
    //     print('A new onMessageOpenedApp event was published!');
    //     // Navigator.pushNamed(context, '/message',
    //     //     arguments: MessageArguments(message, true));
    //   },
    // );
  }

  String constructFCMPayload(String? token) {
    _messageCount++;
    return jsonEncode({
      'token': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!',
        'count': _messageCount.toString(),
      },
      'notification': {
        'title': 'Hello FlutterFire!',
        'body': 'This notification (#$_messageCount) was created via FCM!',
      },
    });
  }

  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    // tz.initializeTimeZones();
    // final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    // tz.setLocalLocation(tz.getLocation(timeZoneName!));
  }

  // FirebaseMessaging _firebaseMessaging;
  // void setUpFirebase(BuildContext context) {
  //   _firebaseMessaging = FirebaseMessaging();
  //   _firebaseCloudMessagingListeners(context);
  // }
  // void _firebaseCloudMessagingListeners(BuildContext context) {
  //   if (Platform.isIOS) _iosPermission();

  //   _firebaseMessaging.getToken().then((token) {
  //     print("FCM Token: " + token);
  //   });

  //   _firebaseMessaging.subscribeToTopic(Constant.FCM_TOPIC);

  //   _firebaseMessaging.configure(
  //     onMessage: (Map<String, dynamic> message) async {
  //       print('on message $message');
  //     },
  //     onResume: (Map<String, dynamic> message) async {
  //       print('on resume $message');
  //     },
  //     onLaunch: (Map<String, dynamic> message) async {
  //       print('on launch $message');
  //     },
  //   );
  // }

  // void _iosPermission() {
  //   _firebaseMessaging.requestNotificationPermissions(
  //       IosNotificationSettings(sound: true, badge: true, alert: true));
  //   _firebaseMessaging.onIosSettingsRegistered
  //       .listen((IosNotificationSettings settings) {
  //     print("Settings registered: $settings");
  //   });
  // }
}
