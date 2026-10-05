name: Build AV Pro Studio APK
on: [push, workflow_dispatch]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Create Flutter App
        run: |
          flutter create --org com.av.studio av_app
          cd av_app
          flutter pub add video_player image_picker path_provider gal flutter_tts

      - name: Configure Android 16 Hardware Security
        run: |
          ACT=$(find av_app/android/app/src/main -name "MainActivity.*" | head -n 1)
          if [[ "$ACT" == *".kt" ]]; then
            cat << 'EOF' > "$ACT"
          package com.av.studio.av_app

          import android.os.Bundle
          import android.view.WindowManager
          import io.flutter.embedding.android.FlutterActivity

          class MainActivity: FlutterActivity() {
              override fun onCreate(savedInstanceState: Bundle?) {
                  super.onCreate(savedInstanceState)
                  window.setFlags(
                      WindowManager.LayoutParams.FLAG_SECURE,
                      WindowManager.LayoutParams.FLAG_SECURE
                  )
              }
          }
          EOF
          fi

      - name: Inject Studio Code
        run: |
          cp app_code.dart av_app/lib/main.dart

      - name: Build Release APK
        run: |
          cd av_app
          flutter build apk --release

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: AV-Pro-Studio-APK
          path: av_app/build/app/outputs/flutter-apk/app-release.apk
