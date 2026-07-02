# Gson uses generic type information stored in a class file when working with
# fields. R8/ProGuard removes this information (the `Signature` attribute) by
# default, which breaks flutter_local_notifications: it uses a Gson
# `TypeToken<ArrayList<NotificationDetails>>() {}` to persist/restore
# scheduled notifications, and without the signature this throws
# "RuntimeException: Missing type parameter" at runtime, silently preventing
# notifications from being (re)scheduled in release builds.
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type

-keep class com.dexterous.flutterlocalnotifications.models.** { *; }

# The plugin ships no consumer ProGuard rules of its own and relies on Gson
# reflection (RuntimeTypeAdapterFactory, polymorphic StyleInformation
# subtypes) throughout its non-model classes too, so keep the whole plugin
# package unobfuscated/unshrunk rather than chasing individual reflection
# call sites.
-keep class com.dexterous.flutterlocalnotifications.** { *; }
