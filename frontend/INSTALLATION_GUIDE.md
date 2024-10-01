# Installationsguide

Nedan följer en guide som hjälper dig att komma igång med utveckling av appen. Det finns fyra viktiga
komponenter som behöver installeras och konfigureras:

1. Installation av SDK för Flutter
2. Installation av SDK för Android och/eller iOS
3. Konfiguration av emulator och/eller fysisk enhet för Android och/eller iOS
4. Konfiguration av utvecklingsmiljö för Flutter och Android och/eller iOS

Notera att iOS-utveckling *enbart* stöds på macOS, medan Android-utveckling stöds på alla operativsystem.

## Installation av SDK för Flutter

1. Installera Flutter SDK genom att följa [guiden som finns på Flutters webbsida](https://docs.flutter.dev/get-started/install).
Notera *var* du installerar Flutter SDK (förslagsvis någonstans i din hemkatalog). **OBS!** Under 2024 års kandidatprojekt har appen
byggts med Flutter 3.19, som kan laddas ned från [SDK-arkivet](https://docs.flutter.dev/release/archive). Flutter 3.22 släpptes vid
kandidatprojektets slut och har därför inte hunnit testas utförligt. Alla versioner av Flutter högre än 3.19 kan innehålla ändringar
som påverkar appens funktionalitet och/eller utseende, detta får ses som ett framtida projekt att åtgärda, om det skulle inträffa.

2. Lägg till sökvägen `<Flutter SDK>/bin` i miljövariabeln `PATH`, om du inte redan gjorde det vid installationen.
**OBS!** Ersätt `<Flutter SDK>` med sökvägen till din installation av Flutter SDK, och notera att om du använder Windows ska
`\` användas istället för `/` i sökvägar, samt att variabeln `PATH` heter `Path` på Windows.

> **OBS!** Det rekommenderas inte att använda Snap för att installera Flutter SDK på Linux.
>
> Snap är en alternativ pakethanterare som numera installeras automatiskt på Ubuntu,
> vars syfte är att underlätta distribution och konfiguration av program (för utvecklaren).
> Tyvärr finns det många problem med Snap, både för program i allmänhet och specifikt för Flutter.
> [[1]](https://linuxmint-user-guide.readthedocs.io/en/latest/snap.html)
> [[2]](https://www.baeldung.com/linux/snap-remove-disable#introduction-to-the-problem)
> [[3]](https://github.com/flutter/flutter/issues/124011)
> [[4]](https://bugs.launchpad.net/ubuntu/+source/firefox/+bug/1971037)
> [[5]](https://www.omgubuntu.co.uk/2024/01/valve-dont-recommend-ubuntu-steam-snap)

## Installation av SDK för Android

Android SDK består av ett flertal komponenter som innehåller olika utvecklingsverktyg och bibliotek för Android.
För att kompilera och köra appen krävs ett urval av dessa SDK-komponenter. Dessa kan
[hämtas automatiskt](https://developer.android.com/studio/intro/update#download-with-gradle)
när appen kompileras, *men bara om du har accepterat alla SDK-licenser*.
Följ instruktionerna nedan för att installera alla nödvändiga SDK-komponenter:

1. Ladda ned [Android Studio](https://developer.android.com/studio) (valfritt, men rekommenderas) och genomför en standardinstallation.
Fördelen med att installera Android Studio är att du får tillgång till grafiska verktyg
och en integrerad utvecklingsmiljö för Android-utveckling. Men Android Studio krävs inte
för att kompilera eller köra appen, allt som behövs är några komponenter ur Android SDK.

2. Sätt värdet på miljövariabeln `JAVA_HOME` till sökvägen för din JDK-installation.
Om du har valt att installera Android Studio kan du kan använda den JDK-installation som finns i mappen `jbr` i din
installationsmapp för Android Studio. Annars måste du installera en JDK, version 17 eller högre
(förslagsvis [Eclipse Temurin](https://adoptium.net/temurin/releases/?package=jdk&version=17)).

3. Installera versionen `latest` av [Android SDK Command-Line Tools](https://developer.android.com/tools#tools-sdk). Det kan göras under fliken
"SDK Tools" i [Android Studios grafiska SDK Manager](https://developer.android.com/studio/intro/update#sdk-manager).
Om du har valt att *inte* installera Android Studio kan du *istället* ladda ned Android SDK Command-Line Tools
från samma webbsida som Android Studio, under rubriken "Command line tools only", och sedan köra kommandot
`sdkmanager --sdk_root=<Android SDK> cmdline-tools;latest` från `bin`-mappen i arkivet du laddade ned, vilket installerar
Android SDK Command-Line Tools i mappen `<Android SDK>` (välj själv en lämplig sökväg, förslagsvis i din hemkatalog).

4. Konfigurera de miljövariabler som krävs för att kunna använda kommandoradsverktygen i Android SDK.
Sätt värdet av variabeln `ANDROID_HOME` till `<Android SDK>` och lägg till sökvägen `<Android SDK>/cmdline-tools/latest/bin`
samt `<Android SDK>/platform-tools` i variabeln `PATH`. **OBS!** Ersätt `<Android SDK>` med sökvägen till din
installation av Android SDK (INTE till Android Studio), och notera att om du använder Windows ska
`\` användas istället för `/` i sökvägar, samt att variabeln `PATH` heter `Path` på Windows.
Om du installerade Android Studio kan du hitta sökvägen till Android SDK genom att öppna menyn
**Tools > SDK Manager** där du hittar fältet **Android SDK Location**.
Sökvägen till Android SDK är vanligen `%LocalAppData%\Android\Sdk` på Windows,
`$HOME/Library/Android/sdk` på macOS och `$HOME/Android/Sdk` på Linux.

5. Starta om ditt skal och andra program som behöver få tillgång till de nyligen satta miljövariablerna.

6. Acceptera alla licenser för Android SDK-komponenterna genom att köra kommandot `sdkmanager --licenses`
och sedan ange att du har läst och accepterar alla licenser. Efter detta kommer resterande komponenter ur Android SDK
att [laddas ned automatiskt](https://developer.android.com/studio/intro/update#download-with-gradle) när du kompilerar appen.

### Konfiguration av fysisk enhet för Android

Om du vill köra appen på en fysisk Android-enhet behöver du använda ADB.
Du kan läsa mer om detta i guiden ["Run apps on a hardware device"](https://developer.android.com/studio/run/device).

> **OBS!** Notera att Android Studio inte kan hitta din enhet om du är ansluten till Eduroam
> och försöker använda trådlös debugging via Wi-Fi, eftersom Eduroam inte stödjer mDNS.
> Använd en USB-kabel istället.
> 
> Notera även att Windows numera brukar hitta och installera USB-drivrutiner för ADB automatiskt
> när man ansluter en Android-enhet via USB-kabel, så du ska inte behöva installera OEM-drivrutiner.

### Konfiguration av emulator för Android

Om du vill köra appen via en emulator kan du göra det genom den förinstallerade
emulatorn som finns i Android Studio, eller genom att skapa en ny emulator.
Du kan läsa mer om detta i guiden ["Run apps on the Android Emulator"](https://developer.android.com/studio/run/emulator).

> **OBS!** Emulatorn är inte helt felfri och har vissa buggar som gör att den laggar och/eller
> kraschar på vissa datorer, t.ex. om du använder en integrerad Intel-GPU.
> Därför rekommenderas du att använda en fysisk Android-enhet för att köra appen.

## Installation av SDK för iOS

1. Installera Flutter-SDK:n, Xcode och CocoaPods [enligt Flutters dokumentation](https://docs.flutter.dev/get-started/install/macos/mobile-ios).

2. Logga in på Xcode med ditt Apple-ID. För att öppna Flutter-projektet, klicka på "open existing project" och öppna `Runner.xcodeproj` som finns i `frontend/ios`-mappen.

### Konfiguration av fysisk enhet för iOS

1. Följ guiden som finns i [Flutters dokumentation](https://docs.flutter.dev/get-started/install/macos/mobile-ios?tab=physical#configure-your-target-ios-device). **OBS!** Notera att du inte behöver ha ett Apple developer-konto, utan kan använda [ett "Personal Team" som är kopplat till ditt Apple-ID](https://developer.apple.com/support/compare-memberships). Detta kommer dock med vissa begränsningar (läs mer via Apples support-sida). 

2. Kör appen via `flutter run --release`. Notera `--release`-flaggan, Apple kräver att appen installeras i release mode om man vill kunna köra den utan att vara konstant ansluten med debuggern i Xcode.

3. Efter nerladdning av appen så behövs verifiering enligt Flutter-dokumentationen ovan. Ett vanligt problem som kan inträffa är att verifieringen inte går igenom och att inget händer, dvs appen verifieras inte och det står att mobiltelefonen måste ha samma nätverk som datorn. Testa att restarta din iPhone/iPad, stäng av bluetooth, cellular och stäng av eventuella iPhone-profiler ifall det är på. Stäng av tyst läge så att det enda som är på är WIFI, kör sedan om punkt 2. 

### Konfiguration av emulator för iOS

1. Öppna projektet i Xcode och starta sedan emulatorn genom att högerklicka på Xcode appen som visas i din dock. Klicka sedan på `Open Developer Tool` och sedan klicka på `Simulator`.

## Konfiguration av utvecklingsmiljö

För att underlätta utveckling av appen rekommenderas det att man använder
de utvecklingsverktyg och miljöer som erbjuds för Flutter, Android och iOS.
Den största delen av appens kod är plattformsoberoende, men det finns även en
[Android-del](./android/) och en [iOS-del](./ios/).

För att utveckla den plattformsoberoende delen av appen rekommenderas antingen Visual Studio Code med
[Flutter-tillägget](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter),
eller Android Studio med [Flutter-pluginet](https://plugins.jetbrains.com/plugin/9212-flutter).
För att utveckla Android-delen av appen används Android Studio, och för att utveckla
iOS-delen av appen används Xcode.
