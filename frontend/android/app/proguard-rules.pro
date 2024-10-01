# Don't obfuscate any classes under the Nativelib package,
# since Nativelib relies heavily on reflection, which won't work well
# when method names etc. are obfuscated.
# See: https://www.guardsquare.com/manual/configuration/usage#classspecification
-keep class com.example.nativelib.** { *; }

# Workaround for what seems like a bug in the kotlin.reflect library.
# We get a "Could not compute caller" exception when resolving a JVM method,
# if it returns void (i.e. kotlin.Unit) and if kotlin.Unit is obfuscated.
# Related issue: https://issuetracker.google.com/issues/196179629.
# It's worth noting that there is a "includedescriptorclasses" rule added for
# native methods (via the default ProGuard rules), which should have prevented
# kotlin.Unit from being mangled, but R8 does not seem to implement this rule
# for Kotlin. See:
# - https://www.guardsquare.com/manual/configuration/usage#keepoptionmodifiers
# - https://issuetracker.google.com/issues/208209210.
-keep class kotlin.Unit { *; }
