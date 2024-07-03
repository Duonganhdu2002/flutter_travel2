import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/details_page.dart';
import 'package:flutter_application_1/services/firestore/places_store.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchComponent extends StatefulWidget {
  const SearchComponent({super.key});

  @override
  State<SearchComponent> createState() => _SearchComponentState();
}

class _SearchComponentState extends State<SearchComponent> {
  TextEditingController searchController = TextEditingController();
  final PlaceStore placeStore = PlaceStore();

  Future<String> _getImageUrl(String imageName) async {
    if (imageName.isNotEmpty) {
      try {
        String url = await FirebaseStorage.instance
            .ref()
            .child('images/$imageName')
            .getDownloadURL();
        return url;
      } catch (e) {
        return 'https://firebasestorage.googleapis.com/v0/b/travel-app-2f56c.appspot.com/o/images%2Fbai-bien-vung-tau1-min.png?alt=media&token=4533ed08-174e-403e-badb-8419107a6218';
      }
    } else {
      return 'https://firebasestorage.googleapis.com/v0/b/travel-app-2f56c.appspot.com/o/images%2Fbai-bien-vung-tau1-min.png?alt=media&token=4533ed08-174e-403e-badb-8419107a6218';
    }
  }

  Widget _image(List<String> imageNames) {
    if (imageNames.isEmpty) {
      return SizedBox(
        width: double.infinity,
        height: 150,
        child: CachedNetworkImage(
          imageUrl:
              'https://firebasestorage.googleapis.com/v0/b/travel-app-2f56c.appspot.com/o/images%2Fbao-tang-vung-tau2-min.png?alt=media&token=8eef2a82-8829-4b6e-ab4a-e019a71378b1',
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) =>
              const Center(child: Text('Error loading image')),
        ),
      );
    }

    return FutureBuilder<String>(
      future: _getImageUrl(imageNames[0]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: double.infinity,
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox(
            width: double.infinity,
            height: 150,
            child: Center(child: Text('Error loading image')),
          );
        } else {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: snapshot.data!,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Center(child: Text('Error loading image')),
              ),
            ),
          );
        }
      },
    );
  }

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
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search,
                                  size: 35, color: Colors.grey),
                              hintText: 'Search anything ',
                              hintStyle: TextStyle(
                                color: Color(0xFF7D848D),
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                            ),
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
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: placeStore.streamAllPlaces(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data available'));
                  } else {
                    final places = snapshot.data!..shuffle();
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: places.length,
                      itemBuilder: (context, index) {
                        final placeData = places[index];
                        final documentId = placeData['documentId'];
                        final List<String> imageNames =
                            List<String>.from(placeData['photos']);
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsPage(
                                  placeId: documentId,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                            child: Column(
                              children: [
                                _image(imageNames),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    placeData['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        "assets/images/Location.svg",
                                        width: 16,
                                        height: 16,
                                      ),
                                      Expanded(
                                        child: Text(
                                          " ${placeData['address']['street'] ?? ''}, ${placeData['address']['district'] ?? ''}",
                                          style: const TextStyle(
                                            color: Color(0xFF7D848D),
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
