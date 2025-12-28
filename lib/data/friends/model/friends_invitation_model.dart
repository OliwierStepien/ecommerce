// data/friends/model/friend_invitation_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/core/storage/hive_type_id.dart';

@HiveType(typeId: HiveTypeIds.friendInvitation)
class FriendInvitationModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String fromUserEmail;
  
  @HiveField(2)
  final String fromUserName;
  
  @HiveField(3)
  final String toUserEmail;
  
  @HiveField(4)
  final DateTime sentAt;
  
  @HiveField(5)
  final FriendInvitationStatus status;

  FriendInvitationModel({
    required this.id,
    required this.fromUserEmail,
    required this.fromUserName,
    required this.toUserEmail,
    required this.sentAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUserEmail': fromUserEmail,
      'fromUserName': fromUserName,
      'toUserEmail': toUserEmail,
      'sentAt': Timestamp.fromDate(sentAt),
      'status': status.toString().split('.').last,
    };
  }

  factory FriendInvitationModel.fromMap(Map<String, dynamic> map) {
    return FriendInvitationModel(
      id: map['id'],
      fromUserEmail: map['fromUserEmail'],
      fromUserName: map['fromUserName'],
      toUserEmail: map['toUserEmail'],
      sentAt: (map['sentAt'] as Timestamp).toDate(),
      status: FriendInvitationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => FriendInvitationStatus.pending,
      ),
    );
  }

  FriendInvitationModel copyWith({
    FriendInvitationStatus? status,
  }) {
    return FriendInvitationModel(
      id: id,
      fromUserEmail: fromUserEmail,
      fromUserName: fromUserName,
      toUserEmail: toUserEmail,
      sentAt: sentAt,
      status: status ?? this.status,
    );
  }
}

@HiveType(typeId: HiveTypeIds.friendInvitationStatus)
enum FriendInvitationStatus {
  @HiveField(0)
  pending,
  
  @HiveField(1)
  accepted,
  
  @HiveField(2)
  rejected
}