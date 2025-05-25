# Preserve Flutter core classes
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.view.** { *; }

# Preserve SharedPreferences classes
-keep class androidx.preference.** { *; }
-keep class android.content.SharedPreferences { *; }

# Preserve HTTP client classes
-keep class org.apache.http.** { *; }
-keep class com.google.gson.** { *; }
-dontwarn okio.**

# Preserve Stripe classes
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**

# Preserve Image Picker classes
-keep class com.image_picker.** { *; }
-keep class io.flutter.plugins.imagepicker.** { *; }
-dontwarn com.image_picker.**

# Preserve Cookie Jar classes
-keep class com.example.chessearn_new.services.cookie_jar.** { *; } # Adjust package if different
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

# Preserve Permission Handler classes
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# Preserve Chess-related classes (flutter_chess_board and chess)
-keep class com.example.chessearn_new.chess.** { *; } # Adjust package if different
-keep class com.github.bhlangonijr.chesslib.** { *; } # For the 'chess' package
-dontwarn com.github.bhlangonijr.chesslib.**

# Prevent obfuscation of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep generic signatures (for reflection or serialization)
-keepattributes Signature
-keepattributes *Annotation*

# Ignore warnings for unused classes (optional, use cautiously)
-dontwarn