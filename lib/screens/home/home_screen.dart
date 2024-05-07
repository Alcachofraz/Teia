import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:teia/screens/auth/controller/auth_controller.dart';
import 'package:teia/screens/home/controllers/home_controller.dart';
import 'package:teia/screens/home/popups/create_adventure/create_adventure.dart';
import 'package:teia/views/misc/rounded_button.dart';
import 'package:teia/views/misc/screen_wrapper.dart';
import 'package:teia/views/misc/tile.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return ScreenWrapper(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => Column(
                children: [
                  for (final group in controller.joinedGroups)
                    Tile(
                      color: Colors.grey.withOpacity(0.4),
                      elevation: 0,
                      onTap: () {
                        Get.toNamed('/group', parameters: {
                          'group': group.name,
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          group.name,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Gap(16),
            Tile(
              color: Colors.black,
              onTap: () {
                launchJoinAdventurePopup(context).then((_) {
                  controller.refreshJoinedGroups();
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Join New Adventure',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const Gap(16),
            RoundedButton(
              color: Colors.red,
              onTap: () {
                Get.put(AuthController()).logout();
              },
              text: 'Sign out',
            ),
          ],
        ),
      ),
    );
  }
}
