// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_bar.dart';
import 'package:flutter_application_1/components/back_icon.dart';
import 'package:flutter_application_1/models/structure/conversation_model.dart';
import 'package:flutter_application_1/models/structure/message_model.dart';
import 'package:flutter_application_1/models/structure/plan_model.dart';
import 'package:flutter_application_1/pages/chat_page.dart';
import 'package:flutter_application_1/payment.dart';
import 'package:flutter_application_1/services/firestore/conversations_store.dart';
import 'package:flutter_application_1/services/firestore/messages_store.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class MakePlanPage extends StatefulWidget {
  final String placeId;
  const MakePlanPage({super.key, required this.placeId});

  @override
  State<MakePlanPage> createState() => _MakePlanPageState();
}

class _MakePlanPageState extends State<MakePlanPage>
    with AutomaticKeepAliveClientMixin<MakePlanPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController planNameController = TextEditingController();
  TextEditingController fundController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController desiredParticipantsController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  bool isPublic = false;
  bool isFormValid = false;
  List<Map<String, String>> selectedFriends = [];
  List<Map<String, String>> friends = [];
  List<Map<String, String>> filteredFriends = [];
  String userId = FirebaseAuth.instance.currentUser!.uid;

  final ConversationStore _conversationStore = ConversationStore();
  final MessageStore _messageStore = MessageStore();

  @override
  void initState() {
    super.initState();
    _addListeners();
    _loadFriendList();
  }

  void _loadFriendList() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('auths')
          .doc(userId)
          .get();
      List<dynamic> friendRefs = userSnapshot['list_friend'];
      List<Map<String, String>> friendsList = [];
      for (var friendRef in friendRefs) {
        DocumentSnapshot friendSnapshot =
            await (friendRef as DocumentReference).get();
        friendsList.add({
          'id': friendSnapshot.id,
          'username': friendSnapshot['email']
              .split('@')[0], // Extract username from email
          'avatar': friendSnapshot['avatar'],
        });
      }
      setState(() {
        friends = friendsList;
        filteredFriends = friends; // Initially, show all friends
      });
    } catch (e) {
      debugPrint("Failed to load friend list: $e");
    }
  }

  void _addListeners() {
    planNameController.addListener(_validateForm);
    fundController.addListener(_validateForm);
    startDateController.addListener(_validateForm);
    endDateController.addListener(_validateForm);
    desiredParticipantsController.addListener(_validateForm);
    searchController.addListener(() {
      onSearch(searchController.text);
    });
  }

  @override
  void dispose() {
    planNameController.dispose();
    fundController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    desiredParticipantsController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      isFormValid = planNameController.text.isNotEmpty &&
          fundController.text.isNotEmpty &&
          startDateController.text.isNotEmpty &&
          endDateController.text.isNotEmpty &&
          desiredParticipantsController.text.isNotEmpty;
    });
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<String> _getImageUrl(String avatarPath) async {
    return await FirebaseStorage.instance
        .ref()
        .child('avatars/$avatarPath')
        .getDownloadURL();
  }

  Future<void> _savePlan(
      BuildContext context, DocumentReference conversationRef) async {
    if (isFormValid) {
      try {
        // Ensure the current user is added to the participants
        if (!selectedFriends.any((friend) => friend['id'] == userId)) {
          selectedFriends.add({'id': userId, 'avatar': '', 'username': ''});
        }

        DocumentReference placeRef =
            FirebaseFirestore.instance.collection('places').doc(widget.placeId);
        DocumentReference planOwner =
            FirebaseFirestore.instance.collection('auths').doc(userId);

        Map<DocumentReference, int> initialContributions = {
          for (var friend in selectedFriends)
            FirebaseFirestore.instance.collection('auths').doc(friend['id']): 0
        };

        Plan newPlan = Plan(
          id: '',
          dayEnd: Timestamp.fromDate(
              DateFormat('yyyy-MM-dd').parse(endDateController.text)),
          dayStart: Timestamp.fromDate(
              DateFormat('yyyy-MM-dd').parse(startDateController.text)),
          fund: int.parse(fundController.text),
          name: planNameController.text,
          participants: selectedFriends
              .map((friend) => FirebaseFirestore.instance
                  .collection('auths')
                  .doc(friend['id']))
              .toList(),
          placeRef: placeRef,
          planOwner: planOwner,
          public: isPublic,
          contributions: initialContributions,
          desiredParticipants: int.parse(desiredParticipantsController.text),
          conversationRef: conversationRef, // Lưu conversationRef vào kế hoạch
        );

        await FirebaseFirestore.instance
            .collection('plannings')
            .add(newPlan.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plan saved successfully')));

        Navigator.pop(context);
      } catch (e) {
        debugPrint('Error saving plan: $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed to save plan')));
      }
    }
  }

  Future<void> _createGroup(String groupName) async {
    try {
      if (!selectedFriends.any((friend) => friend['id'] == userId)) {
        selectedFriends.add({'id': userId});
      }

      final conversation = Conversation(
        participants: selectedFriends
            .map((friend) =>
                FirebaseFirestore.instance.doc('auths/${friend['id']}'))
            .toList(),
        name: groupName,
        isGroup: true,
        groupOwner: FirebaseFirestore.instance.doc('auths/$userId'),
      );

      DocumentReference conversationRef =
          await _conversationStore.addConversation(conversation);

      final message = Message(
        text: 'Group has been created.',
        senderId: FirebaseFirestore.instance.doc('auths/$userId'),
        receivedId: selectedFriends
            .map((friend) =>
                FirebaseFirestore.instance.doc('auths/${friend['id']}'))
            .toList(),
        createdAt: Timestamp.now(),
        conversationId: conversationRef,
      );

      await _messageStore.addMessage(message);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group created successfully')),
      );

      // Save the plan with the conversation reference
      await _savePlan(context, conversationRef);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            userId: userId,
            friendRefs: conversation.participants,
            groupName: conversation.name,
            conversationId: conversationRef,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating group: $e')),
      );
      debugPrint('Error creating group: $e');
    }
  }

  void toggleSelection(Map<String, String> friend) {
    setState(() {
      if (selectedFriends.any((selected) => selected['id'] == friend['id'])) {
        selectedFriends
            .removeWhere((selected) => selected['id'] == friend['id']);
      } else {
        selectedFriends.add(friend);
      }
    });
  }

  void onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredFriends = friends;
      } else {
        filteredFriends = friends
            .where((friend) =>
                friend['username']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> initPaymentSheet() async {
    try {
      int amount = int.parse(fundController.text);
      int amountInCents = amount * 100; // Convert to cents

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

      // If the payment is successful, create the group and save the plan
      await _createGroup(planNameController.text);
    } catch (e) {
      debugPrint('Error initializing payment sheet: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showFriendSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Friends'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selectedFriends.isNotEmpty)
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: selectedFriends.length,
                          itemBuilder: (context, index) {
                            final selectedFriend = selectedFriends[index];

                            return FutureBuilder<String>(
                              future: _getImageUrl(selectedFriend['avatar']!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(right: 15.0),
                                  child: SizedBox(
                                    width: 70,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          child: Image.network(
                                            snapshot.data!,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                            ),
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: SvgPicture.asset(
                                                "assets/images/delete.svg",
                                                width: 16,
                                                height: 16,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  selectedFriends
                                                      .removeAt(index);
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search friends',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: onSearch,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredFriends.length,
                        itemBuilder: (context, index) {
                          final friend = filteredFriends[index];
                          final isSelected = selectedFriends.any(
                              (selected) => selected['id'] == friend['id']);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 25.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  toggleSelection(friend);
                                });
                              },
                              child: Row(
                                children: [
                                  FutureBuilder<String>(
                                    future: _getImageUrl(friend['avatar']!),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      }
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: Image.network(
                                          snapshot.data!,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
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
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      key: const PageStorageKey<String>('makePlan'),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: CustomBar(
        leftWidget: const BackIcon(),
        centerWidget1: const Text(
          "Make Plan",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        rightWidget: InkWell(
          onTap: isFormValid ? () => initPaymentSheet() : null,
          child: Text(
            "Done",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isFormValid ? Colors.amber : Colors.grey,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: ListView(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    customTextField(
                      "Plan Name",
                      const Color(0xFFF7F7F9),
                      true,
                      BorderSide.none,
                      BorderRadius.circular(14),
                      planNameController,
                      TextInputType.text,
                    ),
                    customTextField(
                      "Plan's Fund",
                      const Color(0xFFF7F7F9),
                      true,
                      BorderSide.none,
                      BorderRadius.circular(14),
                      fundController,
                      TextInputType.number,
                    ),
                    customTextField(
                      "Desired Participants",
                      const Color(0xFFF7F7F9),
                      true,
                      BorderSide.none,
                      BorderRadius.circular(14),
                      desiredParticipantsController,
                      TextInputType.number,
                    ), // Thêm trường nhập cho desiredParticipants
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: customTextFieldWithDatePicker(
                            "Start Date",
                            const Color(0xFFF7F7F9),
                            true,
                            BorderSide.none,
                            BorderRadius.circular(14),
                            startDateController,
                            context,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: customTextFieldWithDatePicker(
                            "End Date",
                            const Color(0xFFF7F7F9),
                            true,
                            BorderSide.none,
                            BorderRadius.circular(14),
                            endDateController,
                            context,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SwitchListTile(
                      title: const Text("This plan is public"),
                      value: isPublic,
                      activeColor: Colors.amber,
                      onChanged: (bool value) {
                        setState(() {
                          isPublic = value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: _showFriendSelectionDialog,
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
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: Text("Go with friend"),
                          ),
                        ),
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

  Widget customTextField(
    String label,
    Color color,
    bool filled,
    BorderSide borderSide,
    BorderRadius borderRadius,
    TextEditingController controller,
    TextInputType keyboardType,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: filled,
            fillColor: color,
            border: OutlineInputBorder(
              borderSide: borderSide,
              borderRadius: borderRadius,
            ),
          ),
          onChanged: (value) {
            setState(() {}); // This will re-render the widget
          },
        ),
      ],
    );
  }

  Widget customTextFieldWithDatePicker(
    String label,
    Color color,
    bool filled,
    BorderSide borderSide,
    BorderRadius borderRadius,
    TextEditingController controller,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: filled,
            fillColor: color,
            border: OutlineInputBorder(
              borderSide: borderSide,
              borderRadius: borderRadius,
            ),
            suffixIcon: IconButton(
              icon: SvgPicture.asset(
                "assets/images/Calendar.svg",
                width: 28,
                height: 28,
              ),
              onPressed: () {
                _selectDate(context, controller);
              },
            ),
          ),
          onChanged: (value) {
            setState(() {}); // This will re-render the widget
          },
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
