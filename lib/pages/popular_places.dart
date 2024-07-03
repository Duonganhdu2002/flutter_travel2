import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/details_page.dart';
import 'package:flutter_application_1/services/firestore/places_store.dart';

class PopularPlacesPage extends StatefulWidget {
  const PopularPlacesPage({super.key});

  @override
  State<PopularPlacesPage> createState() => _PopularPlacesPageState();
}

class _PopularPlacesPageState extends State<PopularPlacesPage> {
  int currentPage = 1;
  final int pageSize = 10;
  bool isLoading = false;
  List<Map<String, dynamic>> popularPlaces = [];
  PlaceStore placeStore = PlaceStore(); // Khởi tạo PlaceStore

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  void _loadPlaces() async {
    setState(() {
      isLoading = true;
    });

    // Fetch paginated places
    placeStore.streamPagedPlaces(currentPage, pageSize).listen((pagedPlaces) {
      setState(() {
        popularPlaces.addAll(pagedPlaces);
        isLoading = false;
      });
    });
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
        return '';
      }
    } else {
      return '';
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
            height: 140,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox(
            width: double.infinity,
            height: 140,
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
                height: 140,
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
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            "Popular Places",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  popularPlaces.clear();
                  _loadPlaces();
                });
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 15,
              ),
              const Text(
                "All Popular Places",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: GridView.builder(
                  itemCount: popularPlaces.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 320,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemBuilder: (context, index) {
                    final place = popularPlaces[index];
                    final documentId = place['documentId'];
                    final List<String> imageNames =
                        List<String>.from(place['photos']);
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.07),
                              spreadRadius: 5,
                              blurRadius: 9,
                              offset: const Offset(-4, 8),
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  _image(imageNames),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                place['name'] ?? '',
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 20,
                                  ),
                                  Text(
                                    place['location'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF7D848D),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                    size: 18,
                                  ),
                                  const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                    size: 18,
                                  ),
                                  const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                    size: 18,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '${place['averageRating']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.cottage_outlined,
                                    size: 18,
                                  ),
                                  Text(
                                    place['type'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF7D848D),
                                      fontWeight: FontWeight.bold,
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
              ),
              if (popularPlaces.length < 10)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentPage++;
                      _loadPlaces();
                    });
                  },
                  child: const Text('Show more'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
