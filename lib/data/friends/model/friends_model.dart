// data/friends/model/friend_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/core/storage/hive_type_id.dart';

@HiveType(typeId: HiveTypeIds.friend)
class FriendModel {
  @HiveField(0)
  final String friendEmail;

  @HiveField(1)
  final String friendName;

  @HiveField(2)
  final DateTime addedAt;

  @HiveField(3, defaultValue: '')
  final String friendUid;

  FriendModel({
    required this.friendEmail,
    required this.friendName,
    required this.addedAt,
    required this.friendUid,
  });

  Map<String, dynamic> toMap() {
    return {
      'friendEmail': friendEmail,
      'friendName': friendName,
      'addedAt': Timestamp.fromDate(addedAt),
      'friendUid': friendUid, // ✅ zapisuj do Firestore
    };
  }

  factory FriendModel.fromMap(Map<String, dynamic> map) {
    return FriendModel(
      friendEmail: map['friendEmail'] as String,
      friendName: map['friendName'] as String? ?? 'Użytkownik',
      addedAt: (map['addedAt'] as Timestamp).toDate(),
      // ✅ kompatybilność wstecz: jeśli brak w starszych dok., ustaw pusty string
      friendUid: (map['friendUid'] as String?) ?? '',
    );
  }
}