class Clan {
  final String clanName;
  final String clanOwnerId;
  final DateTime dateCreated;
  final List<String> membersIDs;
  final List<String> pendingMembersIDs;
  final String sportType;
  final String? description;
  final int skillRating;

  Clan({
    required this.clanName,
    required this.clanOwnerId,
    required this.dateCreated,
    required this.membersIDs,
    required this.pendingMembersIDs,
    required this.sportType,
    this.description,
    required this.skillRating
  });

  factory Clan.fromMap(Map<String, dynamic> map) {
    return Clan(
      clanName: map['clanName'] as String,
      clanOwnerId: map['clanOwnerId'] as String,
      dateCreated: DateTime.parse(map['dateCreated'] as String),
      membersIDs: List<String>.from(map['membersIDs'] ?? []), // Safe conversion
      pendingMembersIDs: List<String>.from(map['membersIDs'] ?? []), // Safe conversion
      sportType: map['sportType'] as String,
      description: map['description'] as String?,
      skillRating: map['skillRating'] as int ?? 0,

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clanName': clanName,
      'clanOwnerId': clanOwnerId,
      'dateCreated': dateCreated.toIso8601String(),
      'membersIDs': membersIDs,
      'pendingMembersIDs': pendingMembersIDs,
      'sportType': sportType,
      'description': description,
      'skillRating': skillRating
    };
  }
}
