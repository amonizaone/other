import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:imot/common/app_config.dart';
import 'package:imot/common/dio/dio_connectivity_request_retrier.dart';
import 'package:imot/common/dio/dio_logging_Interceptors.dart';

class ApiBaseHelper {
  //
  static String? url = AppConfig.instance?.baseUrl;

  static bool allowHttps = false;
  static int? timeOut = const Duration(seconds: 60).inMilliseconds;
  static BaseOptions opts = BaseOptions(
    baseUrl: url ?? dotenv.get('BASE_URL_API'),
    responseType: ResponseType.json,
    connectTimeout: timeOut,
    receiveTimeout: timeOut,
  );

  static Dio createDio() {
    Dio intDio = Dio(opts);
    if (allowHttps) setHttps(intDio);

    return intDio;
  }

  static Dio addInterceptors(Dio dio) {
    // dio.interceptors.clear();

    var qWarper = DioLoggingInterceptors(
      dio: dio,
      requestRetrier: DioConnectivityRequestRetrier(
        dio: Dio(),
        connectivity: Connectivity(),
      ),
    );

    dio.interceptors.add(qWarper.interceptor());

    return dio;
  }

  //static dynamic requestInterceptor(RequestOptions options) async {
  //  // Get your JWT token
  //  // token = await storage.read(key: USER_TOKEN);
  //  // const token = AppConstants.TOKEN;
  //  String token = await Prefs.getUserToken;
  //  if (token != '') options.headers.addAll({"Authorization": "Bearer $token"});
  //  return options;
  //}

  static final dio = createDio();
  static final baseAPI = addInterceptors(dio);

  static void setHttps(Dio dio) {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient h) {
      h.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return h;
    };
  }

  Future<Response?> getAsync(String url) async {
    try {
      // Response response = await dio.get(url);
      Response response = await baseAPI.get(url);
      return response;
    } on DioError catch (e) {
      // Handle error
      print(e);
    }
    return null;
  }

  Future<Response?> postAsync(String url, dynamic data) async {
    try {
      Response response = await baseAPI.post(url, data: data);
      return response;
    } on DioError {
      // Handle error

    }
    return null;
  }

  Future<Response?> putAsync(String url, dynamic data) async {
    try {
      Response response = await baseAPI.put(url, data: data);
      return response;
    } on DioError {
      // Handle error
    }
    return null;
  }

  Future<Response?> deleteAsync(String url) async {
    try {
      Response response = await baseAPI.delete(url);
      return response;
    } on DioError {
      // Handle error
    }
    return null;
  }
}
