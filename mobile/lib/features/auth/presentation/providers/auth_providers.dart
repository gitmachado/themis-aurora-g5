import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/network/api_client.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthSession?>>((ref) {
      return AuthController(ref.watch(authRepositoryProvider));
    });

final currentAccountProvider = FutureProvider<Account>((ref) async {
  final session = ref.watch(authControllerProvider).valueOrNull;
  if (session?.account != null) return session!.account!;
  return ref.read(authRepositoryProvider).getAccount();
});

final accountActionsProvider = Provider<AccountActions>((ref) {
  return AccountActions(ref);
});

class AuthController extends StateNotifier<AsyncValue<AuthSession?>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncData(null));

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final session = await _repository.login(email: email, password: password);
      state = AsyncData(session);
      return session;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncData(null);
  }

  void updateSessionAccount(Account account) {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(account: account));
    }
  }
}

final class AccountActions {
  final Ref _ref;

  const AccountActions(this._ref);

  Future<Account> updateNotificationPreferences(
    Map<String, bool> preferences,
  ) async {
    final account = await _ref
        .read(authRepositoryProvider)
        .updateNotificationPreferences(preferences);
    _ref.read(authControllerProvider.notifier).updateSessionAccount(account);
    return account;
  }

  Future<Account> uploadAvatar({
    required String filePath,
    required String fileName,
  }) async {
    final account = await _ref
        .read(authRepositoryProvider)
        .uploadAvatar(filePath: filePath, fileName: fileName);
    _ref.read(authControllerProvider.notifier).updateSessionAccount(account);
    _ref.invalidate(currentAccountProvider);
    return account;
  }
}
