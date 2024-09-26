import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:zenith_coffee_shop/models/profile.dart';

class ProfilesProvider with ChangeNotifier {
  static final DatabaseReference _firebaseInstance =
      FirebaseDatabase.instance.ref();

  Profile? _currentProfile;

  Profile? get currentProfile => _currentProfile;

  static Future<void> create(Profile profile) async {
    try {
      Map<String, dynamic> data = {
        "userUuid": profile.userUuid,
        "username": profile.username,
        "fullname": profile.fullname,
        "phoneNumber": profile.phoneNumber
      };
      await _firebaseInstance.child("profiles").push().set(data);
    } catch (e) {
      debugPrint("Failed to create profile: $e");
    }
  }

  static Future<void> update(String key, Profile profile) async {
    try {
      Map<String, dynamic> data = {
        "userUuid": profile.userUuid,
        "username": profile.username,
        "fullname": profile.fullname,
        "phoneNumber": profile.phoneNumber
      };
      await _firebaseInstance.child("profiles").child(key).update(data);
    } catch (e) {
      debugPrint("Failed to update profile: $e");
    }
  }

  static Future<List<Profile>> getAllProfiles() async {
    try {
      DataSnapshot snapshot =
          (await _firebaseInstance.child("profiles").once()) as DataSnapshot;
      List<Profile> profiles = [];

      for (var child in snapshot.children) {
        Map<String, dynamic> data =
            Map<String, dynamic>.from(child.value as Map);
        Profile profile = Profile(
          email: data["email"],
          userUuid: data["userUuid"],
          username: data["username"],
          fullname: data["fullname"],
          phoneNumber: data["phoneNumber"],
          role: data["role"],
          password: '', // Do not store password here
        );
        profiles.add(profile);
      }
      return profiles;
    } catch (e) {
      debugPrint("Failed to get profiles: $e");
      return [];
    }
  }

  Future<void> fetchProfileByUid(String uid) async {
    try {
      DatabaseEvent event =
          await _firebaseInstance.child("profiles").child(uid).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        var profileData = snapshot.value as Map<dynamic, dynamic>;
        _currentProfile = Profile(
          email: profileData["email"] ?? "",
          userUuid: profileData["userUuid"] ?? "",
          username: profileData["username"] ?? "",
          fullname: profileData["fullname"] ?? "",
          phoneNumber: profileData["phone_number"] ?? "",
          role: profileData["role"] ?? "",
          password: "",
        );
      } else {
        _currentProfile = null;
        print("No profile found for uid: $uid");
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch profile: $e");
      _currentProfile = null;
      notifyListeners();
    }
  }
}
