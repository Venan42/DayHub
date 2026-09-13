import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'jwt_token';

  AuthRepositoryImpl({required this._remoteDataSource, required this._storage});

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final tokenModel = await _remoteDataSource.register(
      name: name,
      email: email,
      password: password,
    );

    await _storage.write(key: _tokenKey, value: tokenModel.accessToken);
    return _mapModelToEntity(tokenModel.user);
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final tokenModel = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    await _storage.write(key: _tokenKey, value: tokenModel.accessToken);
    return _mapModelToEntity(tokenModel.user);
  }

  @override
  Future<UserEntity> getMe() async {
    final token = await getSavedToken();
    if (token == null) {
      throw Exception('Nenhum token encontrado');
    }

    final userModel = await _remoteDataSource.getMe(token);
    return _mapModelToEntity(userModel);
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  @override
  Future<String?> getSavedToken() async {
    return await _storage.read(key: _tokenKey);
  }

  UserEntity _mapModelToEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      name: model.name,
      email: model.email,
      createdAt: model.createdAt,
    );
  }
}
