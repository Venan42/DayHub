import 'package:dio/dio.dart';
import '../models/token_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<TokenModel> register({
    required String name,
    required String email,
    required String password,
  });

  Future<TokenModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> getMe(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<TokenModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    return TokenModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TokenModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return TokenModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> getMe(String token) async {
    final response = await _dio.get(
      '/auth/me',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}