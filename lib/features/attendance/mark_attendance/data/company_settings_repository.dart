import 'company_settings_api_service.dart';
import 'models/company_settings_model.dart';

class CompanySettingsRepository {
  final CompanySettingsApiService api;

  CompanySettingsRepository(this.api);

  Future<CompanySettings> fetchCompanySettings() async {
    final res = await api.fetchCompanySettings();
    return CompanySettings.fromJson(res);
  }
}
