import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🔥 All overlay states
enum GlobalOverlayState { idle, loading, success, error }

/// 🔥 Immutable State
class GlobalLoadingState {
  final GlobalOverlayState state;
  final String message;

  const GlobalLoadingState({required this.state, required this.message});

  const GlobalLoadingState.idle()
    : state = GlobalOverlayState.idle,
      message = '';

  bool get isLoading => state == GlobalOverlayState.loading;

  bool get isSuccess => state == GlobalOverlayState.success;

  bool get isError => state == GlobalOverlayState.error;

  bool get isVisible => state != GlobalOverlayState.idle;

  GlobalLoadingState copyWith({GlobalOverlayState? state, String? message}) {
    return GlobalLoadingState(
      state: state ?? this.state,
      message: message ?? this.message,
    );
  }
}

/// 🔥 Riverpod 3 Notifier
class GlobalLoadingNotifier extends Notifier<GlobalLoadingState> {
  Timer? _timer;

  @override
  GlobalLoadingState build() {
    return const GlobalLoadingState.idle();
  }

  /// SHOW LOADING
  void showLoading([String message = "Please wait..."]) {
    _timer?.cancel();

    state = GlobalLoadingState(
      state: GlobalOverlayState.loading,
      message: message,
    );
  }

  /// SHOW SUCCESS
  void showSuccess(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _timer?.cancel();

    state = GlobalLoadingState(
      state: GlobalOverlayState.success,
      message: message,
    );

    _timer = Timer(duration, hide);
  }

  /// SHOW ERROR
  void showError(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _timer?.cancel();

    state = GlobalLoadingState(
      state: GlobalOverlayState.error,
      message: message,
    );

    _timer = Timer(duration, hide);
  }

  /// UPDATE MESSAGE (only for loading)
  void update(String message) {
    if (state.state == GlobalOverlayState.loading) {
      state = state.copyWith(message: message);
    }
  }

  /// HIDE
  void hide() {
    _timer?.cancel();
    state = const GlobalLoadingState.idle();
  }
}

/// 🔥 Provider
final globalLoadingProvider =
    NotifierProvider<GlobalLoadingNotifier, GlobalLoadingState>(
      GlobalLoadingNotifier.new,
    );
