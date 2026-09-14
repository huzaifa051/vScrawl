class UserListItemModel {
  final String? id;
  final String? name;
  final String? userName;
  final String? emailAddress;
  final String? status;
  final bool? isOwner;
  final String? joinedOn;
  final String? userStatus;
  final int? roleId;
  final String? roleName;

  UserListItemModel({
    this.id,
    this.name,
    this.userName,
    this.emailAddress,
    this.status,
    this.isOwner,
    this.joinedOn,
    this.userStatus,
    this.roleId,
    this.roleName,
  });

  factory UserListItemModel.fromJson(Map<String, dynamic> json) {
    return UserListItemModel(
      id: json['id'],
      name: json['name'],
      userName: json['userName'],
      emailAddress: json['emailAddress'],
      status: json['status'],
      isOwner: json['isOwner'],
      joinedOn: json['joinedOn'],
      userStatus: json['userStatus'],
      roleId: json['roleId'],
      roleName: json['roleName'],
    );
  }
}

class UserListResponse {
  final List<UserListItemModel> users;
  final int totalElements;

  UserListResponse({required this.users, required this.totalElements});

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    final content = (json['content'] as List<dynamic>? ?? [])
        .map((e) => UserListItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return UserListResponse(
      users: content,
      totalElements: json['totalElements'] ?? content.length,
    );
  }
}
