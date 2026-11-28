# Flutter ve eklentiler icin ProGuard kurallari.
#
# Flutter Gradle eklentisi kendi kurallarini zaten ekliyor; burasi yalnizca
# bu projeye ozgu olanlar icin.

# Flutter motorunun yansima ile cagirdigi siniflar.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Hata ayiklama yiginlarinin okunabilir kalmasi icin satir numaralarini koru.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
