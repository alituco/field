class UserProfile {
  final String id;
  final String firstName;
  final String? lastName;
  final String phoneNumber;
  final String username;
  final DateTime dob;
  final String gender;
  final String? emailAddress;
  final String? favoriteSport;
  final String? biography;
  final String? profilePictureUrl;
  final String? profileBannerUrl;
  final List<String> clans;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.phoneNumber,
    required this.username,
    required this.dob,
    required this.gender,
    this.lastName,
    this.emailAddress,
    this.favoriteSport,
    this.biography,
    this.profilePictureUrl,
    this.profileBannerUrl,
    required this.clans,
  }) {
    // if (firstName.isEmpty) {
    //   throw ArgumentError("First name cannot be empty");
    // }
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String documentId) {
    return UserProfile(
      id: documentId,
      phoneNumber: map['phoneNumber'] as String? ?? 'Unknown',  // Safe cast with default value
      firstName: map['firstName'] as String? ?? 'No Name',  // Safe cast with default value
      username: map['username'] as String? ?? 'No Username',  // Safe cast with default value
      dob: map['dob'] != null ? DateTime.parse(map['dob'] as String) : DateTime.now(),  // Safe parse with default value
      gender: map['gender'] as String? ?? 'Unspecified',  // Safe cast with default value
      lastName: map['lastName'] as String?,  // Safe cast, nullable
      emailAddress: map['emailAddress'] as String?,  // Safe cast, nullable
      biography: map['biography'] as String?,  // Safe cast, nullable
      profilePictureUrl: map['profilePictureUrl'] as String?,  // Safe cast, nullable
      profileBannerUrl: map['profileBannerUrl'] as String?,  // Safe cast, nullable
      clans: List<String>.from(map['clans'] ?? []),  // Safe list conversion
      favoriteSport: map['favoriteSport'] as String?,  // Safe cast, nullable
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'username': username,
      'dob': dob.toIso8601String(),
      'gender': gender,
      'emailAddress': emailAddress,
      'favoriteSport': favoriteSport,
      'biography': biography,
      'profilePictureUrl': profilePictureUrl,
      'profileBannerUrl': profileBannerUrl,
      'clans': clans,
    };
  }

  UserProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? username,
    DateTime? dob,
    String? gender,
    String? favoriteSport,
    String? emailAddress,
    String? biography,
    String? profilePictureUrl,
    String? profileBannerUrl,
    List<String>? clans,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      favoriteSport: favoriteSport ?? this.favoriteSport,
      emailAddress: emailAddress ?? this.emailAddress,
      biography: biography ?? this.biography,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      profileBannerUrl: profileBannerUrl ?? this.profileBannerUrl,
      clans: clans ?? this.clans,
    );
  }
}
