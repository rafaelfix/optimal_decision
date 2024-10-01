# NativeLib

Pluginet krävs för att C++-kod på båda plattformarna körs i nativmiljön, inte i Flutter. Det är därför uppdelat i iOS och Android. Detta innebär att det finns två olika `optQuestions.h` och båda måste uppdateras när ny funktionalitet läggs till.

Utöver detta krävs en form av brygga för båda plattformar. Den nuvarande bryggan exekverar C++-funktioner baserat på ett funktionsnamn och lista av parametrar som skickas från applikationen.

Om du behöver felsöka problem i C++-koden rekommenderas det att du använder Android Studio, eftersom det har
inbyggt stöd för debugging av C++ i Android-appar utan att du behöver konfigurera någonting särskilt.

## Användning

Funktioner anropas [asynkront](https://docs.flutter.dev/development/platform-integration/platform-channels) från Dart enligt följande:

    import 'package:nativelib/nativelib.dart';

    ...

    await Nativelib.call('FUNKTIONSNAMN', [arg1, arg2, ...]);

Typen som returneras är `dynamic` vilket innebär att typen bestäms beroende på vilken typ som returnas av C++-koden.

**OBS!** Tänk på att du kan stöta på concurrency-problem vid användandet av Nativelib, på grund av att funktionsanropen
är asynkrona. Använd `Nativelib.mutexPool.withResource` vid kritiska sektioner där det är viktigt att en operation
som består av flera C++-anrop får exekvera dessa anrop i rätt ordning utan att bli avbruten av andra asynkrona anrop
till C++-koden.

## iOS

Då Swift inte kan köra C++ direkt behövs en Objective-C brygga. Denna finns i `ios/Classes/nativelib.mm`, där `.mm` indikerar Objective-C file med C++ stöd. Mer information om hur Objective-C fungerar finns [här](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html#//apple_ref/doc/uid/TP40011210)

## Android

Klassen `NLib` har alla C++-funktioner deklarerade och hittar funktionerna baserat på namn. Själva implementationen sker i `anroid/src/main/cpp/nativelib.cpp` och är baserat på [Android NDK](https://developer.android.com/ndk).