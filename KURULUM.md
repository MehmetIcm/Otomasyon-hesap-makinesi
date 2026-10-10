# Teknik Hesap Makinesi — Kurulum ve Yayın Kılavuzu

Bu pakette Flutter kaynak kodu (`lib/`), testler (`test/`), uygulama simgeleri (`android_res/`) ve Play mağaza malzemeleri (`store/`) bulunur. `android/` klasörünü Flutter üretir (aşağıda).

> Durum: Kod yazıldığı ortamda Flutter/Dart kurulu değildi. Bu yüzden `flutter analyze`, `flutter test` ve build **henüz çalıştırılmadı**. Aşağıdaki 4. adımda sizin bilgisayarınızda çalıştırın; çıkan hatayı bana yapıştırırsanız düzeltirim.

## 1. İskeleti oluşturun (VS Code terminali)
```
flutter doctor
flutter create --org com.technikalc --project-name pro --platforms android technikalc_pro
```
Bu, paket kimliğini `com.technikalc.pro` yapar.

## 2. Dosyaları kopyalayın
Zip'i açın (klasör adı `technikalc_kaynak`). Üst klasörde:

Windows PowerShell:
```
Copy-Item -Path .\technikalc_kaynak\* -Destination .\technikalc_pro -Recurse -Force
Copy-Item -Path .\technikalc_pro\android_res\* -Destination .\technikalc_pro\android\app\src\main\res\ -Recurse -Force
Remove-Item -Recurse -Force .\technikalc_pro\android_res
```
macOS/Linux:
```
cp -R technikalc_kaynak/. technikalc_pro/
cp -R technikalc_pro/android_res/. technikalc_pro/android/app/src/main/res/ && rm -rf technikalc_pro/android_res
```

## 3. Uygulama adı
`android/app/src/main/AndroidManifest.xml` içinde `android:label="pro"` değerini `android:label="Teknik Hesap Makinesi"` yapın.

## 4. Doğrulama
```
cd technikalc_pro
flutter pub get
flutter analyze
flutter test
flutter run
```
`flutter build apk --debug` ile debug paketi de üretebilirsiniz.

## 5. Hedef API (Play şartı)
Google Play'in resmî sayfasına göre yeni uygulamalar ve güncellemeler Android 16 (API 36) veya üstünü hedeflemelidir. `android/app/build.gradle(.kts)` içinde `targetSdk` değeri `flutter.targetSdkVersion` ise güncel Flutter'da bu değeri `flutter doctor`/derleme sonrası kontrol edin; 36'dan düşükse `targetSdk = 36` yazın (gerekirse `flutter upgrade`).

## 6. İmzalama (keystore'u siz oluşturursunuz)
```
keytool -genkey -v -keystore $env:USERPROFILE\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
(macOS/Linux: `~/upload-keystore.jks`). `keytool` bulunamazsa `flutter doctor -v` çıktısındaki Java yolunu kullanın. Parolayı ve dosyayı güvenle yedekleyin; Git'e eklemeyin.

`android/key.properties` oluşturun (Git'e eklemeyin; Flutter'ın `android/.gitignore` dosyasında olduğunu kontrol edin):
```
storePassword=PAROLANIZ
keyPassword=PAROLANIZ
keyAlias=upload
storeFile=C:/Users/KULLANICI/upload-keystore.jks
```
`android/app/build.gradle.kts` dosyasının en üstüne:
```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```
`android { ... }` içine:
```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = keystoreProperties["storeFile"]?.let { file(it) }
        storePassword = keystoreProperties["storePassword"] as String
    }
}
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```
(Eski Groovy `build.gradle` kullanıyorsanız Flutter'ın "Build and release an Android app" belgesindeki Groovy karşılığını uygulayın.)

## 7. İmzalı AAB
```
flutter build appbundle --release
```
Çıktı: `build/app/outputs/bundle/release/app-release.aab`

## 8. Play Console
1. Uygulama oluşturun (ad: Teknik Hesap Makinesi, dil: Türkçe).
2. Mağaza girişi: `store/store_listing_tr.md` metinleri, `store/play_icon_512.png`, `store/feature_graphic_1024x500.png`. **Telefon ekran görüntülerini** uygulamayı çalıştırıp siz alın (en az 2).
3. Gizlilik politikası: `store/privacy_policy_tr.md` içindeki alanları doldurup herkese açık bir URL'de yayınlayın.
4. Uygulama içeriği: reklam yok; Veri güvenliği: veri toplanmıyor/paylaşılmıyor (paylaşım yalnızca kullanıcı başlatır); içerik derecelendirmesi anketi; hedef kitle yetişkin/genel.
5. İlk yüklemede Play Uygulama İmzalama'yı kabul edin ve AAB'yi yükleyin.
6. **Kişisel geliştirici hesabınız 13 Kasım 2023'ten sonra açıldıysa:** üretime çıkmadan önce en az 12 test kullanıcısıyla, kesintisiz 14 gün kapalı test yapmanız gerekir. Kurumsal hesapta bu şart uygulanmaz. Güncel koşulları Play Console Yardım'dan doğrulayın.
7. Yayın öncesi: tüm hesaplamaları gerçek cihazda elle deneyin, uyarı metinlerini okuyun.

## Önemli not
Kablo kesiti/gerilim düşümü hesapları ön değerlendirmedir; uygulama kesin kesit veya koruma elemanı seçimi iddiasında bulunmaz.
