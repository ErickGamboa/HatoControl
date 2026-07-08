# Android release signing

This machine has no Android SDK/JDK installed (`flutter doctor` reports no
Android toolchain), so the keystore below has to be generated on a machine
that has Android Studio (or a standalone JDK) — do this once, then keep the
file safe.

## One-time: generate the upload keystore

```bash
keytool -genkey -v \
  -keystore android/app/upload-keystore.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

It'll prompt for a store password, a key password (can match the store
password), and your name/org/country — those don't need to be exact, they're
not shown to end users, just embedded in the certificate.

**Back up `upload-keystore.jks` and its passwords somewhere durable (password
manager, not just this disk) immediately.** With Play App Signing (the
default for new Play Console apps), Google holds the real app-signing key and
this is only your *upload* key — if you lose it, Google support can help you
reset it, but it's still a manual recovery process you want to avoid.

## One-time: create `android/key.properties`

Create `android/key.properties` (already gitignored, never commit it):

```properties
storeFile=app/upload-keystore.jks
storePassword=<the store password you chose>
keyAlias=upload
keyPassword=<the key password you chose>
```

Once this file exists, `android/app/build.gradle.kts` automatically signs
release builds with it instead of the debug keystore. With no
`key.properties`, release builds keep falling back to debug signing (so
`flutter run --release` still works locally with zero setup) — but a
debug-signed build will be rejected by Play Console.

## Building for Play Console

```bash
flutter build appbundle --release
```

Produces `build/app/outputs/bundle/release/app-release.aab`, signed with the
key above, ready to upload to Play Console.
