import 'package:flutter_riverpod/flutter_riverpod.dart';

final appRestartProvider = NotifierProvider<AppRestartNotifier, int>(
  AppRestartNotifier.new,
);

class AppRestartNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void restart() {
    state++;
  }
}
