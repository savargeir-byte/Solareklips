import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1625281157866154/9237853813';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-1625281157866154/9237853813';
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Request user consent for GDPR/CCPA compliance
  /// Must be called BEFORE MobileAds.instance.initialize()
  static Future<void> requestConsent() async {
    final params = ConsentRequestParameters();
    
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        // Consent info updated successfully
        final status = await ConsentInformation.instance.getConsentStatus();
        print('🔐 Consent status: $status');
        
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          _loadConsentForm();
        }
      },
      (FormError error) {
        // Handle error
        print('❌ Consent error: ${error.errorCode} - ${error.message}');
      },
    );
  }

  static void _loadConsentForm() {
    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        final status = await ConsentInformation.instance.getConsentStatus();
        if (status == ConsentStatus.required) {
          consentForm.show((FormError? formError) {
            if (formError != null) {
              print('❌ Consent form error: ${formError.message}');
            }
            // Load another form if consent is still required
            _loadConsentForm();
          });
        }
      },
      (FormError formError) {
        print('❌ Failed to load consent form: ${formError.message}');
      },
    );
  }

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static BannerAd createBannerAd({
    required AdSize adSize,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
    required void Function(Ad) onAdLoaded,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('✅ Ad loaded successfully');
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ Ad failed to load: ${error.code} - ${error.message}');
          onAdFailedToLoad(ad, error);
        },
      ),
    );
  }
}
