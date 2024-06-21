import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';

import '../../consts/firebase_consts.dart';
import '../../widget/custom_widget.dart';

// class EditProfile extends StatefulWidget {
//   const EditProfile({super.key});
//
//   @override
//   State<EditProfile> createState() => _EditProfileState();
// }
//
// class _EditProfileState extends State<EditProfile> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Edit Profile",
//           style: TextStyle(
//             fontSize: 25,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         backgroundColor: const Color(0xFF0000FF),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.check_sharp),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // const Text(
//             //   "Account",
//             //   style: TextStyle(
//             //     fontSize: 30,
//             //     fontWeight: FontWeight.bold,
//             //   ),
//             // ),
//             // const SizedBox(height: 0),
//             EditItem(
//               title: "Photo",
//               widget: Column(
//                 children: [
//                   const Icon(
//                     Icons.person,
//                     size: 100,
//                   ),
//                   TextButton(
//                     onPressed: () {},
//                     style: TextButton.styleFrom(
//                       foregroundColor: Colors.lightBlueAccent,
//                     ),
//                     child: const Text("Upload Image"),
//                   ),
//                 ],
//               ),
//             ),
//             const EditItem(
//               title: "Name",
//               widget: TextField(),
//             ),
//             const SizedBox(height: 20),
//             const EditItem(
//               title: "Email",
//               widget: TextField(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pinCodeController = TextEditingController();
  final rcNumController = TextEditingController();
  final dLController = TextEditingController();

  File? rcBookImg;
  File? licenseImg;
  List<File> vehicleImages = [];
  String? selectedVehicleType;
  bool isLoading = true;

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
          phoneNumberController.text = userData['phoneNumber'];
          emailController.text = userData['email'];
          addressController.text = userData['street'];
          cityController.text = userData['city'];
          stateController.text = userData['state'];
          pinCodeController.text = userData['postal_code'];
          rcNumController.text = userData['rcNumber'];
          dLController.text = userData['dl_number'];
          selectedVehicleType = userData['vehicleType'];
          isLoading = false;
        });
      }
    }
  }

  Future<void> updateUserProfile() async {
    if (_formKey.currentState!.validate()) {
      if (currentUser != null) {
        DatabaseReference database = FirebaseDatabase.instance.ref();
        await database.child('drivers').child(currentUser!.uid).update({
          'name': nameController.text.trim(),
          'phoneNumber': phoneNumberController.text.trim(),
          'email': emailController.text.trim(),
          'street': addressController.text.trim(),
          'city': cityController.text.trim(),
          'state': stateController.text.trim(),
          'postal_code': pinCodeController.text.trim(),
          'rcNumber': rcNumController.text.trim(),
          'dl_number': dLController.text.trim(),
          'vehicleType': selectedVehicleType,
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully!')));
      }
    }
  }

  Future<void> pickImage(ImageSource source, String imageType) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        switch (imageType) {
          case 'rcBook':
            rcBookImg = File(pickedFile.path);
            break;
          case 'license':
            licenseImg = File(pickedFile.path);
            break;
          case 'vehicle':
            vehicleImages.add(File(pickedFile.path));
            break;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pinCodeController.dispose();
    rcNumController.dispose();
    dLController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Color(0xFF0000FF),
        elevation: 0.0,
      ),
      body: isLoading
          ? Center(
              child: SpinKitFadingCircle(
                color: Color(0xFF0000FF),
                size: 50.0,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // CircleAvatar(
                    //   radius: 50,
                    //   backgroundImage: rcBookImg != null ? FileImage(rcBookImg!) : AssetImage('assets/profile_placeholder.png') as ImageProvider,
                    // ),
                    // SizedBox(height: 20),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Street',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your street address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: cityController,
                      decoration: InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your city';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: stateController,
                      decoration: InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your state';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: pinCodeController,
                      decoration: InputDecoration(
                        labelText: 'Postal Code',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your postal code';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: rcNumController,
                      decoration: InputDecoration(
                        labelText: 'RC Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your RC number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: dLController,
                      decoration: InputDecoration(
                        labelText: 'DL Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your DL number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    // DropdownButtonFormField<String>(
                    //   value: selectedVehicleType,
                    //   items: <String>['Car', 'Bike', 'Truck'].map((String value) {
                    //     return DropdownMenuItem<String>(
                    //       value: value,
                    //       child: Text(value),
                    //     );
                    //   }).toList(),
                    //   onChanged: (newValue) {
                    //     setState(() {
                    //       selectedVehicleType = newValue;
                    //     });
                    //   },
                    //   decoration: InputDecoration(
                    //     labelText: 'Vehicle Type',
                    //     border: OutlineInputBorder(),
                    //   ),
                    // ),
                    SizedBox(height: 20),
                    // ElevatedButton.icon(
                    //   onPressed: () => pickImage(ImageSource.gallery, 'rcBook'),
                    //   icon: Icon(Icons.image),
                    //   label: Text('Pick RC Book Image'),
                    //   style: ElevatedButton.styleFrom(
                    //     primary: Colors.teal,
                    //   ),
                    // ),
                    // ElevatedButton.icon(
                    //   onPressed: () => pickImage(ImageSource.gallery, 'license'),
                    //   icon: Icon(Icons.image),
                    //   label: Text('Pick License Image'),
                    //   style: ElevatedButton.styleFrom(
                    //     primary: Colors.teal,
                    //   ),
                    // ),
                    // ElevatedButton.icon(
                    //   onPressed: () => pickImage(ImageSource.gallery, 'vehicle'),
                    //   icon: Icon(Icons.image),
                    //   label: Text('Pick Vehicle Image'),
                    //   style: ElevatedButton.styleFrom(
                    //     primary: Colors.teal,
                    //   ),
                    // ),
                    // SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: updateUserProfile,
                      child: Text('Update Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0000FF),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
