import 'dart:math';

import 'package:teia/models/story.dart';
import 'package:teia/models/user_state.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/utils/utils.dart';

enum GroupState {
  idle,
  writing,
  reading;

  String get name {
    switch (this) {
      case GroupState.idle:
        return 'Idle';
      case GroupState.writing:
        return 'Writing';
      case GroupState.reading:
        return 'Reading';
    }
  }
}

class Group {
  final String name;
  final String password;
  final Story? story;
  final GroupState state;
  final List<String> users;
  final int currentChapter;
  final Map<String, UserState> userState;
  final bool finalChapter;

  Group({
    required this.name,
    required this.password,
    required this.users,
    required this.state,
    required this.currentChapter,
    required this.userState,
    required this.finalChapter,
    this.story,
  });

  factory Group.init(String name, String password, String? uid) {
    return Group(
      name: name,
      password: password,
      story: null,
      state: GroupState.idle,
      currentChapter: 1,
      userState: {
        if (uid != null)
          uid: UserState(
            role: Role.reader,
            ready: false,
            avatar: 0,
            name: Utils.getUsernameFromEmail(
              AuthenticationService.value.user.email!,
            ),
            uid: uid,
            admin: true,
            currentPage: 1,
          ),
      },
      users: uid == null ? [] : [uid],
      finalChapter: false,
    );
  }

  factory Group.fromMap(Map<String, dynamic> map, Story? story) {
    return Group(
      name: map['name'],
      password: map['password'],
      story: story,
      state: GroupState.values[map['state']],
      currentChapter: map['currentChapter'],
      userState: (map['userState'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, UserState.fromMap(value, key)),
      ),
      users: (map['users'] as List).cast<String>(),
      finalChapter: map['finalChapter'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'password': password,
      'story': story,
      'state': state.index,
      'currentChapter': currentChapter,
      'userState': userState.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'users': users,
      'finalChapter': finalChapter,
    };
  }
}
