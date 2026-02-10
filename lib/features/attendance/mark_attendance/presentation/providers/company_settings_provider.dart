import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/company_settings_api_service.dart';
import '../../data/company_settings_repository.dart';
import '../../data/models/company_settings_model.dart';
import '../../../../../core/providers/network_providers.dart';

// ───────── API PROVIDER ─────────

final companySettingsApiProvider = Provider<CompanySettingsApiService>((ref) {
  final api = ref.read(apiServiceProvider);
  return CompanySettingsApiService(api);
});

// ───────── REPOSITORY PROVIDER ─────────

final companySettingsRepositoryProvider = Provider<CompanySettingsRepository>((
  ref,
) {
  final api = ref.read(companySettingsApiProvider);
  return CompanySettingsRepository(api);
});

// ───────── MAIN ASYNC NOTIFIER ─────────

final companySettingsProvider =
    AsyncNotifierProvider<CompanySettingsNotifier, CompanySettings>(
      CompanySettingsNotifier.new,
    );

class CompanySettingsNotifier extends AsyncNotifier<CompanySettings> {
  late CompanySettingsRepository _repo;

  @override
  Future<CompanySettings> build() async {
    _repo = ref.read(companySettingsRepositoryProvider);
    return _repo.fetchCompanySettings();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _repo.fetchCompanySettings());
  }
}
