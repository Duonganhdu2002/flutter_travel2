import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_bar.dart';
import 'package:flutter_application_1/components/back_icon.dart';
import 'package:flutter_application_1/components/user_image.dart';
import 'package:flutter_application_1/services/firestore/auths_store.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile>
    with AutomaticKeepAliveClientMixin<EditProfile> {
  Uint8List? imagePicker;
  final _formKey = GlobalKey<FormState>();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool isFormValid = false;

  AuthStore authStore = AuthStore();
  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _addListeners();
    _loadLoginDetails();
  }

  void _loadLoginDetails() async {
    var userData = await authStore.getUserById(userId).first;
    if (userData != null) {
      setState(() {
        fullNameController.text = userData.fullName;
        locationController.text = userData.location ?? '';
        phoneController.text = userData.phone ?? '';
      });
    }
  }

  void _addListeners() {
    fullNameController.addListener(_validateForm);
    locationController.addListener(_validateForm);
    phoneController.addListener(_validateForm);
  }

  @override
  void dispose() {
    fullNameController.dispose();
    locationController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _updateUser() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> updatedData = {
        'fullname': fullNameController.text.trim(),
        'location': locationController.text.trim(),
        'phone': phoneController.text.trim(),
      };

      authStore.updateUser(userId, updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  void _selectImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await uploadImage(File(image.path));
    }
  }

  Future<void> uploadImage(File file) async {
    try {
      String fileName = path.basename(file.path);
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child("avatars/$fileName");

      // Upload file
      await imageRef.putFile(file);

      // Lấy URL tải xuống
      String downloadURL = await imageRef.getDownloadURL();
      debugPrint("Download URL: $downloadURL");

      // Cập nhật URL ảnh đại diện trong Firestore
      await FirebaseFirestore.instance
          .collection('auths')
          .doc(userId)
          .update({'avatar': fileName});

      // Cập nhật URL ảnh mới vào `UserImage` widget bằng cách sử dụng `setState` để cập nhật giao diện của `UserImage` (nếu cần thiết)
      setState(() {});
    } catch (e) {
      debugPrint("Error uploading image: $e");
    }
  }

  void _validateForm() {
    setState(() {
      isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: CustomBar(
        leftWidget: const BackIcon(),
        centerWidget1: const Text(
          "Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        rightWidget: InkWell(
          onTap: isFormValid ? _updateUser : null,
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
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ListView(
            children: [
              Column(
                children: [
                  ClipOval(
                    child: UserImage(
                      userId: userId,
                      width: 120,
                      height: 120,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      fullNameController.text.isNotEmpty
                          ? fullNameController.text
                          : "Unknown",
                      style: const TextStyle(
                        color: Color(0xFF1B1E28),
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _selectImage(context),
                    child: const Text(
                      "Change Profile Picture",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
              Form(
                key: _formKey,
                onChanged: _validateForm,
                child: Column(
                  children: [
                    customTextField(
                      "Full Name",
                      const Color(0xFFF7F7F9),
                      true,
                      BorderSide.none,
                      const BorderRadius.all(Radius.circular(14)),
                      fullNameController,
                      (value) =>
                          value.isNotEmpty &&
                          RegExp(r"^[a-zA-Z\s]+$").hasMatch(value),
                    ),
                    customTextField(
                      "Location",
                      const Color(0xFFF7F7F9),
                      true,
                      BorderSide.none,
                      const BorderRadius.all(Radius.circular(14)),
                      locationController,
                      (value) => value.isNotEmpty,
                    ),
                    customTextField(
                      "Mobile Number",
                      const Color(0xFFF7F7F9),
                      true,
                      BorderSide.none,
                      const BorderRadius.all(Radius.circular(14)),
                      phoneController,
                      (value) =>
                          value.isNotEmpty &&
                          RegExp(r"^[0-9]{10}$").hasMatch(value),
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
    bool Function(String) validator,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: filled,
            fillColor: color,
            border: OutlineInputBorder(
              borderSide: borderSide,
              borderRadius: borderRadius,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? Icon(
                    Icons.check,
                    color:
                        validator(controller.text) ? Colors.green : Colors.red,
                  )
                : null,
          ),
          validator: (value) {
            if (!validator(value ?? '')) {
              return 'Invalid $label';
            }
            return null;
          },
          onChanged: (value) {
            _validateForm();
          },
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
