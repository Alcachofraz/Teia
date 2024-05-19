import 'package:flutter/material.dart';
import 'package:teia/models/user.dart';
import 'package:teia/models/user_state.dart';

class UserTileInfo {
  const UserTileInfo({
    required this.user,
    required this.isSelf,
    required this.color,
    required this.role,
    required this.ready,
    required this.avatar,
  });

  final User user;
  final bool isSelf;
  final Color color;
  final Role role;
  final bool ready;
  final int avatar;
}
