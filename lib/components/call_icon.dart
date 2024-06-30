import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CallIcon extends StatelessWidget {
  const CallIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(40),
      ),
      child: IconButton(
        icon: ImageFiltered(
          imageFilter:
              const ColorFilter.mode(Colors.black12, BlendMode.srcATop),
          child: SvgPicture.asset(
            "assets/images/Callicon.svg",
            width: 24,
            height: 24,
          ),
        ),
        onPressed: () {
        },
      ),
    );
  }
}