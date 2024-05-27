import 'package:teia/models/story.dart';
import 'package:teia/models/user_state.dart';
import 'package:teia/services/authentication_service.dart';

enum GroupState {
  idle,
  writing,
  reading,
  discussing,
}

class Group {
  final String name;
  final String password;
  final Story? story;
  final GroupState state;
  final List<String> users;
  final Map<String, UserState> userState;

  Group({
    required this.name,
    required this.password,
    required this.users,
    required this.state,
    required this.userState,
    this.story,
  });

  factory Group.init(String name, String password, String? uid) {
    return Group(
      name: name,
      password: password,
      story: null,
      state: GroupState.idle,
      userState: {
        if (uid != null)
          uid: UserState(
            role: Role.reader,
            ready: false,
            avatar: 0,
            name: AuthenticationService.value.user!.name,
            uid: uid,
            admin: true,
          ),
      },
      users: uid == null ? [] : [uid],
    );
  }

  factory Group.fromMap(Map<String, dynamic> map, Story? story) {
    return Group(
      name: map['name'],
      password: map['password'],
      story: story,
      state: GroupState.values[map['state']],
      userState: (map['userState'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, UserState.fromMap(value, key)),
      ),
      users: (map['users'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'password': password,
      'story': story,
      'state': state.index,
      'userState': userState.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'users': users,
    };
  }
}
