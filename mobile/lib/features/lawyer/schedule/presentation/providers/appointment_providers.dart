import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../shared/errors/either_failure_extensions.dart';
import '../../../../../../shared/network/api_client.dart';
import '../../../../../../shared/network/websocket_client.dart';
import '../../data/datasources/appointment_remote_data_source.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../domain/usecases/appointment_use_cases.dart';

// Data source
final appointmentRemoteDataSourceProvider =
    Provider<AppointmentRemoteDataSource>((ref) {
  return AppointmentRemoteDataSource(ref.watch(apiClientProvider));
});

// Repository
final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepositoryImpl(
    ref.watch(appointmentRemoteDataSourceProvider),
  );
});

// Use cases
final getAppointmentsUseCaseProvider = Provider<GetAppointmentsUseCase>((ref) {
  return GetAppointmentsUseCase(ref.watch(appointmentRepositoryProvider));
});

final createAppointmentUseCaseProvider = Provider<CreateAppointmentUseCase>((ref) {
  return CreateAppointmentUseCase(ref.watch(appointmentRepositoryProvider));
});

final updateAppointmentStatusUseCaseProvider = Provider<UpdateAppointmentStatusUseCase>((ref) {
  return UpdateAppointmentStatusUseCase(ref.watch(appointmentRepositoryProvider));
});

final updateAppointmentUseCaseProvider = Provider<UpdateAppointmentUseCase>((ref) {
  return UpdateAppointmentUseCase(ref.watch(appointmentRepositoryProvider));
});

// Selected date
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Appointments provider
final appointmentsProvider =
    AsyncNotifierProvider<AppointmentsNotifier, List<Appointment>>(
  AppointmentsNotifier.new,
);

class AppointmentsNotifier extends AsyncNotifier<List<Appointment>> {
  StreamSubscription? _subscription;

  @override
  Future<List<Appointment>> build() async {
    _listenToEvents();
    ref.onDispose(() => _subscription?.cancel());
    return _fetch();
  }

  void _listenToEvents() {
    _subscription?.cancel();
    _subscription = ref.watch(webSocketClientProvider).events.listen((event) {
      if (event.type == 'appointment:created' ||
          event.type == 'appointment:updated' ||
          event.type == 'appointment:deleted' ||
          event.type == 'connected') {
        refresh();
      }
    });
  }

  Future<List<Appointment>> _fetch() async {
    final now = DateTime.now();
    // Busca dos últimos 2 meses até os próximos 12 meses
    final start = DateTime(now.year, now.month - 2, 1);
    final end = DateTime(now.year + 1, now.month + 6, 1);

    final result = await ref.read(getAppointmentsUseCaseProvider)(start, end);
    return result.getOrThrow();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      state = AsyncValue.data(await _fetch());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// View mode
final scheduleViewModeProvider = StateProvider<String>((ref) => 'today');

// Show history (completed/canceled)
final showHistoryProvider = StateProvider<bool>((ref) => false);

// Filtered appointments by selected date and view mode (excludes history by default)
final appointmentsByDateProvider = Provider<List<Appointment>>((ref) {
  final appointments = ref.watch(appointmentsProvider).valueOrNull ?? const [];
  final selectedDate = ref.watch(selectedDateProvider);
  final mode = ref.watch(scheduleViewModeProvider);
  final showHistory = ref.watch(showHistoryProvider);

  return appointments.where((appointment) {
    // Filter by history visibility
    if (showHistory) {
      if (!appointment.isCompleted && !appointment.isCanceled) return false;
    } else {
      if (appointment.isCompleted || appointment.isCanceled) return false;
    }

    final appDate = appointment.scheduledAt;
    if (mode == 'week') {
      final startOfWeek = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      ).subtract(Duration(days: selectedDate.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));
      return appDate.isAfter(startOfWeek.subtract(const Duration(milliseconds: 1))) &&
          appDate.isBefore(endOfWeek);
    } else if (mode == 'month') {
      return appDate.year == selectedDate.year && appDate.month == selectedDate.month;
    } else {
      // 'today', 'tomorrow', 'custom_day'
      return appDate.year == selectedDate.year &&
          appDate.month == selectedDate.month &&
          appDate.day == selectedDate.day;
    }
  }).toList()
    ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
});

// Only history (completed/canceled)
final appointmentHistoryProvider = Provider<List<Appointment>>((ref) {
  final appointments = ref.watch(appointmentsProvider).valueOrNull ?? const [];
  final selectedDate = ref.watch(selectedDateProvider);
  final mode = ref.watch(scheduleViewModeProvider);

  return appointments.where((appointment) {
    if (!appointment.isCompleted && !appointment.isCanceled) {
      return false;
    }

    final appDate = appointment.scheduledAt;
    if (mode == 'week') {
      final startOfWeek = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      ).subtract(Duration(days: selectedDate.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));
      return appDate.isAfter(startOfWeek.subtract(const Duration(milliseconds: 1))) &&
          appDate.isBefore(endOfWeek);
    } else if (mode == 'month') {
      return appDate.year == selectedDate.year && appDate.month == selectedDate.month;
    } else {
      return appDate.year == selectedDate.year &&
          appDate.month == selectedDate.month &&
          appDate.day == selectedDate.day;
    }
  }).toList()
    ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
});

// Appointments actions
final appointmentActionsProvider =
    Provider<AppointmentActions>((ref) => AppointmentActions(ref));

final class AppointmentActions {
  final Ref _ref;

  const AppointmentActions(this._ref);

  Future<void> create(Map<String, dynamic> data) async {
    final result = await _ref.read(createAppointmentUseCaseProvider).call(data);
    result.getOrThrow();
    _ref.invalidate(appointmentsProvider);
  }

  Future<void> complete(String id) async {
    final result = await _ref.read(updateAppointmentStatusUseCaseProvider).call(id, 'COMPLETED');
    result.getOrThrow();
    _ref.invalidate(appointmentsProvider);
  }

  Future<void> cancel(String id) async {
    final result = await _ref.read(updateAppointmentStatusUseCaseProvider).call(id, 'CANCELED');
    result.getOrThrow();
    _ref.invalidate(appointmentsProvider);
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    final result = await _ref.read(updateAppointmentUseCaseProvider).call(id, data);
    result.getOrThrow();
    _ref.invalidate(appointmentsProvider);
  }
}
