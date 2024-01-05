import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast(String message, {Color backgroundColor = Colors.white, Color textColor = Colors.black}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: backgroundColor,
    textColor: textColor,
    fontSize: 16.0,
  );
}

Future<Map<String, dynamic>> getDocumentData(BuildContext context, String documentId, {String collectionId = "DID"}) async {
  try {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      var result = await Permission.storage.request();
      if (result != PermissionStatus.granted) {
        // ('Storage permission not granted');
        showToast('Storage permission not granted', backgroundColor: Colors.redAccent, textColor: Colors.white);
        return {};
      }
    }

    BuildContext localContext = context;

    CollectionReference<Map<String, dynamic>> collection =
    FirebaseFirestore.instance.collection(collectionId);

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await collection.doc(documentId).get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> data = documentSnapshot.data()!;
      await saveDataAsJson(data, documentId);
      showToast('Data saved successfully');
      return data;
    } else {
      showDialog(
        context: localContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Document Not Found'),
            content: Text('The document with ID $documentId does not exist.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      // print('Document does not exist');
      return {};
    }
  } catch (e) {
    // print('Error fetching document: $e');
    showToast('Error fetching document: $e');
    return {};
  }
}

Future<void> saveDataAsJson(Map<String, dynamic> data, String documentId) async {
  try {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      showToast('Storage permission not granted');
      return;
    }

    Directory? directory = await getExternalStorageDirectory();
    File file = File('${directory?.path}/$documentId.json');
    String jsonData = jsonEncode(data);
    await file.writeAsString(jsonData);

    showToast('Data saved as JSON file: ${file.path}');
  } catch (e) {
    // print('Error saving data as JSON: $e');
    showToast('Error saving data as JSON: $e');
  }
}

Future<List<Map<String, dynamic>>> getAllJsonMaps() async {
  try {
    // Get the application's local storage directory
    Directory? directory = await getExternalStorageDirectory();

    // List all files in the directory
    List<FileSystemEntity>? files = directory?.listSync();

    // Filter out only JSON files
    List<Map<String, dynamic>> jsonMaps = [];

    for (var file in files!) {
      if (file is File && file.path.endsWith('.json')) {
        // Convert each JSON file to a map
        Map<String, dynamic> jsonMap = await convertJsonFileToMap(file);
        jsonMaps.add(jsonMap);
      }
    }

    return jsonMaps;
  } catch (e) {
    showToast('Error getting and converting JSON files to maps: $e');
    return [];
  }
}

Future<Map<String, dynamic>> convertJsonFileToMap(File jsonFile) async {
  try {
    // Read the content of the JSON file
    String jsonContent = await jsonFile.readAsString();

    // Parse the JSON content into a map
    Map<String, dynamic> jsonMap = jsonDecode(jsonContent);

    return jsonMap;
  } catch (e) {
    showToast('Error converting JSON file to map: $e');
    return {};
  }
}

