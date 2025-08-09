name: Flutter Build (APK & AAB)

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Java 17 (for Android Gradle)
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: "17"

      - name: Install Flutter (3.22.2 stable)
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.2'
          channel: 'stable'

      - name: Cache pub
        uses: actions/cache@v4
        with:
          path: ~/.pub-cache
          key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-pub-

      - name: Cache Gradle
        uses: actions/cache@v4
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
          key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
          restore-keys: |
            ${{ runner.os }}-gradle-

      # ВАЖНО: регенерим платформенные папки под современный Gradle
      - name: Regenerate Android project (fix unsupported Gradle)
        run: flutter create . --platforms=android

      - name: Flutter pub get
        run: flutter pub get

      - name: Build APK (release)
        run: flutter build apk --release

      - name: Build AAB (release)
        run: flutter build appbundle --release

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
          if-no-files-found: error
          retention-days: 7

      - name: Upload AAB
        uses: actions/upload-artifact@v4
        with:
          name: app-release-aab
          path: build/app/outputs/bundle/release/app-release.aab
          if-no-files-found: error
          retention-days: 7
