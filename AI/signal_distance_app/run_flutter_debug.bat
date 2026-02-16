@echo off
echo Starting Flutter Run... > flutter_debug.log
flutter devices >> flutter_debug.log 2>&1
flutter run >> flutter_debug.log 2>&1
