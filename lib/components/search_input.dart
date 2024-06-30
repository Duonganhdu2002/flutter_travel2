import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchInput extends StatelessWidget {
  final String hintText;
  final Function(String) onSearch;

  const SearchInput({
    super.key,
    this.hintText = 'Search for chats & messages',
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          ImageFiltered(
            imageFilter: const ColorFilter.mode(
              Color(0xFF7D848D),
              BlendMode.srcATop,
            ),
            child: SvgPicture.asset(
              "assets/images/Search.svg",
              width: 28,
              height: 28,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF7D848D),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          ImageFiltered(
            imageFilter: const ColorFilter.mode(
              Color(0xFF7D848D),
              BlendMode.srcATop,
            ),
            child: SvgPicture.asset(
              "assets/images/RightArrow.svg",
              width: 28,
              height: 28,
            ),
          ),
        ],
      ),
    );
  }
}
