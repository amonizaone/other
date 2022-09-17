import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:imot/common/cache/box_cache.dart';
import 'package:imot/common/dio/api_base_helper.dart';
import 'package:imot/common/dio/dio_connectivity_request_retrier.dart';
import 'package:imot/common/general_function.dart';
import 'package:imot/pages/auth/controller/auth_controller.dart';

class DioLoggingInterceptors {
  final Dio dio;
  final DioConnectivityRequestRetrier requestRetrier;

  DioLoggingInterceptors({required this.dio, required this.requestRetrier});

  //ConnectivityService connectivityService = Get.find();
  // String? csrfToken;

  Interceptor interceptor() {
    return QueuedInterceptorsWrapper(
      onRequest: (RequestOptions request, handler) async {
        //SystemChannels.textInput.invokeMethod('TextInput.hide');
        var uToken = BoxCacheUtil.userToken;
        var storageToken = uToken?.accessToken;
        //Here is line you need
        //CancelToken cancelToken = CancelToken();
        //cancelToken.isCancelled
        //if (request.cancelToken?.isCancelled == true) {
        //request.cancelToken = cancelToken;
        //}

        // await Prefs.getUserToken;

        //if (connectivityService.isOnline) {
        //SystemChannels.textInput.invokeMethod('TextInput.hide');
        //print('requset ${DateTime.now().toIso8601String()}');
        print('REQUEST[${request.uri}] ========> PATH: ${request.path}');
        //LogUtil.printLog(request.headers);
        if (request.data is Map) {
          //print('REQUEST BODY [${json.encode(request.data)}]');
          //LogUtil.printLog(request.data);
        }

        //Log.logi('REQUEST BODY', request.data);
        print('REQUEST TOKEN [Bearer $storageToken]');
        if (!GetUtils.isNullOrBlank(storageToken)!) {
          request.headers.addAll({
            'Authorization': 'Bearer $storageToken',
          });
        }

        return handler.next(request);
        //}
      },
      onError: (DioError e, handler) async {
        // FlavorConfig.instance.baseUrl;
        // Assume 401 stands for token expired
        if (CancelToken.isCancel(e)) {
          //print('Request canceled! '+ err.message)
        } else {
          // handle error.
        }
        if (e.response != null) {
          print('Dio error!');
          print('STATUS: ${e.response?.statusCode}');
          //print('DATA: ${e.response?.data}');
          //print('HEADERS: ${e.response?.headers}');
        } else {
          // Error due to setting up or sending the request
          print('Error sending request!');
          print(e.message);
        }
        var auth = BoxCacheUtil.getAuthUser;
        var uToken = BoxCacheUtil.userToken;
        var refreshTokenLocal = uToken?.refreshToken;

        if (e.response != null &&
            (e.response?.statusCode == 401 || e.response?.statusCode == 403) &&
            refreshTokenLocal != null) {
          // if (e.response?.statusCode == 401) {
          final options = e.response!.requestOptions;
          // String storageToken = await Prefs.getRefreshToken;
          print('on request error');

          try {
            final tokenDio = Dio();
            ApiBaseHelper.setHttps(tokenDio);

            var tokenUrl = Uri.parse(
                '${dotenv.get('BASE_URL_API')}/v1/users/refresh-token}');

            var res = await tokenDio.post(
                '${dotenv.get('BASE_URL_API')}/v1/users/refresh-token',
                data: {
                  "refreshToken": refreshTokenLocal,
                  'userId': auth!.id,
                });
            final Map<String, dynamic> result = res.data;

            String accessToken = result['token']['accessToken'];
            String refreshToken = result['token']['refreshToken'];

            BoxCacheUtil.setUserToken(result['token']);
            BoxCacheUtil.setAuthentication(true);

            final newToken = BoxCacheUtil.userToken?.accessToken;
            options.headers['Authorization'] = 'Bearer $newToken';
            dio.fetch(options).then(
              (r) => handler.resolve(r),
              onError: (e) {
                handler.reject(e);
              },
            );
          } on DioError catch (e) {
            print(e);
            BoxCacheUtil.setAuthentication(false);

            //Future.delayed(const Duration(seconds: 3));
            //Get.find<AuthController>().signout();
            //GLFunc.showSnackbar(message: 'รหัสหมดอายุโปรดทำการเข้าสู่ระบบใหม่');
            //rethrow;
          } finally {
            GLFunc.instance.hideLoading();
          }

          return;
        }
        //print('[====> Respone Error ] ${e.response?.data}');
        //if (e.error is SocketException || e.error is TimeoutException) {
        //  //return handler.next(e);
        //}
        if (_shouldRetry(e)) {
          await requestRetrier.scheduleRequestRetry(e.requestOptions).then(
            (r) => handler.resolve(r),
            onError: (ex) {
              handler.reject(ex);
            },
          );
        }

        // handler.next(e);
        return handler.next(e);
      },
      onResponse: (e, handler) async {
        // print('[====> Respone Success ] ${e.data}');
        if (EasyLoading.isShow) await EasyLoading.dismiss();
        // return e;
        return handler.next(e);
      },
    );
  }

  bool _shouldRetry(DioError err) {
    return err.type == DioErrorType.other &&
        err.error != null &&
        err.error is SocketException;
  }
}

extension RequestOptionsX on RequestOptions {
  static const _kAttemptKey = 'ro_attempt';
  static const _kDisableRetryKey = 'ro_disable_retry';

  int get _attempt => (extra[_kAttemptKey] as int?) ?? 0;

  set _attempt(int value) => extra[_kAttemptKey] = value;

  bool get disableRetry => (extra[_kDisableRetryKey] as bool?) ?? false;

  set disableRetry(bool value) => extra[_kDisableRetryKey] = value;
}
