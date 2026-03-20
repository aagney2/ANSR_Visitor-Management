# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Dio / OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Brother Printer SDK
-keep class com.brother.** { *; }
-keep class com.brother.ptouch.** { *; }
-dontwarn com.brother.**

# Google ML Kit (mobile_scanner)
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Keep Gson / JSON serialization
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }

# Prevent stripping of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
