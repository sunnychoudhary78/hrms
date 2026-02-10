import '../../../../../core/network/api_service.dart';
import '../../../../../core/network/api_endpoints.dart';

class CompanySettingsApiService {
  final ApiService api;

  CompanySettingsApiService(this.api);

  Future<Map<String, dynamic>> fetchCompanySettings() async {
    return await api.get(ApiEndpoints.companySettings);
  }
}
