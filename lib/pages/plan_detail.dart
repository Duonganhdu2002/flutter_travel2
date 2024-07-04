import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_bar.dart';
import 'package:flutter_application_1/components/back_icon.dart';
import 'package:flutter_application_1/models/structure/plan_model.dart';
import 'package:flutter_application_1/models/structure/place_model.dart';
import 'package:flutter_application_1/pages/chat_page.dart';
import 'package:flutter_application_1/pages/user_detail_page.dart';
import 'package:flutter_application_1/payment.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanDetailPage extends StatefulWidget {
  final Plan plan;
  final Place place;

  const PlanDetailPage({super.key, required this.plan, required this.place});

  @override
  _PlanDetailPageState createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends State<PlanDetailPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, String>> friends = [];
  List<Map<String, String>> filteredFriends = [];
  List<String> selectedFriends = [];

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  Future<void> initPaymentSheet() async {
    try {
      int amountPerPerson = widget.plan.fund ~/ widget.plan.desiredParticipants;
      int amountInCents = amountPerPerson * 100; // Convert to cents

      final data = await createPaymentIntent(
        name: "Test User",
        address: "Test Address",
        pin: "12345",
        city: "Test City",
        state: "Test State",
        country: "US",
        currency: "USD",
        amount: amountInCents.toString(),
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: data['client_secret'],
          merchantDisplayName: "Payment gateway",
          style: ThemeMode.dark,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // If the payment is successful, update Firestore
      await _addCurrentUserToParticipants();

      // Add user to conversation participants
      await _addCurrentUserToConversationParticipants();

      // Navigate to group chat page
      _navigateToGroupChat();
    } catch (e) {
      debugPrint('Error initializing payment sheet: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _addCurrentUserToParticipants() async {
    try {
      List<DocumentReference> updatedParticipants =
          List<DocumentReference>.from(
              widget.plan.participants.map((p) => p as DocumentReference));
      DocumentReference currentUserRef =
          FirebaseFirestore.instance.collection('auths').doc(currentUserId);

      updatedParticipants.add(currentUserRef);

      Map<DocumentReference, int> contributions = widget.plan.contributions;

      contributions[currentUserRef] = 1;

      Map<String, int> contributionsForFirestore =
          contributions.map((key, value) => MapEntry(key.path, value));

      await FirebaseFirestore.instance
          .collection('plannings')
          .doc(widget.plan.id)
          .update({
        'participants': updatedParticipants,
        'contributions': contributionsForFirestore,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have successfully joined the plan')),
      );

      setState(() {
        widget.plan.participants.add(currentUserRef);
      });
    } catch (e) {
      debugPrint('Error adding current user to participants: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _addCurrentUserToConversationParticipants() async {
    try {
      DocumentReference currentUserRef =
          FirebaseFirestore.instance.collection('auths').doc(currentUserId);

      await widget.plan.conversationRef.update({
        'participants': FieldValue.arrayUnion([currentUserRef.path]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have been added to the conversation')),
      );
    } catch (e) {
      debugPrint('Error adding current user to conversation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _navigateToGroupChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          userId: currentUserId,
          friendRefs: List<DocumentReference>.from(widget.plan.participants),
          groupName: widget.plan.name,
          conversationId: widget.plan.conversationRef,
        ),
      ),
    );
  }

  Future<void> _fetchFriends() async {
    try {
      final currentUserSnapshot = await FirebaseFirestore.instance
          .collection('auths')
          .doc(currentUserId)
          .get();
      final currentUserData =
          currentUserSnapshot.data() as Map<String, dynamic>;

      List<DocumentReference> friendRefs =
          List<DocumentReference>.from(currentUserData['list_friend'] ?? []);

      List<Map<String, String>> friendsList = [];
      for (DocumentReference friendRef in friendRefs) {
        final friendSnapshot = await friendRef.get();
        final friendData = friendSnapshot.data() as Map<String, dynamic>;

        String avatarPath = friendData['avatar'] ?? 'default_avatar.png';
        String avatarUrl = await _getAvatarUrl(avatarPath);

        if (!widget.plan.participants
            .any((participant) => participant.id == friendRef.id)) {
          friendsList.add({
            'userId': friendRef.id,
            'username': friendData['email'].split('@')[0],
            'avatar': avatarUrl
          });
        }
      }

      setState(() {
        friends = friendsList;
        filteredFriends = friendsList;
      });
    } catch (e) {
      debugPrint('Error fetching friends: $e');
    }
  }

  Future<String> _getAvatarUrl(String avatarPath) async {
    try {
      String url = await FirebaseStorage.instance
          .ref('avatars/$avatarPath')
          .getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Error fetching avatar: $e');
      return 'assets/images/placeholder_avatar.jpg';
    }
  }

  Future<void> _addParticipants() async {
    if (selectedFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one friend to add'),
        ),
      );
      return;
    }

    try {
      List<DocumentReference> updatedParticipants =
          List.from(widget.plan.participants);
      for (String friendId in selectedFriends) {
        updatedParticipants
            .add(FirebaseFirestore.instance.doc('auths/$friendId'));
      }

      await FirebaseFirestore.instance
          .collection('plannings')
          .doc(widget.plan.id)
          .update({'participants': updatedParticipants});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Participants added successfully')),
      );

      setState(() {
        widget.plan.participants.addAll(updatedParticipants);
      });

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding participants: $e')),
      );
      debugPrint('Error adding participants: $e');
    }
  }

  void _showAddParticipantsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Friends to Add'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search friends',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (query) {
                        setState(() {
                          filteredFriends = friends
                              .where((friend) => friend['username']!
                                  .toLowerCase()
                                  .contains(query.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredFriends.length,
                        itemBuilder: (context, index) {
                          final friend = filteredFriends[index];
                          final isSelected =
                              selectedFriends.contains(friend['userId']);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedFriends.remove(friend['userId']);
                                  } else {
                                    selectedFriends.add(friend['userId']!);
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(40),
                                    child: Image.network(
                                      friend['avatar']!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          friend['username']!,
                                          style: const TextStyle(
                                            color: Color(0xFF1B1E28),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : Colors.grey,
                                        width: 2,
                                      ),
                                      color: isSelected
                                          ? const Color(0xFFFFD521)
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 18,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: _addParticipants,
                ),
              ],
            );
          },
        );
      },
    );
  }

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

  Stream<String> _getParticipantAvatarStream(
      DocumentReference participantRef) async* {
    final participantSnapshot = await participantRef.snapshots().first;
    String avatarPath =
        participantSnapshot.get('avatar') ?? 'default_avatar.png';
    yield await _getAvatarUrl(avatarPath);
  }

  Stream<DocumentSnapshot> _getParticipantSnapshot(
      DocumentReference participantRef) {
    return participantRef.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    bool isMember = widget.plan.participants
        .any((participant) => participant.id == currentUserId);
    int amountPerPerson = widget.plan.fund ~/ widget.plan.desiredParticipants;

    return Scaffold(
      appBar: CustomBar(
        leftWidget: const BackIcon(),
        centerWidget1: Text(widget.plan.name),
        rightWidget: isMember
            ? (widget.plan.participants.length < widget.plan.desiredParticipants
                ? ElevatedButton(
                    onPressed: _showAddParticipantsDialog,
                    child: const Text("Add Participants"),
                  )
                : const Text("Plan is full."))
            : ElevatedButton(
                onPressed: () {
                  initPaymentSheet();
                },
                child: const Text("Join and Pay"),
              ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _image(widget.place.photos),
            const SizedBox(height: 10),
            Text(
              widget.place.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Amount per person: \$${amountPerPerson.toString()}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                Text(
                  "Participants: ${widget.plan.participants.length}/${widget.plan.desiredParticipants}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SvgPicture.asset(
                  "assets/images/Location.svg",
                  width: 22,
                  height: 22,
                ),
                Expanded(
                  child: Text(
                    " ${widget.place.address.street}, ${widget.place.address.district}",
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
            const SizedBox(height: 20),
            const Text(
              "Participants",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.plan.participants.length,
                itemBuilder: (context, index) {
                  final participantRef = widget.plan.participants[index];
                  return StreamBuilder<DocumentSnapshot>(
                    stream: _getParticipantSnapshot(participantRef),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error loading user'));
                      } else if (!snapshot.hasData) {
                        return const Center(child: Text('User not found'));
                      }

                      final participantData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final participantName =
                          participantData['email'].split('@')[0];

                      return StreamBuilder<String>(
                        stream: _getParticipantAvatarStream(participantRef),
                        builder: (context, avatarSnapshot) {
                          if (avatarSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (avatarSnapshot.hasError) {
                            return const Center(
                                child: Text('Error loading avatar'));
                          } else if (!avatarSnapshot.hasData) {
                            return const Center(
                                child: Text('Avatar not found'));
                          }

                          final participantAvatar = avatarSnapshot.data!;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(participantAvatar),
                            ),
                            title: Text(participantName),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetailPage(
                                    userId: participantRef.id,
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
          ],
        ),
      ),
    );
  }
}
