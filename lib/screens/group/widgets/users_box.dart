import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:teia/screens/group/models/user_tile_info.dart';
import 'package:teia/services/art_service.dart';

class UsersBox extends StatelessWidget {
  const UsersBox({
    super.key,
    required this.info,
    required this.color,
  });

  final List<UserTileInfo> info;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: color,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            for (final UserTileInfo userInfo in info)
              Material(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: userInfo.color,
                  ),
                ),
                child: InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            ArtService.value.assetPath(
                              userInfo.avatar,
                            ),
                            height: 48,
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Text(userInfo.user.name),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
