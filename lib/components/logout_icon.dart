import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/shared_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoutComponent extends StatelessWidget {
  const LogoutComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(40),
      ),
      child: Stack(
        children: [
          IconButton(
            icon: ImageFiltered(
              imageFilter:
                  const ColorFilter.mode(Colors.black12, BlendMode.srcATop),
              child: SvgPicture.asset(
                "assets/images/logout.svg",
                width: 24,
                height: 24,
              ),
            ),
            onPressed: () {
              SharedService.logOut(context);
            },
          )
        ],
      ),
    );
  }
}
