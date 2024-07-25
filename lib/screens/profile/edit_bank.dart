import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../consts/firebase_consts.dart';
import '../../widget/custom_widget.dart';

class EditBankDetails extends StatefulWidget {
  const EditBankDetails({super.key});

  @override
  State<EditBankDetails> createState() => _EditBankDetailsState();
}

class _EditBankDetailsState extends State<EditBankDetails> {
  final _formKey = GlobalKey<FormState>();
  final panController = TextEditingController();
  final bNameController = TextEditingController();
  final ifscController = TextEditingController();
  final accNumController = TextEditingController();
  final confirmAccNumber= TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
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
          panController.text = userData['PAN_number'];
          bNameController.text = userData['bank_name'];
          ifscController.text = userData['IFSC_code'];
          accNumController.text = userData['acc_number'];
          confirmAccNumber.text = userData['confirm_accNumber'];
          isLoading = false;
        });
      }
    }
  }

  Future<void> updateBankDetails() async {
    // if (_formKey.currentState!.validate()) {
      if (currentUser != null) {
        DatabaseReference database = FirebaseDatabase.instance.ref();
        await database.child('drivers').child(currentUser!.uid).update({
          'PAN_number': panController.text.trim(),
          'bank_name': bNameController.text.trim(),
          'IFSC_code': ifscController.text.trim(),
          'confirm_accNumber': accNumController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bank details updated successfully!')));
      // }
    }
  }

  @override
  void dispose() {
    panController.dispose();
    bNameController.dispose();
    ifscController.dispose();
    accNumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bank Details'),
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
              child: Column(
                children: [
                  TextFormField(
                    controller: panController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'PAN card',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: bNameController,
                    decoration: InputDecoration(
                      labelText: 'Bank Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: ifscController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'IFSC code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: accNumController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Account Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: accNumController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Account Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      hint: "Save Changes",
                      onPress: updateBankDetails,
                      borderRadius: BorderRadius.circular(5.0),
                      color: const Color(0xFF0000FF),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
