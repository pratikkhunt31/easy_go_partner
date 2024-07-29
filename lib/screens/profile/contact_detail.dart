import 'package:flutter/material.dart';

class ContactDetailsPage extends StatelessWidget {
  const ContactDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Contact Details",
        ),
        backgroundColor: const Color(0xFF0000FF),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Get in Touch",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: height * 0.022),
            Row(
              children: [
                const Icon(
                  Icons.email,
                  color: Color(0xFF0000FF),
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Email:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "easygo9444@gmail.com",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.022),
            Row(
              children: [
                const Icon(
                  Icons.phone,
                  color: Color(0xFF0000FF),
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Phone:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "+91 6353935644",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.022),
          ],
        ),
      ),
    );
  }
}
