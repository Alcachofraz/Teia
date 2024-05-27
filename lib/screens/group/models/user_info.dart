import 'package:flutter/material.dart';
import 'package:teia/models/user_state.dart';

class UserInfo {
  const UserInfo({
    required this.isSelf,
    required this.color,
    required this.state,
  });

  final bool isSelf;
  final Color color;
  final UserState state;
}
