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
      return AlertDialog(
        title: const Text('Edit user'),
        content: const EditUserPopup(),
        backgroundColor: Colors.grey[200],
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
                      child: Stack(
                        children: [
                          PageView(
                            controller: controller.pageController,
                            children: [
                              for (String avatar in controller.avatars)
                                Image.asset(
                                  avatar,
                                ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                                right: 8,
                              ),
                              child: Material(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  side: BorderSide(
                                    color: controller.avatarColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  child: Text(
                                    '${controller.selectedAvatar.value + 1} / ${controller.avatars.length}',
                                    style: TextStyle(
                                      color: controller.avatarColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
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
            () => Row(
              children: [
                for (Role role in Role.values)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: role == Role.values.first ? 4 : 0,
                        left: role == Role.values.last ? 4 : 0,
                      ),
                      child: Stack(
                        children: [
                          Material(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: controller.role.value == role
                                  ? BorderSide(
                                      color: controller.roleColor,
                                      width: 1,
                                    )
                                  : BorderSide.none,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Column(
                                children: [
                                  Image.asset(
                                    role.image,
                                    fit: BoxFit.fitWidth,
                                  ),
                                  const Gap(4),
                                  Text(
                                    role.toString().toUpperCase(),
                                    style: TextStyle(
                                      color: controller.roleColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.grey.withOpacity(
                                controller.role.value == role ? 0.0 : 0.2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  controller.role.value = role;
                                },
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                        ],
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
