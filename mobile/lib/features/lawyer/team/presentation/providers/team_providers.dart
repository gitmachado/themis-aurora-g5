import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/errors/either_failure_extensions.dart';
import '../../../../../../shared/network/websocket_client.dart';

import '../../../../../../shared/network/api_client.dart';
import '../../data/datasources/team_remote_data_source.dart';
import '../../data/repositories/team_repository_impl.dart';
import '../../domain/entities/team_member.dart';
import '../../domain/entities/team_member_created.dart';
import '../../domain/entities/team_member_draft.dart';
import '../../domain/repositories/team_repository.dart';
import '../../domain/usecases/team_use_cases.dart';

final teamRemoteDataSourceProvider = Provider<TeamRemoteDataSource>((ref) {
  return TeamRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return TeamRepositoryImpl(ref.watch(teamRemoteDataSourceProvider));
});

final listTeamUseCaseProvider = Provider<ListTeamUseCase>((ref) {
  return ListTeamUseCase(ref.watch(teamRepositoryProvider));
});

final getTeamMemberUseCaseProvider = Provider<GetTeamMemberUseCase>((ref) {
  return GetTeamMemberUseCase(ref.watch(teamRepositoryProvider));
});

final addTeamMemberUseCaseProvider = Provider<AddTeamMemberUseCase>((ref) {
  return AddTeamMemberUseCase(ref.watch(teamRepositoryProvider));
});

final updateTeamMemberPermissionsUseCaseProvider =
    Provider<UpdateTeamMemberPermissionsUseCase>((ref) {
      return UpdateTeamMemberPermissionsUseCase(
        ref.watch(teamRepositoryProvider),
      );
    });

final removeTeamMemberUseCaseProvider = Provider<RemoveTeamMemberUseCase>((
  ref,
) {
  return RemoveTeamMemberUseCase(ref.watch(teamRepositoryProvider));
});

/// Lista de advogados da equipe do escritório.
final teamListProvider =
    AsyncNotifierProvider<TeamListNotifier, List<TeamMember>>(
      TeamListNotifier.new,
    );

class TeamListNotifier extends AsyncNotifier<List<TeamMember>> {
  StreamSubscription? _subscription;

  @override
  Future<List<TeamMember>> build() async {
    ref.watch(webSocketClientProvider); // Cria dependência reativa
    _listenToEvents();
    ref.onDispose(() => _subscription?.cancel());
    return _fetch();
  }

  void _listenToEvents() {
    _subscription?.cancel();
    _subscription = ref.read(webSocketClientProvider).events.listen((event) {
      // Refresh on reconnect to ensure fresh data
      if (event.type == 'connected') {
        refresh();
      }
    });
  }

  Future<List<TeamMember>> _fetch() async {
    return (await ref.read(listTeamUseCaseProvider)()).getOrThrow();
  }

  Future<void> refresh() async {
    try {
      final members = await _fetch();
      state = AsyncValue.data(members);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Adiciona um advogado e atualiza a lista localmente sem refetch.
  /// Retorna o membro criado + a senha temporária (UMA única vez).
  Future<TeamMemberCreated> addMember(TeamMemberDraft draft) async {
    final created = (await ref.read(addTeamMemberUseCaseProvider)(
      draft,
    )).getOrThrow();

    final current = state.valueOrNull ?? const <TeamMember>[];
    state = AsyncData(
      [...current, created.member]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
    );
    return created;
  }

  void replaceMember(TeamMember member) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData([
      for (final m in current)
        if (m.id == member.id) member else m,
    ]);
  }

  void removeLocally(String id) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.where((m) => m.id != id).toList());
  }
}

/// Detalhe de um único membro — busca direta no servidor.
final teamMemberDetailProvider = FutureProvider.family<TeamMember, String>((
  ref,
  id,
) async {
  return (await ref.watch(getTeamMemberUseCaseProvider)(id)).getOrThrow();
});
