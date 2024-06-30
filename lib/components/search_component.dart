import 'package:flutter/material.dart';

class SearchComponent extends StatefulWidget {
  const SearchComponent({super.key});

  @override
  State<SearchComponent> createState() => _SearchComponentState();
}

class _SearchComponentState extends State<SearchComponent> {
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search,
                                    size: 35, color: Colors.grey),
                                hintText: 'Search anything ',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF7D848D),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                suffixIcon: IntrinsicHeight(
                                  child: SizedBox(
                                    width: double.minPositive,
                                    child: Row(
                                      children: [
                                        const VerticalDivider(
                                          width: double.minPositive,
                                          thickness: 2,
                                          indent: 10,
                                          endIndent: 10,
                                          color: Colors.grey,
                                        ),
                                        IconButton(
                                            onPressed: () {},
                                            icon: const Icon(
                                                Icons.mic_none_outlined,
                                                size: 30,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                )),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
