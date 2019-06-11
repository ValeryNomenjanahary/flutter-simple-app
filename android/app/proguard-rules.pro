#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-dontwarn io.flutter.plugin.**
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-dontwarn io.flutter.view.**
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

-dontwarn android.support.v4.**
-keep public class com.google.android.gms.* { public *; }
-dontwarn com.google.android.gms.**

