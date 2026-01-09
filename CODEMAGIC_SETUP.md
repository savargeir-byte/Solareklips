# Codemagic Setup fyrir Solar Eclipse App

## Forsendur

### iOS Build

1. **Apple Developer Account** með App Store Connect aðgang
2. **Bundle ID**: `com.solareklips.eclipseapp`
3. **Code Signing Certificates** og **Provisioning Profiles**

### Android Build

1. **Google Play Developer Account**
2. **Keystore** skrá fyrir signing
3. **Service Account** JSON fyrir Google Play upload

## Uppsetning í Codemagic

### 1. Tengja Repository

1. Farðu á [codemagic.io](https://codemagic.io)
2. Skráðu þig inn með GitHub
3. Bættu við `Solareklips` repository

### 2. iOS Setup

#### App Store Connect Integration

1. Farðu í **Teams > Integrations > App Store Connect**
2. Smelltu á **Connect**
3. Fylgdu leiðbeiningunum til að tengja Apple account
4. Nafngreindu integration sem `codemagic`

#### Code Signing

1. Farðu í **Teams > Code signing identities**
2. Veldu **iOS** tab
3. Hlaðu upp:
   - Distribution Certificate (.p12)
   - Provisioning Profile (.mobileprovision)
4. Settu inn certificate password

#### Bundle ID

Gakktu úr skugga um að Bundle ID í Xcode sé `com.solareklips.eclipseapp`:

```bash
open ios/Runner.xcworkspace
```

Í Xcode:

- Veldu Runner project
- Veldu Runner target
- General tab → Bundle Identifier

### 3. Android Setup

#### Google Play Integration

1. Farðu í **Teams > Integrations > Google Play**
2. Hlaðu upp service account JSON
3. Nafngreindu integration

#### Keystore

1. Farðu í **Teams > Code signing identities**
2. Veldu **Android** tab
3. Hlaðu upp keystore skrá
4. Settu inn:
   - Keystore password
   - Key alias
   - Key password
5. Vistað sem `keystore_reference`

### 4. Environment Variables

Í `codemagic.yaml` eru eftirfarandi breytur:

**iOS:**

- `BUNDLE_ID`: com.solareklips.eclipseapp
- `APP_STORE_ID`: [Þitt App Store ID]

**Android:**

- `PACKAGE_NAME`: com.solareklips.eclipseapp
- `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS`: [Auto-set af Google Play integration]

### 5. Email Notifications

Breyttu `your-email@example.com` í `codemagic.yaml` í þitt email:

```yaml
publishing:
  email:
    recipients:
      - your-email@example.com
```

## Build Commands

### Manual Build í Codemagic UI

1. Veldu workflow: `ios-workflow` eða `android-workflow`
2. Smelltu **Start new build**

### Automatic Builds

Build keyrist sjálfkrafa við:

- Push til `main` branch
- Pull request

## Build Outputs

### iOS

- **IPA skrá**: `build/ios/ipa/*.ipa`
- **Hlaðið upp**: TestFlight (Beta Testing)
- **Status**: Draft í App Store Connect

### Android

- **APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **AAB**: `build/app/outputs/bundle/release/app-release.aab`
- **Hlaðið upp**: Internal Testing track á Google Play

## Troubleshooting

### iOS Build Fails

1. Athugaðu certificate og provisioning profile
2. Gakktu úr skugga um Bundle ID sé rétt
3. Athugaðu logs í Codemagic build details

### Android Build Fails

1. Athugaðu keystore credentials
2. Gakktu úr skugga um package name sé rétt
3. Athugaðu Java version (ætti að vera 17)

## Local Testing

### iOS (macOS only)

```bash
flutter build ios --release
```

### Android

```bash
flutter build apk --release
flutter build appbundle --release
```

## Version Management

Breyttu version í `codemagic.yaml`:

```yaml
--build-name=1.0.0
--build-number=$BUILD_NUMBER
```

Build number er sjálfvirkt incremented af Codemagic.

## Support

- [Codemagic Docs](https://docs.codemagic.io/flutter/)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Flutter Android Deployment](https://docs.flutter.dev/deployment/android)
