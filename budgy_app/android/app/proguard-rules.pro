# Keep Google Error Prone annotations
-keep class com.google.errorprone.annotations.** { *; }

# Keep javax.annotation classes
-keep class javax.annotation.** { *; }

# Ignore compiler-only classes
-dontwarn javax.lang.model.**
