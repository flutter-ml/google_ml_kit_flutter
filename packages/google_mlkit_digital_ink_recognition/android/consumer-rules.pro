# Consumer R8/ProGuard rules for apps that depend on google_mlkit_digital_ink_recognition.
# Without them, release builds with R8 full mode (default since AGP 9) crash on launch.

# WorkManager (pulled in by ML Kit) and Room create the generated *_Impl databases
# by reflection, so their no-arg constructors must not be removed.
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.WorkDatabase_Impl { <init>(); }

# ML Kit ships a java.util.Random subclass that only allows setSeed() while an
# internal flag is set. R8 optimizes that flag away, so Random.<init> throws
# "Setting the seed on the shared Random object is not permitted".
-keep class com.google.android.gms.internal.mlkit_vision_digital_ink.** { *; }
-keep class com.google.mlkit.** { *; }
