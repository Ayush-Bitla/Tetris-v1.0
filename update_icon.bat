@echo off
echo Updating Tetris icon...

if not exist assets\icons\tetris_icon.png (
  echo Error: The tetris_icon.png file is missing!
  echo Please save the T-shaped image as 'tetris_icon.png' in the 'assets\icons' folder.
  pause
  exit /b 1
)

echo Generating app icons...
call flutter pub get
call flutter pub run flutter_launcher_icons

echo Building APK with new icon...
call flutter build apk

echo Copying APK to project root...
copy build\app\outputs\flutter-apk\app-release.apk tetris_with_icon.apk

echo Done! Your Tetris app now has a T-shaped icon.
echo The APK is available as 'tetris_with_icon.apk'
pause 