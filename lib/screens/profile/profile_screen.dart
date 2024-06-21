import 'package:easy_go_partner/screens/profile/edit_bank.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../../consts/firebase_consts.dart';
import '../../controller/auth_controller.dart';
import '../../widget/custom_widget.dart';
import '../login/num_screen.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  Future<void> loadUserData() async {
    if (currentUser != null) {
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child('drivers')
          .child(currentUser!.uid);
      DataSnapshot snapshot = await userRef.get();
      if (snapshot.exists) {
        Map<String, dynamic> userData =
            Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          nameController.text = userData['name'];
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.put(AuthController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Account",
          style: TextStyle(
            fontSize: 25,
          ),
        ),
        backgroundColor: const Color(0xFF0000FF),
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: SpinKitFadingCircle(
                color: Color(0xFF0000FF),
                size: 50.0,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const Text(
                  //   "Setting",
                  //   style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 10),
                  // const Text(
                  //   "Account",
                  //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  // ),
                  // const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF0000FF),
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(20), // Adjust the padding as needed
                          child: Text(
                            nameController.text.isNotEmpty ? nameController.text[0] : '',
                            style: TextStyle(
                              fontSize: 24, // Adjust the font size as needed
                              fontWeight: FontWeight.bold, // Optional: make the text bold
                              color: Colors.white, // Adjust the text color as needed
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nameController.text.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              "Personal Info",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ForwardIcon(
                          onTap: () {
                            Get.to(() => EditProfileScreen());
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // const SizedBox(height: 20),
                  // SettingItem(
                  //   title: "Language",
                  //   value: "Gujarati",
                  //   icon: Ionicons.earth,
                  //   bgColor: Colors.orange.shade100,
                  //   iconColor: Colors.orange,
                  //   onTap: () {},
                  // ),
                  const SizedBox(height: 20),
                  SettingItem(
                    title: "Bank Details",
                    icon: Ionicons.receipt_sharp,
                    bgColor: Colors.red.shade100,
                    iconColor: Colors.red,
                    onTap: () {
                      Get.to(() => EditBankDetails());
                    },
                  ),
                  const SizedBox(height: 20),
                  SettingItem(
                    title: "Terms & Condition",
                    icon: Ionicons.text,
                    bgColor: Colors.blue.shade100,
                    iconColor: Colors.blue,
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  SettingItem(
                    title: "Help",
                    icon: Ionicons.help,
                    bgColor: Colors.green.shade100,
                    iconColor: Colors.green,
                    onTap: () {
                      // print(currentUser!);
                    },
                  ),
                  const SizedBox(height: 20),
                  SettingItem(
                    title: "LogOut",
                    icon: Ionicons.log_out_sharp,
                    bgColor: Colors.red.shade100,
                    iconColor: Colors.red,
                    onTap: () async {
                      try {
                        print("logout");
                        await authController.logout();
                        Get.offAll(() => NumberScreen());
                      } catch (e) {
                        print(e);
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
