import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_settings.dart';
import '../../data/datasources/settings_remote_data_source.dart';

// EVENTS
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class FetchSettings extends SettingsEvent {}

class UpdateSettingChanged extends SettingsEvent {
  final String key;
  final dynamic value;
  const UpdateSettingChanged(this.key, this.value);
  @override
  List<Object?> get props => [key, value];
}

// STATES
abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}
class SettingsLoading extends SettingsState {}
class SettingsLoaded extends SettingsState {
  final UserSettings settings;
  final bool isUpdating; // To show mini-loader during switch change
  const SettingsLoaded(this.settings, {this.isUpdating = false});
  @override
  List<Object?> get props => [settings, isUpdating];
}
class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLOC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsBloc(this.remoteDataSource) : super(SettingsInitial()) {
    on<FetchSettings>(_onFetchSettings);
    on<UpdateSettingChanged>(_onUpdateSetting);
  }

  Future<void> _onFetchSettings(FetchSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      final settings = await remoteDataSource.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateSetting(UpdateSettingChanged event, Emitter<SettingsState> emit) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      // Optimistic update if needed, but here we'll just show 'Updating' state
      emit(SettingsLoaded(currentState.settings, isUpdating: true));
      try {
        await remoteDataSource.updateSetting(event.key, event.value);
        // Refetch to ensure consistency
        final newSettings = await remoteDataSource.getSettings();
        emit(SettingsLoaded(newSettings));
      } catch (e) {
        // Rollback or show error
        emit(SettingsError('Gagal memperbarui pengaturan: ${e.toString()}'));
        emit(SettingsLoaded(currentState.settings));
      }
    }
  }
}
