# ─── Apple.NET ProGuard Rules ───
# Optimized for Flutter + Firebase

# ─── General Flutter Rules ───
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# ─── Firebase Rules ───
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep class * extends java.lang.annotation.Annotation { *; }

# ─── Firebase Database ───
-keep class com.google.firebase.database.** { *; }
-keepclassmembers class com.google.firebase.database.** { *; }

# ─── Firebase Auth ───
-keep class com.google.firebase.auth.** { *; }
-keepclassmembers class com.google.firebase.auth.** { *; }

# ─── Firebase Messaging ───
-keep class com.google.firebase.messaging.** { *; }
-keepclassmembers class com.google.firebase.messaging.** { *; }

# ─── Gson (used by Firebase) ───
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }

# ─── Image Picker ───
-keep class io.flutter.plugins.imagepicker.** { *; }

# ─── Connectivity Plus ───
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# ─── Permission Handler ───
-keep class com.baseflow.permissionhandler.** { *; }

# ─── Cached Network Image ───
-keep class com.bumptech.glide.** { *; }
-keepclassmembers class com.bumptech.glide.** { *; }

# ─── Preserve line numbers for crash logs ───
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ─── Remove verbose logging in release ───
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
}
