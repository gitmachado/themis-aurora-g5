import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/errors/either_failure_extensions.dart';

import '../../../../shared/network/api_client.dart';
import '../../../../shared/services/push_notification_service.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_use_cases.dart';
import '../../domain/usecases/google_sign_in_use_case.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(apiClientProvider));
});

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  return PushNotificationService(ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final googleSignInUseCaseProvider = Provider<GoogleSignInUseCase>((ref) {
  return GoogleSignInUseCase(ref.watch(authRepositoryProvider));
});

final restoreSessionUseCaseProvider = Provider<RestoreSessionUseCase>((ref) {
  return RestoreSessionUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentAccountUseCaseProvider = Provider<GetCurrentAccountUseCase>((
  ref,
) {
  return GetCurrentAccountUseCase(ref.watch(authRepositoryProvider));
});

final updateNotificationPreferencesUseCaseProvider =
    Provider<UpdateNotificationPreferencesUseCase>((ref) {
      return UpdateNotificationPreferencesUseCase(
        ref.watch(authRepositoryProvider),
      );
    });

final uploadAvatarUseCaseProvider = Provider<UploadAvatarUseCase>((ref) {
  return UploadAvatarUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthSession?>>((ref) {
      return AuthController(
        loginUseCase: ref.watch(loginUseCaseProvider),
        logoutUseCase: ref.watch(logoutUseCaseProvider),
        googleSignInUseCase: ref.watch(googleSignInUseCaseProvider),
        pushNotificationService: ref.watch(pushNotificationServiceProvider),
      );
    });

final currentAccountProvider = FutureProvider<Account>((ref) async {
  final session = ref.watch(authControllerProvider).valueOrNull;
  if (session?.account != null) return session!.account!;
  return (await ref.read(getCurrentAccountUseCaseProvider)()).getOrThrow();
});

final accountActionsProvider = Provider<AccountActions>((ref) {
  return AccountActions(ref);
});

class AuthController extends StateNotifier<AsyncValue<AuthSession?>> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  final PushNotificationService _pushNotificationService;

  AuthController({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GoogleSignInUseCase googleSignInUseCase,
    required PushNotificationService pushNotificationService,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _googleSignInUseCase = googleSignInUseCase,
       _pushNotificationService = pushNotificationService,
       super(const AsyncData(null));

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final session = (await _loginUseCase(
        email: email,
        password: password,
      )).getOrThrow();
      state = AsyncData(session);

      try {
        await _pushNotificationService.initializePushNotifications();
      } catch (e) {
        log('[AuthController] Push init failed: $e');
      }

      return session;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<AuthSession> googleSignIn() async {
    state = const AsyncLoading();
    try {
      final session = (await _googleSignInUseCase()).getOrThrow();
      state = AsyncData(session);

      try {
        await _pushNotificationService.initializePushNotifications();
      } catch (e) {
        log('[AuthController] Push init failed: $e');
      }

      return session;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // Import this locally to avoid dependency everywhere if not needed, or better, handle in repository.
      // But we can just use the repository's logout which we should implement properly later.
      // For now, call the logout use case which clears the token.
      (await _logoutUseCase()).getOrThrow();
      state = const AsyncData(null);
    } catch (_) {}
  }

  void updateSessionAccount(Account account) {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(account: account));
    }
  }

  void setSession(AuthSession? session) {
    state = AsyncData(session);
    if (session != null) {
      try {
        _pushNotificationService.initializePushNotifications();
      } catch (e) {
        log('[AuthController] Push init failed: $e');
      }
    }
  }
}

final class AccountActions {
  final Ref _ref;

  const AccountActions(this._ref);

  Future<Account> updateNotificationPreferences(
    Map<String, bool> preferences,
  ) async {
    final account =
        (await _ref
                .read(updateNotificationPreferencesUseCaseProvider)
                .call(preferences))
            .getOrThrow();
    _ref.read(authControllerProvider.notifier).updateSessionAccount(account);
    return account;
  }

  Future<Account> uploadAvatar({
    required String filePath,
    required String fileName,
  }) async {
    final account =
        (await _ref
                .read(uploadAvatarUseCaseProvider)
                .call(filePath: filePath, fileName: fileName))
            .getOrThrow();
    _ref.read(authControllerProvider.notifier).updateSessionAccount(account);
    _ref.invalidate(currentAccountProvider);
    return account;
  }
}
