import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Request"),
        backgroundColor: const Color(0xFF0000FF),
        elevation: 0,
        // leading: null,
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Card(
          // elevation: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Image.asset('assets/images/truck2.png',
                    width: 50, height: 50),
                title: const Text('Date and Time'),
                trailing: const Icon(Icons.arrow_forward),
              ),
              const Divider(
                height: 1.0,
                thickness: 1.0,
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: const [
                    Text("From:-"),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                          "Pick up Address Pick up Address Pick up Address"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: const [
                    Text("From:-"),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                          "Drop Location Drop Location Drop Location Drop Location"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: const [
                    SizedBox(height: 20),
                    Text(
                      "Users Details:-",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 5),
                    Text("Name, Mobile Number"),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                  ),
                  onPressed: () {},
                  child: Text("Accept"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
