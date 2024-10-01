import 'package:flutter_test/flutter_test.dart';
import 'package:olle_app/functions/profiles.dart';

void main() {
  test("Profile toJson/fromJson roundtrip", () {
    // Given an example Profile
    final profile = Profile(
      name: "TestProfile",
      identifier: "7fc1615a-0e42-44ad-bb68-28d8e07b13db",
      uploadedTaskCount: 29,
      teacherEmail: "teacher@example.org",
      linkedAccount: const UserManagementAccount(
        email: "parent@example.org",
        accessCode: 123456,
      ),
    );
    // When we roundtrip it
    final profileJson = profile.toJson();
    final roundtrippedProfile = Profile.fromJson(profileJson);
    final roundtrippedProfileJson = roundtrippedProfile.toJson();
    // Then it should contain the same information
    expect(roundtrippedProfile.identifier, equals(profile.identifier));
    expect(roundtrippedProfileJson, equals(profileJson));
  });
}
