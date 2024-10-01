import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nativelib/nativelib.dart';

import 'package:olle_app/functions/database_connection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// The storage key to use for saving/loading profiles.
///
/// Can be incremented to avoid conflicts between different versions of the
/// storage format. Migrations could be created by loading from the old key
/// and saving to the new key, but this is not needed during development.
const profileStorageKey = "profiles_v3";

/// A model that holds the profiles.
class ProfileModel extends ChangeNotifier {
  final GetStorage box = GetStorage();
  final Map<String, Profile> _profiles = {};
  Profile _selectedProfile =
      Profile(name: "none", identifier: "none", uploadedTaskCount: 0);

  ProfileModel() {
    _loadProfiles();
  }

  Map<String, Profile> get profiles => _profiles;
  Profile get selectedProfile => _selectedProfile;

  void setProfile({required Profile profile}) async {
    _selectedProfile = profile;

    final String documents = await _localPath;

    await Nativelib.call("setFiles", [documents, profile.identifier]);
    _getLevels();

    if (kDebugMode) {
      print("Using documents path: " + documents);
      print('[profile] ${selectedProfile.toJson()}');
    }

    notifyListeners();
  }

  /// Adds a new profile to the model.
  ///
  /// Returns the newly created profile.
  Future<Profile> addProfile({
    required String name,
  }) async {
    String identifier;
    try {
      final userId = await createUser(name);
      identifier = UserIdHandler.generateOnline(userId);
    } catch (e) {
      if (kDebugMode) {
        print("Unable to create online user");
        print(e);
      }
      identifier = UserIdHandler.generateOffline();
    }

    final newProfile =
        Profile(name: name, identifier: identifier, uploadedTaskCount: 0);
    _profiles[identifier] = newProfile;
    saveProfiles();
    notifyListeners();
    return newProfile;
  }

  /// Clears current selected [Profile], [_selectedProfile]
  void clearProfile() {
    _selectedProfile =
        Profile(name: "none", identifier: "none", uploadedTaskCount: 0);
    notifyListeners();
  }

  /// Loads all [Profile] from the storage.
  void _loadProfiles() {
    _profiles.clear();
    final tempProfiles = box.read(profileStorageKey) ?? {};
    tempProfiles.forEach((identifier, json) {
      _loadProfile(Profile.fromJson(json));
    });

    notifyListeners();
  }

  /// Loads a single [profile], used by [_loadProfiles].
  void _loadProfile(Profile profile) {
    _profiles[profile.identifier] = profile;
  }

  /// Remove [Profile] from the model.
  /// [profile] must be a valid [Profile].
  Future<void> removeProfile({required Profile profile}) async {
    String path = await _localPath;

    String calcDigitPath = path + "/optCalcDigit" + profile.identifier + ".txt";
    File file = File(calcDigitPath);

    if (await file.exists() == true) {
      file.delete();
    }

    String gamingTimePath =
        path + "/optGamingTime" + profile.identifier + ".txt";
    file = File(gamingTimePath);

    if (await file.exists() == true) {
      file.delete();
    }

    _profiles.remove(profile.identifier);
    saveProfiles();
    notifyListeners();
  }

  /// This function will locally change the identifying value of a profile,
  /// this includes renaming all relevant files
  /// * [newIdentidifier] needs to have a prefix of online_
  Future<void> changeProfileIdentifier({required String newIdentifier}) async {
    final String oldIdentifier = _selectedProfile.identifier;
    final String path = await _localPath;

    if (kDebugMode) {
      print('[ChangeIdentifier] $oldIdentifier -> $newIdentifier');
    }

    String oldDigitPath = '$path/optCalcDigit$oldIdentifier.txt';
    String oldTimePath = '$path/optGamingTime$oldIdentifier.txt';

    String newDigitPath = '$path/optCalcDigit$newIdentifier.txt';
    String newTimePath = '$path/optGamingTime$newIdentifier.txt';

    File digitFile = File(oldDigitPath);
    File timeFile = File(oldTimePath);

    if (await digitFile.exists() && await timeFile.exists()) {
      if (kDebugMode) {
        print('[ChangeIdentifier] old: ${selectedProfile.toJson()}');
      }
      await digitFile.rename(newDigitPath);
      await timeFile.rename(newTimePath);

      _selectedProfile.identifier = newIdentifier;
      Profile temp = _profiles.remove(oldIdentifier)!;
      _profiles[newIdentifier] = temp;

      await Nativelib.call("setFiles", [path, newIdentifier]);

      if (kDebugMode) {
        print('[ChangeIdentifier] new: ${selectedProfile.toJson()}');
      }
    }

    saveProfiles();
    notifyListeners();
  }

  /// Tries to upload all sessions which have not yet been uploaded for the [selectedProfile]
  /// including any tasks and keypresses performed in that session.
  ///
  /// Should not throw any errors. If one or more sessions can't be uploaded,
  /// a new attempt will be made in the next call to [tryUploadSessions].
  Future<void> tryUploadSessions() async {
    try {
      await tryUpgradeProfile();

      // Tasks which have not yet been uploaded
      List<TaskSchema> tasksToUpload =
          await getTasks(fromTask: selectedProfile.uploadedTaskCount);
      await sendSessions(
        profile: selectedProfile,
        taskList: tasksToUpload,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Unable to upload sessions");
        print(selectedProfile.toJson());
        print(e);
      }
    } finally {
      // sendSessions may update uploadedTaskCount regardless of success or failure
      // (since it will try to upload multiple sessions), so we need to save that to disk.
      // If we don't save the profiles, we will forget that we have uploaded some tasks when the user closes the app.
      saveProfiles();
      _getLevels();
    }
  }

  /// This method will try to upgrade a profile to an online version if:
  /// * the profile is offline
  /// * the application can reach the database
  ///
  /// It checks if the user is and offline user then
  Future<void> tryUpgradeProfile() async {
    if (!selectedProfile.isOffline()) return;

    String userId = await createUser(selectedProfile.name);

    await changeProfileIdentifier(
        newIdentifier: UserIdHandler.generateOnline(userId));
  }

  /// Saves all currently known [Profile]'s to the storage.
  void saveProfiles() {
    box.write(profileStorageKey, _formatSaveData());
  }

  /// Formats the data in [_profiles] for saving purposes
  Map<String, String> _formatSaveData() {
    return _profiles
        .map((id, profile) => MapEntry(profile.identifier, profile.toJson()));
  }

  // Pulls the level down to update the selected profile
  Future<void> _getLevels() async {
    if (kDebugMode) {
      print("query Level");
    }
    for (String op in _selectedProfile.levels.keys) {
      _selectedProfile.levels[op] = await _getLevel(op);
    }
    notifyListeners();
  }

  /// queries the native library about the users level of [operator]
  Future<int> _getLevel(String operator) async {
    return await Nativelib.call("getLevel", [operator]);
  }

  void linkAccount(Profile profile, UserManagementAccount account) {
    profile.linkedAccount = account;
    saveProfiles();
    notifyListeners();
  }

  Future<void> changeTeacherEmail(Profile profile, String teacherEmail) async {
    await addTeacherEmail(userId: profile.userId, teacherEmail: teacherEmail);
    profile.teacherEmail = teacherEmail;
    saveProfiles();
    notifyListeners();
  }

  /// Gets the path to local documents, used for setting save file and removing saves
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }
}

/// [Profile] is a simple class containing useful information about a user.
///
/// * [name] for user name.
/// * [identifier] is a unique identifier for the profile with a prefix and an [userId].
/// * [levels] is a [Map]<[String],[int]> of the users level for the different algorithms.
/// * [uploadedTaskCount] is the number of tasks that have been uplodaded from the optCalcDigit file to the database.
/// * [teacherEmail] is an optional associated teacher email, not used by the app.
/// * [linkedAccount] is an optionally linked user management account, which can be used for profile synchronization.
///
/// To get the Id part of identifier to interact with the backend, use [userId]
class Profile {
  Profile({
    required this.name,
    required this.identifier,
    required this.uploadedTaskCount,
    this.teacherEmail,
    this.linkedAccount,
  });

  final String name;
  String identifier;
  Map<String, int> levels = {
    '+': 2,
    'p': 2,
    '-': 2,
    '*': 2,
    'm': 2,
    '/': 2
  }; // level 2 is default
  int uploadedTaskCount;
  String? teacherEmail;
  UserManagementAccount? linkedAccount;

  String get userId => UserIdHandler.getUserId(identifier);
  String get prefix => UserIdHandler.getPrefix(identifier);

  String toJson() {
    return jsonEncode({
      "name": name,
      "identifier": identifier,
      "uploadedTaskCount": uploadedTaskCount,
      "teacherEmail": teacherEmail,
      "linkedAccount": linkedAccount != null
          ? {
              "email": linkedAccount!.email,
              "accessCode": linkedAccount!.accessCode,
            }
          : null,
    });
  }

  factory Profile.fromJson(String json) {
    final data = jsonDecode(json);
    return Profile(
      name: data["name"],
      identifier: data["identifier"],
      uploadedTaskCount: data["uploadedTaskCount"],
      teacherEmail: data["teacherEmail"],
      linkedAccount: data["linkedAccount"] != null
          ? UserManagementAccount(
              email: data["linkedAccount"]["email"],
              accessCode: data["linkedAccount"]["accessCode"],
            )
          : null,
    );
  }

  bool isOffline() {
    return UserIdHandler.isOffline(identifier);
  }
}

/// A user management account can be used to synchronize user profiles.
class UserManagementAccount {
  const UserManagementAccount({
    required this.email,
    required this.accessCode,
  });

  /// The email address of the user management account.
  final String email;

  /// The access code received via email, which is used to verify the user.
  final int accessCode;
}

/// [UserIdHandler] is a simple class to handle everything to do with UUID's
///
/// The handler can:
/// * Generate offline identifiers
/// * Fetch userId part
/// * Determine what sort of identifier it is
class UserIdHandler {
  static String generateOffline() {
    const Uuid uuid = Uuid();
    return "offline_" + uuid.v4();
  }

  static String generateOnline(String userId) {
    return "online_" + userId;
  }

  static String getUserId(String identifier) {
    try {
      return identifier.split(RegExp(r"_")).last;
    } on StateError {
      throw ErrorDescription("Invalid userId");
    }
  }

  static String getPrefix(String identifier) {
    return identifier.split(RegExp(r"_")).first;
  }

  static bool isOffline(String identifier) {
    return identifier.startsWith("offline");
  }
}
