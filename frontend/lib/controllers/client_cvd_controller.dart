import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/utils/network_utils.dart';
import 'package:frontend/screens/client_personal_data_insertion_page.dart';
//TODO: Create and place the content of this page
import 'package:frontend/screens/client_cvd_prediction_page.dart';

final FlutterSecureStorage storage = FlutterSecureStorage();

Future<void> handleCVDPredictionButtonTap(BuildContext context, String? token) async {
  try {
    final bool userHasHealthData = await checkUserHasHealthData(token);

    if (userHasHealthData) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClientCVDPredictionPage(),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Health Data Required"),
            content: Text("You need to insert your health data before receiving a prediction."),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: Text("Proceed to the Data Insertion Page"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClientPersonalDataInsertionPage(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occured: ${e.toString()}")),
    );
  }
}



