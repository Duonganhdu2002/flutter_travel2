import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/public_plan.dart';
import 'package:flutter_application_1/pages/details_page.dart';
import 'package:flutter_application_1/pages/popular_places.dart';
import 'package:flutter_application_1/services/firestore/places_store.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeComponent extends StatefulWidget {
  const HomeComponent({super.key});
  @override
  State<HomeComponent> createState() => _HomeComponentState();
}

class _HomeComponentState extends State<HomeComponent>
    with AutomaticKeepAliveClientMixin<HomeComponent> {
  final PlaceStore placeStore = PlaceStore();

  @override
  bool get wantKeepAlive => true;

  Future<void> _refreshData() async {
    setState(() {});
  }

  Future<String> _getImageUrl(String imageName) async {
    debugPrint(imageName);
    if (imageName.isNotEmpty) {
      try {
        String url = await FirebaseStorage.instance
            .ref()
            .child('images/$imageName')
            .getDownloadURL();
        debugPrint(url);

        return url;
      } catch (e) {
        debugPrint('Error getting image URL: $e');
        // Return a default image URL in case of an error
        return 'https://firebasestorage.googleapis.com/v0/b/travel-app-2f56c.appspot.com/o/images%2Fbai-bien-vung-tau1-min.png?alt=media&token=4533ed08-174e-403e-badb-8419107a6218';
      }
    } else {
      // Return default image URL if the name is empty
      return 'https://firebasestorage.googleapis.com/v0/b/travel-app-2f56c.appspot.com/o/images%2Fbai-bien-vung-tau1-min.png?alt=media&token=4533ed08-174e-403e-badb-8419107a6218';
    }
  }

  Widget _image(List<String> imageNames) {
    if (imageNames.isEmpty) {
      return SizedBox(
        width: double.infinity,
        height: 350,
        child: CachedNetworkImage(
          imageUrl:
              'https://firebasestorage.googleapis.com/v0/b/travel-app-2f56c.appspot.com/o/images%2Fbao-tang-vung-tau2-min.png?alt=media&token=8eef2a82-8829-4b6e-ab4a-e019a71378b1',
          width: double.infinity,
          height: 350,
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
            height: 350,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox(
            width: double.infinity,
            height: 350,
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
                height: 350,
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
    super.build(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: placeStore.streamTop10Places(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                key: const PageStorageKey<String>('homeListView'),
                children: [
                  const Text(
                    "Explore the ",
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        "Beautiful ",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Column(
                        children: [
                          const Text(
                            "world!",
                            style: TextStyle(
                              fontSize: 50,
                              color: Color(0xFFFF7029),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Image.asset(
                            'assets/images/text_under.png',
                            width: 120,
                            fit: BoxFit.contain,
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Best Destination",
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PopularPlacesPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "View all",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.amber,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 500,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final placeData = snapshot.data![index];
                        final documentId = placeData['documentId'];
                        final List<String> imageNames =
                            List<String>.from(placeData['photos']);
                        debugPrint(imageNames.toString());
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            width: 300,
                            margin: const EdgeInsets.only(right: 25.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 3,
                                  blurRadius: 5,
                                  offset: const Offset(4, 4),
                                ),
                              ],
                            ),
                            child: GestureDetector(
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
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Stack(
                                      children: [
                                        _image(imageNames),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            placeData['name'] ?? 'Unknown',
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                "assets/images/Location.svg",
                                                width: 22,
                                                height: 22,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  " ${placeData['address']['street'] ?? ''}, ${placeData['address']['district'] ?? ''}",
                                                  style: const TextStyle(
                                                    color: Color(0xFF7D848D),
                                                    fontSize: 17,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Public Plans",
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Add navigation to view all public plans
                        },
                        child: const Text(
                          "View all",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.amber,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const PublicPlansWidget(), // Thêm widget mới
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
