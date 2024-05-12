import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teia/screens/auth/controller/auth_controller.dart';
import 'package:teia/screens/home/controllers/home_controller.dart';
import 'package:teia/screens/home/popups/create_adventure/create_adventure.dart';
import 'package:teia/screens/home/widgets/adventure_tile.dart';
import 'package:teia/views/misc/rounded_button.dart';
import 'package:teia/views/misc/screen_wrapper.dart';

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
            RoundedButton(
              color: Colors.red,
              onTap: () {
                Get.put(AuthController()).logout();
              },
              text: 'Sign out',
            ),
            Obx(
              () => Wrap(
                children: [
                  AdventureTile(
                    onTap: () {
                      launchJoinAdventurePopup(context).then((_) {
                        controller.refreshJoinedGroups();
                      });
                    },
                  ),
                  for (final group in controller.joinedGroups)
                    AdventureTile(
                      onTap: () {
                        Get.toNamed('/group', parameters: {
                          'group': group.name,
                        });
                      },
                      adventure: group,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
