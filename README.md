# Flash Quiz

A cross-platform Flutter quiz application.

## How to Compile and Run Flash Quiz

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (version 3.0.0 or higher recommended)
- Dart SDK (comes with Flutter)
- For mobile: Xcode (macOS) for iOS, Android Studio for Android
- For desktop: See [Flutter desktop support](https://docs.flutter.dev/desktop)

### 1. Upzip the folder "quiz_app"

### 2. Install Dependencies
open the unzipped folder quiz_app and then install the Dependencies
```sh
flutter pub get
```

### 3. Run the App

#### On Mobile (Android/iOS)
- **Android:**  
  Connect a device or start an emulator, then run:
  ```sh
  flutter run
  ```
- **iOS:**  
  Open Simulator (`open -a Simulator`), then run:
  ```sh
  flutter run
  ```

#### On Desktop (macOS/Windows/Linux)
- Make sure desktop support is enabled:
  ```sh
  flutter config --enable-macos-desktop
  flutter config --enable-windows-desktop
  flutter config --enable-linux-desktop
  ```
- Then run:
  ```sh
  flutter run -d macos    # for macOS
  flutter run -d windows  # for Windows
  flutter run -d linux    # for Linux
  ```

#### On Web
- Run:
  ```sh
  flutter run -d chrome
  ```

### 4. Build Release Versions
- **Android APK:**  
  ```sh
  flutter build apk
  ```
- **iOS:**  
  ```sh
  flutter build ios
  ```
- **Web:**  
  ```sh
  flutter build web
  ```

---

## Resources

- [Flutter documentation](https://docs.flutter.dev/)
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
