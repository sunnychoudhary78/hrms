import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🔹 Immutable State
class GlobalLoadingState {
  final bool isLoading;
  final String message;

  const GlobalLoadingState({required this.isLoading, required this.message});

  const GlobalLoadingState.initial() : isLoading = false, message = '';
}

/// 🔹 Riverpod 3 Notifier
class GlobalLoadingNotifier extends Notifier<GlobalLoadingState> {
  @override
  GlobalLoadingState build() {
    return const GlobalLoadingState.initial();
  }

  void show([String message = "Please wait..."]) {
    state = GlobalLoadingState(isLoading: true, message: message);
  }

  void update(String message) {
    state = GlobalLoadingState(isLoading: true, message: message);
  }

  void hide() {
    state = const GlobalLoadingState.initial();
  }
}

/// 🔹 Modern Provider
final globalLoadingProvider =
    NotifierProvider<GlobalLoadingNotifier, GlobalLoadingState>(
      GlobalLoadingNotifier.new,
    );
