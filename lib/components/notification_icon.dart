import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationIcon extends StatelessWidget {
  final bool notificationExistence;
  final VoidCallback? onTap;
  const NotificationIcon(
      {super.key, required this.notificationExistence, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F9),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ImageFiltered(
                  imageFilter:
                      const ColorFilter.mode(Colors.black87, BlendMode.srcATop),
                  child: SvgPicture.asset(
                    "assets/images/bell.svg",
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
              Positioned(
                right: 7,
                top: 0,
                child: Container(
                  padding: notificationExistence
                      ? const EdgeInsets.all(4.0)
                      : const EdgeInsets.all(0.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: const Text(
                    '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
