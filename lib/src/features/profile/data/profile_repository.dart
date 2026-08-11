import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/network/dio_client.dart';
import '../domain/me_entity.dart';

/// `GET /users/me` (PRD §5.2). The single source of the actor's identity,
/// role and school — the login flow calls it immediately after persisting
/// tokens, and the profile screen (§5.2) and role-based shell (§5.7) read the
/// result from [currentUserProvider].
abstract class ProfileRepository {
  /// Throws an [AppError] — never a `DioException`.
  Future<MeEntity> fetchMe();
}

class DioProfileRepository implements ProfileRepository {
  const DioProfileRepository(this._dio);

  final Dio _dio;

  static const String mePath = '/users/me';

  @override
  Future<MeEntity> fetchMe() {
    return guardApiCall(() async {
      final Response<Map<String, dynamic>> response =
          await _dio.get<Map<String, dynamic>>(mePath);

      return MeEntity.fromJson(response.data ?? <String, dynamic>{});
    });
  }
}

final Provider<ProfileRepository> profileRepositoryProvider =
    Provider<ProfileRepository>(
  (Ref ref) => DioProfileRepository(ref.watch(dioProvider)),
);
