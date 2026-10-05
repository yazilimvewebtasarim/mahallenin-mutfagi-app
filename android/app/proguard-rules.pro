# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep generic attributes
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# AndroidX
-keep class androidx.lifecycle.** { *; }
-keep class androidx.core.** { *; }
-keep class androidx.annotation.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Audioplayers
-keep class xyz.luan.audioplayers.** { *; }

# Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Prevent R8 from breaking serialization/reflection
-dontwarn java.lang.invoke.**
-dontwarn javax.annotation.**

# Play Store split install & deferred components suppress
-dontwarn com.google.android.play.core.**
