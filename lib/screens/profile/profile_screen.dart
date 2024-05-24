

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../../controller/auth_controller.dart';
import '../../widget/custom_widget.dart';
import '../login/num_screen.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
      body: Padding(
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
                        color: Colors.grey.shade300, shape: BoxShape.circle),
                    child: const Icon(
                      Icons.person,
                      size: 70,
                      color: Color(0xFF0000FF),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "User Name",
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
                      Get.to(() => const EditProfile());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "Settings",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            SettingItem(
              title: "Language",
              value: "Gujarati",
              icon: Ionicons.earth,
              bgColor: Colors.orange.shade100,
              iconColor: Colors.orange,
              onTap: () {},
            ),
            const SizedBox(height: 20),
            SettingItem(
              title: "Your Bookings",
              icon: Ionicons.receipt_sharp,
              bgColor: Colors.red.shade100,
              iconColor: Colors.red,
              onTap: () {},
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
                } catch(e) {
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
