import 'package:dio/dio.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';


class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 15),
      sendTimeout: Duration(seconds: 10),
    ),
  );


  static Future<Response> post(
    String path,
    dynamic data, {
    String? token,
    bool isJson = false,
  }) async {
   final token1 =  await TokenStorage.getToken();
   if(token1 == null)
   {
    print("token null hai yaha");
   }

    print('fromapiservice'+token1.toString());
    try {
      Options options = Options(
        headers: {
         'Authorization': 'Bearer $token1'

          // 'Content-Type': isJson ? 'application/json' : 'multipart/form-data',
        },
      );
      return await _dio.post(path, data: data, options: options);
    } on DioError catch (e) {
      throw Exception(e.response?.data ?? 'Network error: ${e.message}');
    }catch (e) {
      print('Pritam'+e.toString());
      throw(e);
    }
  }

  static Future<Response> get(
    String path, {
    String? token,
  }) async {
    try {
      Options options = Options(
        headers: {
          'Authorization': token != null ? 'Bearer $token' : null,
        },
      );
      return await _dio.get(path, options: options);
    } on DioError catch (e) {
      throw Exception(e.response?.data ?? 'Network error: ${e.message}');
    }
  }

  static Future<Response> put(
    String path,
    dynamic data, {
    String? token,
  }) async {
    try {
      Options options = Options(
        headers: {
          'Authorization': token != null ? 'Bearer $token' : null,
          'Content-Type': 'application/json',
        },
      );
      return await _dio.put(path, data: data, options: options);
    } on DioError catch (e) {
      throw Exception(e.response?.data ?? 'Network error: ${e.message}');
    }
  }

  static Future<Response> delete(
    String path, {
    String? token,
  }) async {
    try {
      Options options = Options(
        headers: {
          'Authorization': token != null ? 'Bearer $token' : null,
        },
      );
      return await _dio.delete(path, options: options);
    } on DioError catch (e) {
      throw Exception(e.response?.data ?? 'Network error: ${e.message}');
    }
  }

}
