import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_bar.dart';
import 'package:flutter_application_1/components/back_icon.dart';
import 'package:flutter_application_1/notification.dart';
import 'package:flutter_application_1/pages/make_plan_page.dart';
import 'package:flutter_application_1/services/firestore/auths_store.dart';
import 'package:flutter_application_1/services/firestore/places_store.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:readmore/readmore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DetailsPage extends StatefulWidget {
  final String placeId;
  const DetailsPage({super.key, required this.placeId});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final PlaceStore placeStore = PlaceStore();
  final AuthStore authStore = AuthStore();
  bool isLoading = true;
  Map<String, dynamic>? placeData;
  String? selectedPhotoUrl;
  String? countryName;
  double averageRating = 0.0;
  int totalRatings = 0;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    fetchPlaceData();
    fetchAverageRating();
  }

  Future<void> fetchPlaceData() async {
    try {
      DocumentSnapshot doc = await placeStore.getPlaceById(widget.placeId);
      placeData = doc.data() as Map<String, dynamic>?;
      if (placeData != null) {
        debugPrint('Place data fetched: $placeData');
        if (placeData!['photos'] != null && placeData!['photos'].isNotEmpty) {
          await fetchImageUrl(placeData!['photos'][0]);
        }
        if (placeData!['address']['country_id'] != null) {
          DocumentReference countryRef = placeData!['address']['country_id'];
          await fetchCountryName(countryRef);
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching place data: $e');
    }
  }

  Future<void> fetchImageUrl(String imageName) async {
    try {
      String url = await FirebaseStorage.instance
          .ref()
          .child('images/$imageName')
          .getDownloadURL();
      setState(() {
        selectedPhotoUrl = url;
      });
    } catch (e) {
      setState(() {
        selectedPhotoUrl =
            'https://firebasestorage.googleapis.com/v0/b/travel-app-2f56c.appspot.com/o/images%2Fbai-bien-vung-tau1-min.png?alt=media&token=4533ed08-174e-403e-badb-8419107a6218';
      });
      debugPrint('Error fetching image URL: $e');
    }
  }

  Future<void> fetchCountryName(DocumentReference countryRef) async {
    try {
      debugPrint('Fetching country name for country reference: $countryRef');
      DocumentSnapshot countryDoc = await countryRef.get();
      if (countryDoc.exists) {
        setState(() {
          countryName = countryDoc['name'];
        });
        debugPrint('Country name fetched: $countryName');
      } else {
        setState(() {
          countryName = 'Unknown';
        });
        debugPrint(
            'Country document does not exist for country reference: $countryRef');
      }
    } catch (e) {
      setState(() {
        countryName = 'Unknown';
      });
      debugPrint('Error fetching country name: $e');
    }
  }

  Future<void> fetchAverageRating() async {
    try {
      QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
          .collection('ratings')
          .where('placeRef',
              isEqualTo:
                  FirebaseFirestore.instance.doc('places/${widget.placeId}'))
          .get();

      double totalRating = 0.0;
      for (var doc in ratingsSnapshot.docs) {
        totalRating += doc['rating'];
      }

      setState(() {
        averageRating =
            ratingsSnapshot.size > 0 ? totalRating / ratingsSnapshot.size : 0.0;
        totalRatings = ratingsSnapshot.size;
      });

      debugPrint(
          'Average rating fetched: $averageRating from $totalRatings ratings');
    } catch (e) {
      setState(() {
        averageRating = 0.0;
        totalRatings = 0;
      });
      debugPrint('Error fetching average rating: $e');
    }
  }

  Future<String> _getImageUrl(String imageName) async {
    if (imageName.isNotEmpty) {
      try {
        String url = await FirebaseStorage.instance
            .ref()
            .child('images/$imageName')
            .getDownloadURL();
        return url;
      } catch (e) {
        debugPrint('Error fetching image URL: $e');
        return 'https://firebasestorage.googleapis.com/v0/b/travel-app-2f56c.appspot.com/o/images%2Fbai-bien-vung-tau1-min.png?alt=media&token=4533ed08-174e-403e-badb-8419107a6218';
      }
    } else {
      return 'https://firebasestorage.googleapis.com/v0/b/travel-app-2f56c.appspot.com/o/images%2Fbai-bien-vung-tau1-min.png?alt=media&token=4533ed08-174e-403e-badb-8419107a6218';
    }
  }

  void _toggleBookmark() async {
    bool isBookmarked =
        await authStore.toggleBookmark(currentUserId, widget.placeId);
    String message = isBookmarked
        ? 'You have added ${placeData?['name'] ?? 'this place'} to your bookmark list'
        : 'You have removed ${placeData?['name'] ?? 'this place'} from your bookmark list';

    // Show a notification
    if (isBookmarked) {
      NotificationCustom.show(
        title: 'Bookmark Added',
        body: message,
      );
    } else {
      NotificationCustom.show(
        title: 'Bookmark Removed',
        body: message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const PageStorageKey<String>('detailPlace'),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                if (selectedPhotoUrl != null)
                  CachedNetworkImage(
                    imageUrl: selectedPhotoUrl!,
                    width: double.infinity,
                    height: 720,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                Column(
                  children: [
                    const CustomBar(
                      isTransparent: true,
                      leftWidget: BackIcon(),
                      centerWidget1: Text(
                        "Details",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      rightWidget: Text("               "),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                    ),
                  ],
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.3,
                  minChildSize: 0.3,
                  maxChildSize: 1,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(38),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          placeData?['name'] ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 25,
                                            color: Color(0xFF1B1E28),
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "${placeData?['address']['street'] ?? ''}, ${placeData?['address']['ward'] ?? ''}, ${placeData?['address']['district'] ?? ''}",
                                          style: const TextStyle(
                                            color: Color(0xFF7D848D),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StreamBuilder<List<DocumentReference>>(
                                    stream: authStore
                                        .getUserBookmarks(currentUserId),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      }
                                      List<DocumentReference> bookmarks =
                                          snapshot.data ?? [];
                                      bool isBookmarked = bookmarks.any(
                                          (bookmark) =>
                                              bookmark.id == widget.placeId);
                                      return ClipOval(
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.bookmark_add_outlined,
                                            color: isBookmarked
                                                ? Colors.yellow
                                                : Colors.black,
                                          ),
                                          onPressed: _toggleBookmark,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      ImageFiltered(
                                        imageFilter: const ColorFilter.mode(
                                            Color(0xFF7D848D),
                                            BlendMode.srcATop),
                                        child: SvgPicture.asset(
                                          "assets/images/Location.svg",
                                          width: 20,
                                          height: 20,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        countryName ?? 'Unknown',
                                        style: const TextStyle(
                                          color: Color(0xFF7D848D),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        averageRating.toStringAsFixed(1),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        '($totalRatings)',
                                        style: const TextStyle(
                                          color: Color(0xFF7D848D),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              if (placeData?['photos'] != null)
                                SizedBox(
                                  height: 80,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: placeData!['photos'].length,
                                    itemBuilder: (context, index) {
                                      return FutureBuilder<String>(
                                        future: _getImageUrl(
                                            placeData!['photos'][index]),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Container(
                                              width: 60,
                                              height: 60,
                                              margin: const EdgeInsets.only(
                                                  right: 10),
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            );
                                          } else if (snapshot.hasError ||
                                              !snapshot.hasData) {
                                            return Container(
                                              width: 60,
                                              height: 60,
                                              margin: const EdgeInsets.only(
                                                  right: 10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.grey,
                                              ),
                                              child: const Center(
                                                child: Icon(Icons.error),
                                              ),
                                            );
                                          } else {
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedPhotoUrl =
                                                      snapshot.data;
                                                });
                                              },
                                              child: Container(
                                                width: 60,
                                                height: 60,
                                                margin: const EdgeInsets.only(
                                                    right: 10),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                clipBehavior:
                                                    Clip.antiAliasWithSaveLayer,
                                                child: CachedNetworkImage(
                                                  imageUrl: snapshot.data!,
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              const SizedBox(
                                height: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'About Destination',
                                    style: TextStyle(
                                        fontSize: 22,
                                        color: Color(0xFF1B1E28),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ReadMoreText(
                                    placeData?['description'] ?? '',
                                    trimMode: TrimMode.Line,
                                    trimLines: 3,
                                    colorClickableText: Colors.deepOrangeAccent,
                                    trimCollapsedText: "Read More",
                                    trimExpandedText: "Show Less",
                                    style: const TextStyle(
                                        color: Color(0xFF7D848D), fontSize: 16),
                                  ),
                                  const SizedBox(
                                    height: 100,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MakePlanPage(
                                            placeId: widget.placeId,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.yellow[600],
                                    ),
                                    child: const SizedBox(
                                      width: double.infinity,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 16.0),
                                        child: Center(
                                          child: Text("Make plan"),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
