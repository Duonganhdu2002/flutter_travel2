import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BackIcon extends StatelessWidget {
  const BackIcon({super.key});

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
                "assets/images/direction_left.svg",
                width: 16,
                height: 16,
              ),
            ),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                // Trang hiện tại là trang gốc, không thực hiện pop
              }
            },
          )
        ],
      ),
    );
  }
}
