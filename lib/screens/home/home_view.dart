import 'package:easy_go_partner/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/home_controller.dart';
import '../booking/bookings.dart';
import '../wallet/wallet.dart';
import 'home_screen.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(HomeController());

    var navbarItem = [
      const BottomNavigationBarItem(
          icon: Icon(Icons.request_page), label: "Request"),
      const BottomNavigationBarItem(
          icon: Icon(Icons.history), label: "Bookings"),
      const BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_sharp), label: "Wallet"),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
    ];

    var navBody = [
      HomeScreen(),
      Bookings(),
      Wallet(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: Column(
        children: [
          Obx(
            () => Expanded(
              child: navBody.elementAt(controller.currentNavIndex.value),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          // elevation: 0.5,
          currentIndex: controller.currentNavIndex.value,
          selectedItemColor: Colors.black87,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontFamily: "sans_semibold"),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          items: navbarItem,
          onTap: (value) {
            controller.currentNavIndex.value = value;
          },
        ),
      ),
    );
  }
}
