import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teia/screens/auth/controller/auth_controller.dart';
import 'package:teia/screens/home/controllers/home_controller.dart';
import 'package:teia/screens/home/popups/join_adventure/join_adventure.dart';
import 'package:teia/screens/home/widgets/adventure_tile.dart';
import 'package:teia/views/misc/rounded_button.dart';
import 'package:teia/views/misc/screen_wrapper.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    final screenSize = MediaQuery.of(context).size;
    return ScreenWrapper(
      body: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 300,
                      ),
                      const Spacer(),
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
                Obx(
                  () => Wrap(
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 20,
                    runSpacing: 20,
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
                const Spacer(),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 16, 40, 0),
                child: screenSize.width < (screenSize.height)
                    ? Image.asset(
                        controller.backgroundLeft,
                        width: screenSize.width * 0.25,
                      )
                    : Row(
                        children: [
                          Image.asset(
                            controller.backgroundLeft,
                            width: screenSize.width * 0.25,
                          ),
                          const Spacer(),
                          Image.asset(
                            controller.backgroundRight,
                            width: screenSize.width * 0.25,
                          ),
                        ],
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
