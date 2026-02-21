class MobileConfig {
  final bool allowMobileCheckin;
  final bool requireMobileGps;
  final bool requireMobileCheckinSelfie;
  final bool requireMobileCheckoutSelfie;

  const MobileConfig({
    required this.allowMobileCheckin,
    required this.requireMobileGps,
    required this.requireMobileCheckinSelfie,
    required this.requireMobileCheckoutSelfie,
  });

  factory MobileConfig.fromJson(Map<String, dynamic> json) {
    return MobileConfig(
      allowMobileCheckin: json["allow_mobile_checkin"] ?? true,
      requireMobileGps: json["require_mobile_gps"] ?? false,
      requireMobileCheckinSelfie:
          json["require_mobile_checkin_selfie"] ?? false,
      requireMobileCheckoutSelfie:
          json["require_mobile_checkout_selfie"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "allow_mobile_checkin": allowMobileCheckin,
      "require_mobile_gps": requireMobileGps,
      "require_mobile_checkin_selfie": requireMobileCheckinSelfie,
      "require_mobile_checkout_selfie": requireMobileCheckoutSelfie,
    };
  }
}
