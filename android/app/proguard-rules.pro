# Keep ML Kit text recognition classes
-keep class com.google.mlkit.vision.text.** { *; }
-keepclassmembers class com.google.mlkit.vision.text.** { *; }

# Firebase and ML Kit rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.iid.FirebaseInstanceId
-dontwarn com.google.firebase.iid.**

# Keep ML Kit commons
-keep class com.google.mlkit.common.** { *; }
-keep class com.google.mlkit.linkfirebase.** { *; }

# Keep model info classes
-keep class com.google.mlkit.common.model.** { *; }
-keep class com.google.mlkit.common.sdkinternal.** { *; }

# Suppress warnings for obsolete Firebase IID
-dontnote com.google.firebase.iid.**

# Keep image labeling classes
-keep class com.google.mlkit.vision.label.** { *; }
-keepclassmembers class com.google.mlkit.vision.label.** { *; }

# Keep Google ML Kit internal classes
-keep class com.google.android.gms.internal.mlkit_** { *; }
-dontwarn com.google.android.gms.internal.mlkit_**
