import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teia/models/group.dart';
import 'package:teia/screens/home/popups/controller/edit_user_controller.dart';

launchEditUserPopup(BuildContext context, Group group) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit user'),
        content: EditUserPopup(group: group),
      );
    },
  );
}

class EditUserPopup extends GetView<EditUserController> {
  final Group group;
  const EditUserPopup({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    Get.put(EditUserController(group: group));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 200,
          child: PageView(children: [
            for (String avatar in controller.availableAvatars)
              Image.asset(
                avatar,
              ),
          ]),
        )
      ],
    );
  }
}
