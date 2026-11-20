-keep class net.sqlcipher.** { *; }

# Drift (SQLite database ORM)
-keep class * extends androidx.sqlite.** { *; }
-keep class com.github.drydart.flutter_sqlcipher.** { *; }

# Sherpa-ONNX (transcription engine)
-keep class com.k2fsa.sherpa.onnx.** { *; }

# Flutter Record plugin
-keep class com.llfbandit.record.** { *; }

# Just Audio plugin
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# Video Player plugin
-keep class io.flutter.plugins.videoplayer.** { *; }

# Flutter embedding and reflection
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Foreground service (flutter_foreground_task)
-keep class com.pravera.flutter_foreground_task.** { *; }

# Native libraries
-keepclasseswithmembernames class * {
    native <methods>;
}

# Google Play Core (not used, suppress warnings)
-dontwarn com.google.android.play.core.**
