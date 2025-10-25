// data/friends/model/friend_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

// part 'friend_model.g.dart';

@HiveType(typeId: 7)
class FriendModel {
  @HiveField(0)
  final String friendEmail;
  
  @HiveField(1)
  final String friendName;
  
  @HiveField(2)
  final DateTime addedAt;

  FriendModel({
    required this.friendEmail,
    required this.friendName,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'friendEmail': friendEmail,
      'friendName': friendName,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  factory FriendModel.fromMap(Map<String, dynamic> map) {
    return FriendModel(
      friendEmail: map['friendEmail'],
      friendName: map['friendName'],
      addedAt: (map['addedAt'] as Timestamp).toDate(),
    );
  }
}