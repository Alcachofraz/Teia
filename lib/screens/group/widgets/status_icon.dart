import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:teia/models/group.dart';
import 'package:teia/models/user_state.dart';

class StatusInfo {
  final String icon;
  final String tooltip;

  const StatusInfo(
    this.icon,
    this.tooltip,
  );
}

class StatusIcon extends StatelessWidget {
  const StatusIcon({
    super.key,
    required this.userState,
    required this.group,
  });

  final UserState userState;
  final Group group;

  StatusInfo getInfo() {
    switch (userState.role) {
      case Role.reader:
        switch (group.state) {
          case GroupState.idle:
            if (group.finalChapter) {
              return const StatusInfo('🏁', 'Adventure done!');
            } else {
              return StatusInfo(
                userState.ready ? '✅' : '⌛',
                userState.ready
                    ? 'I am ready!'
                    : 'Preparing for the adventure...',
              );
            }
          case GroupState.reading:
            return StatusInfo(
              userState.ready ? '✅' : '⌛',
              userState.ready
                  ? 'Already read the current chapter!'
                  : 'Still reading...',
            );
          case GroupState.writing:
            return const StatusInfo('✅', 'Waiting for the next chapter!');
        }
      case Role.writer:
        switch (group.state) {
          case GroupState.idle:
            if (group.finalChapter) {
              return const StatusInfo('🏁', 'Adventure done!');
            } else {
              return StatusInfo(
                userState.ready ? '✅' : '⌛',
                userState.ready
                    ? 'I am ready!'
                    : 'Preparing for the adventure...',
              );
            }
          case GroupState.reading:
            return const StatusInfo(
              '✅',
              'Already working on the next chapter!',
            );
          case GroupState.writing:
            return StatusInfo(
              userState.ready ? '✅' : '⌛',
              userState.ready
                  ? "Finished writing!"
                  : 'Still working on the next chapter...',
            );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    StatusInfo info = getInfo();
    return JustTheTooltip(
      content: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(info.tooltip),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Text(
          info.icon,
        ),
      ),
    );
  }
}
