import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teia/models/group.dart';
import 'package:teia/models/user_state.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/utils/utils.dart';

class GroupStatusBox extends StatelessWidget {
  const GroupStatusBox({
    super.key,
    required this.group,
    this.color,
  });

  final Group group;
  final Color? color;

  Widget getGroupStatusText() {
    int currentChapter = group.state == GroupState.reading
        ? group.currentChapter - 1
        : group.currentChapter;

    if (group.state == GroupState.reading) {
      return group.userState[AuthenticationService.value.uid!]!.role ==
              Role.writer
          ? RichText(
              text: TextSpan(
                style: GoogleFonts.robotoMono(
                  color: Colors.black.withOpacity(0.9),
                  fontSize: 14,
                ),
                children: [
                  const TextSpan(
                      text: "✍🏼 There are still users who haven't read the "),
                  TextSpan(
                    text: "Chapter $currentChapter",
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ". But you can start working on "),
                  TextSpan(
                    text: "Chapter ${currentChapter + 1}",
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: "!"),
                ],
              ),
            )
          : (group.userState[AuthenticationService.value.uid!]!.ready
              ? RichText(
                  text: TextSpan(
                    style: GoogleFonts.robotoMono(
                      color: Colors.black.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(
                          text:
                              "✔️ You already read the most recent chapter ("),
                      TextSpan(
                        text: "Chapter $currentChapter",
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                          text:
                              "). Give the other users some time so that they can read it too."),
                    ],
                  ),
                )
              : RichText(
                  text: TextSpan(
                    style: GoogleFonts.robotoMono(
                      color: Colors.black.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(text: "📖 You have "),
                      TextSpan(
                        text: "Chapter $currentChapter",
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: " to read. Let's go!"),
                    ],
                  ),
                ));
    } else {
      return group.userState[AuthenticationService.value.uid!]!.role ==
              Role.reader
          ? RichText(
              text: TextSpan(
                style: GoogleFonts.robotoMono(
                  color: Colors.black.withOpacity(0.9),
                  fontSize: 14,
                ),
                children: [
                  const TextSpan(text: "⌛ "),
                  TextSpan(
                    text: "Chapter $currentChapter",
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: " is in the works! Sit tight."),
                ],
              ),
            )
          : (group.userState[AuthenticationService.value.uid!]!.ready
              ? RichText(
                  text: TextSpan(
                    style: GoogleFonts.robotoMono(
                      color: Colors.black.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(
                          text:
                              "⌛ Other writers are still working on some final adjustments for "),
                      TextSpan(
                        text: "Chapter $currentChapter",
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: "!"),
                    ],
                  ),
                )
              : RichText(
                  text: TextSpan(
                    style: GoogleFonts.robotoMono(
                      color: Colors.black.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(text: "✍🏼 The readers are waiting for "),
                      TextSpan(
                        text: "Chapter $currentChapter",
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ". Let's not procrastinate!"),
                    ],
                  ),
                ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "What's happening?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Gap(4),
        Material(
          color: Utils.pageEditorSheetColor,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: getGroupStatusText(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
