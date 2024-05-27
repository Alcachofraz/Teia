import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:teia/models/group.dart';
import 'package:teia/models/user_state.dart';
import 'package:teia/services/art_service.dart';
import 'package:teia/services/authentication_service.dart';

class AdventureTile extends StatefulWidget {
  const AdventureTile({
    super.key,
    this.onTap,
    this.adventure,
  });

  final Group? adventure;
  final void Function()? onTap;

  @override
  State<AdventureTile> createState() => _AdventureTileState();
}

class _AdventureTileState extends State<AdventureTile> {
  late final Color color;

  @override
  void initState() {
    super.initState();
    color = ArtService.value.pastel();
  }

  String getRole(Group adventure) {
    return widget.adventure!.userState
            .containsKey(AuthenticationService.value.user?.uid)
        ? 'You are a ${widget.adventure!.userState[AuthenticationService.value.user?.uid]!.role == Role.writer ? 'Narrator' : 'Reader'}'
        : 'Choose your role now!';
  }

  String getStatus(Group adventure) {
    return 'Idle';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        /*side: adventure != null
            ? BorderSide.none
            : BorderSide(
                color: textColor,
                width: 2,
              ),*/
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 300,
          height: 200,
          child: widget.adventure != null
              ? SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(20),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Text(
                          widget.adventure!.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Gap(4),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Wrap(
                          children: [
                            const Icon(
                              Icons.psychology,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              getRole(widget.adventure!),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(4),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Wrap(
                          children: [
                            const Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              getStatus(widget.adventure!),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Wrap(
                          children: [
                            const Icon(
                              Icons.history_edu,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.adventure!.story != null
                                  ? widget.adventure!.story!.title
                                  : 'No story yet',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.group,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.adventure!.users.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(12),
                    ],
                  ),
                )
              : const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 56,
                      ),
                      Gap(8),
                      Text(
                        'Create a new adventure',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
