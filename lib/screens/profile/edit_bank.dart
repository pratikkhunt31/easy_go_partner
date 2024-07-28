import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import '../../consts/firebase_consts.dart';
import '../../widget/custom_widget.dart';

class EditBankDetails extends StatefulWidget {
  const EditBankDetails({super.key});

  @override
  State<EditBankDetails> createState() => _EditBankDetailsState();
}

class _EditBankDetailsState extends State<EditBankDetails> {
  final panController = TextEditingController();
  final ifscController = TextEditingController();
  final accNumController = TextEditingController();
  final confirmAccNumber = TextEditingController();
  final accId = TextEditingController();

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
          ifscController.text = userData['IFSC_code'];
          accNumController.text = userData['acc_number'];
          confirmAccNumber.text = userData['confirm_accNumber'];
          accId.text = userData['account_id'];

          isLoading = false;
        });
      }
    }
  }

  Future<void> updateAccount() async {
    final url = Uri.parse(
        'https://easygoapi-eieu6qudpq-uc.a.run.app/accounts/${accId.text}');
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "bank_account_number": accNumController.text.trim(),
        "ifsc_code": ifscController.text.trim(),
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to update account: ${response.body}');
    }
  }

  bool validateInputs() {
    if (panController.text.trim().isEmpty ||
        ifscController.text.trim().isEmpty ||
        accNumController.text.trim().isEmpty ||
        confirmAccNumber.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('All fields are required.')));
      return false;
    }
    if (accNumController.text.trim() != confirmAccNumber.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account number doesn't match.")));
      return false;
    }
    return true;
  }

  Future<void> updateBankDetails() async {
    if (!validateInputs()) return;

    await updateAccount();

    if (currentUser != null) {
      DatabaseReference database = FirebaseDatabase.instance.ref();
      await database.child('drivers').child(currentUser!.uid).update({
        'PAN_number': panController.text.trim(),
        'IFSC_code': ifscController.text.trim(),
        'acc_number': accNumController.text.trim(),
        'confirm_accNumber': confirmAccNumber.text.trim(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bank details updated successfully!')));
  }

  @override
  void dispose() {
    panController.dispose();
    ifscController.dispose();
    accNumController.dispose();
    confirmAccNumber.dispose();
    accId.dispose();
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
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'PAN card',
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
                    controller: confirmAccNumber,
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
