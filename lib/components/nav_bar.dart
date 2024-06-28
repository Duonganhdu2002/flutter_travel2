import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomBar extends StatelessWidget {
  final void Function(int)? onTabChange;
  final int selectedIndex;

  const CustomBottomBar(
      {super.key, required this.onTabChange, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 3,
                  blurRadius: 15,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SvgPicture.asset(
              'assets/images/nav_bottom.svg',
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildIconButton(
                icon: 'assets/images/home_icon.svg',
                label: 'Home',
                onPressed: () => onTabChange?.call(0),
                isSelected: selectedIndex == 0,
              ),
              buildIconButton(
                icon: 'assets/images/Calendar.svg',
                label: 'Plans',
                onPressed: () => onTabChange?.call(1),
                isSelected: selectedIndex == 1,
              ),
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD521),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/images/Search.svg',
                    width: 32,
                    height: 32,
                  ),
                  onPressed: () => onTabChange?.call(2),
                ),
              ),
              buildIconButton(
                icon: 'assets/images/Caht.svg',
                label: 'Messages',
                onPressed: () => onTabChange?.call(3),
                isSelected: selectedIndex == 3,
              ),
              buildIconButton(
                icon: 'assets/images/User.svg',
                label: 'Profile',
                onPressed: () => onTabChange?.call(4),
                isSelected: selectedIndex == 4,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Padding buildIconButton({
    required String icon,
    required String label,
    required VoidCallback onPressed,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          IconButton(
            icon: ImageFiltered(
              imageFilter: isSelected
                  ? const ColorFilter.mode(Colors.yellow, BlendMode.srcATop)
                  : const ColorFilter.mode(Colors.grey, BlendMode.srcATop),
              child: SvgPicture.asset(
                icon,
                width: 32,
                height: 32,
              ),
            ),
            onPressed: onPressed,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFFFFD521)
                  : const Color(0xFFBABABA),
            ),
          ),
        ],
      ),
    );
  }
}
