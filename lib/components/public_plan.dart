import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/structure/plan_model.dart';
import 'package:flutter_application_1/models/structure/place_model.dart';
import 'package:flutter_application_1/pages/plan_detail.dart';
import 'package:flutter_application_1/services/firestore/plannings_store.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PublicPlansWidget extends StatelessWidget {
  const PublicPlansWidget({Key? key}) : super(key: key);

  Future<String> _getImageUrl(String imageName) async {
    if (imageName.isNotEmpty) {
      try {
        return await FirebaseStorage.instance
            .ref()
            .child('images/$imageName')
            .getDownloadURL();
      } catch (e) {
        return 'https://via.placeholder.com/150';
      }
    } else {
      return 'https://via.placeholder.com/150';
    }
  }

  Future<Place> _getPlace(DocumentReference placeRef) async {
    DocumentSnapshot snapshot = await placeRef.get();
    return Place.fromSnapshot(snapshot);
  }

  Widget _image(List<dynamic> photos) {
    if (photos.isEmpty) {
      return SizedBox(
        width: double.infinity,
        height: 350,
        child: CachedNetworkImage(
          imageUrl: 'https://via.placeholder.com/150',
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
      future: _getImageUrl(photos.first),
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
    final PlanningStore planningStore = PlanningStore();

    return StreamBuilder<List<Plan>>(
      stream: planningStore.streamPublicPlans(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No public plans available'));
        } else {
          return SizedBox(
            height: 530,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final plan = snapshot.data![index];
                return FutureBuilder<Place>(
                  future: _getPlace(plan.placeRef),
                  builder: (context, placeSnapshot) {
                    if (placeSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (placeSnapshot.hasError) {
                      return const Center(child: Text('Error loading place'));
                    } else if (!placeSnapshot.hasData) {
                      return const Center(child: Text('Place not found'));
                    } else {
                      final place = placeSnapshot.data!;
                      int amountPerPerson =
                          plan.fund ~/ plan.desiredParticipants;
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
                                  builder: (context) => PlanDetailPage(
                                    plan: plan,
                                    place: place,
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
                                      _image(place.photos),
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
                                          place.name,
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
                                      Text(
                                        "\$${amountPerPerson.toString()} / person",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(
                                        "Participants: ${plan.participants.length}/${plan.desiredParticipants}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.blue,
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
                                                " ${place.address.street}, ${place.address.district}",
                                                style: const TextStyle(
                                                  color: Color(0xFF7D848D),
                                                  fontSize: 17,
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
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        }
      },
    );
  }
}
