import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_application_1/models/structure/plan_model.dart';
import 'package:flutter_application_1/models/structure/place_model.dart';
import 'package:flutter_application_1/pages/plan_detail.dart';
import 'package:flutter_application_1/services/firestore/plannings_store.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting

class PlanningComponent extends StatelessWidget {
  const PlanningComponent({super.key});

  Future<String> getPlaceImage(String imagePath) async {
    try {
      final Reference ref =
          FirebaseStorage.instance.ref().child('images/$imagePath');
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error fetching image URL: $e');
      return 'https://via.placeholder.com/150'; // Placeholder image URL in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<List<Plan>>(
          stream: PlanningStore().streamPlansByUserId(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading plans'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No plans found'));
            }

            final plans = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return FutureBuilder<DocumentSnapshot>(
                  future: plan.placeRef.get(),
                  builder: (context, placeSnapshot) {
                    if (placeSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (placeSnapshot.hasError) {
                      return const Center(child: Text('Error loading place'));
                    } else if (!placeSnapshot.hasData) {
                      return const Center(child: Text('Place not found'));
                    }

                    final place = Place.fromSnapshot(placeSnapshot.data!);
                    final amountPerPerson = plan.fund ~/ plan.desiredParticipants;
                    final startDate = DateFormat('dd/MM/yyyy').format(plan.dayStart.toDate());
                    final endDate = DateFormat('dd/MM/yyyy').format(plan.dayEnd.toDate());

                    return FutureBuilder<String>(
                      future: getPlaceImage(place.photos.first),
                      builder: (context, imageSnapshot) {
                        if (imageSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (imageSnapshot.hasError) {
                          return const Center(
                              child: Text('Error loading image'));
                        }

                        final imageUrl = imageSnapshot.data!;

                        return GestureDetector(
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
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.07),
                                  spreadRadius: 5,
                                  blurRadius: 9,
                                  offset: const Offset(-4, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                        width: double.infinity,
                                        height: 140,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    plan.name,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          size: 20),
                                      Text(
                                        place.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF7D848D),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 18),
                                      const SizedBox(width: 5),
                                      Text(
                                        "$startDate - $endDate",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF7D848D),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.attach_money, size: 18),
                                      Text(
                                        "${plan.fund}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF7D848D),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.people, size: 18),
                                      Text(
                                        "Participants: ${plan.participants.length}/${plan.desiredParticipants}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF7D848D),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.attach_money, size: 18),
                                      Text(
                                        "Amount per person: \$${amountPerPerson.toString()}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.green,
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
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
