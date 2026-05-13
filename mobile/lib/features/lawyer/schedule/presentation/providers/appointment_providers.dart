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
    final startOfWeek = _getStartOfWeek(DateTime.now());
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final result =
        await ref.read(getAppointmentsUseCaseProvider)(startOfWeek, endOfWeek);
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

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }
}

// Filtered appointments by selected date
final appointmentsByDateProvider = Provider<List<Appointment>>((ref) {
  final appointments = ref.watch(appointmentsProvider).valueOrNull ?? const [];
  final selectedDate = ref.watch(selectedDateProvider);

  return appointments.where((appointment) {
    return appointment.scheduledAt.year == selectedDate.year &&
        appointment.scheduledAt.month == selectedDate.month &&
        appointment.scheduledAt.day == selectedDate.day;
  }).toList()
    ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
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
}
