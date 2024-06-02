import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:teia/models/user_state.dart';
import 'package:teia/screens/group/controllers/group_controller.dart';
import 'package:teia/views/misc/header.dart';
import 'package:teia/views/teia_button.dart';

launchEditUserPopup(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return const AlertDialog(
        title: Text('Edit user'),
        content: EditUserPopup(),
        backgroundColor: Colors.white,
      );
    },
  );
}

class EditUserPopup extends GetView<GroupController> {
  const EditUserPopup({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(GroupController());
    return SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Header(
            text: 'Avatar',
            color: controller.avatarColor,
          ),
          const Gap(8),
          IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(
                  () => Material(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(100),
                      bottomLeft: Radius.circular(100),
                    ),
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(100),
                        bottomLeft: Radius.circular(100),
                      ),
                      onTap: controller.selectedAvatar.value == 0
                          ? null
                          : controller.previousAvatar,
                      child: Center(
                        child: Icon(
                          Icons.chevron_left,
                          size: 28,
                          color: controller.selectedAvatar.value == 0
                              ? Colors.transparent
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: SizedBox(
                      height: 200,
                      child: PageView(
                        controller: controller.pageController,
                        children: [
                          for (String avatar in controller.avatars)
                            Image.asset(
                              avatar,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => Material(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(100),
                      bottomRight: Radius.circular(100),
                    ),
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(100),
                        bottomRight: Radius.circular(100),
                      ),
                      onTap: controller.selectedAvatar.value ==
                              controller.avatars.length - 1
                          ? null
                          : controller.nextAvatar,
                      child: Center(
                        child: Icon(
                          Icons.chevron_right,
                          size: 28,
                          color: controller.selectedAvatar.value ==
                                  controller.avatars.length - 1
                              ? Colors.transparent
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          Header(text: 'Name', color: controller.nameColor),
          const Gap(8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(128),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: TextEditingController(text: controller.name),
                style: const TextStyle(
                  fontSize: 13,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  controller.name = value;
                },
              ),
            ),
          ),
          const Gap(16),
          Header(
            text: 'Role',
            color: controller.roleColor,
          ),
          const Gap(8),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (Role role in Role.values)
                  Material(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(128),
                      side: controller.role.value == role
                          ? BorderSide(
                              color: controller.roleColor,
                              width: 1,
                            )
                          : BorderSide.none,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(128),
                      onTap: () {
                        controller.role.value = role;
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Text(
                          role.toString().split('.').last,
                          style: TextStyle(
                            color: controller.role.value == role
                                ? Colors.black
                                : Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Gap(16),
          TeiaButton(
            text: 'Save',
            onTap: controller.save,
          ),
        ],
      ),
    );
  }
}
