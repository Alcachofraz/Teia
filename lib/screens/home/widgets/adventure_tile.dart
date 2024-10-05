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
    this.group,
    this.text,
  });

  final String? text;
  final Group? group;
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
    return widget.group!.userState.containsKey(AuthenticationService.value.uid)
        ? 'You are a ${widget.group!.userState[AuthenticationService.value.uid]!.role == Role.writer ? 'Narrator' : 'Reader'}'
        : 'Choose your role now!';
  }

  String getStatus(Group adventure) {
    return adventure.state.name;
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
          child: widget.group != null
              ? SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(20),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Text(
                          widget.group!.name,
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
                              getRole(widget.group!),
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
                              getStatus(widget.group!),
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
                              widget.group!.story != null
                                  ? widget.group!.story!.name
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
                              widget.group!.users.length.toString(),
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
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 56,
                      ),
                      const Gap(8),
                      Text(
                        widget.text ?? 'Unnamed',
                        style: const TextStyle(
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
