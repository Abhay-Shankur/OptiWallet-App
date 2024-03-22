import 'package:OptiWallet/firebaseHandlers/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:OptiWallet/pages/scan_page.dart';
import 'package:OptiWallet/download.dart';

import '../firebaseHandlers/firestore_handler.dart';
// ... (Your existing imports)

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Map<String, dynamic>> jsonDataList;
  late String? _did;

  @override
  void initState() {
    super.initState();
    _loadData();
    _getDID();
  }

  Future _getDID() async {
    String? email= FirebaseAuthOperations(context: context).getUserEmail();
    FirestoreHandler firestoreHandler = FirestoreHandler();
    Map<String, dynamic>? user = await firestoreHandler.getDocument('USER', email!);
    setState(() {
      _did = user!['did'];
    });
    firestoreHandler.closeFirestore();
  }
  Future<void> _loadData() async {
    try {
      List<Map<String, dynamic>> data = await getAllJsonMaps();
      setState(() {
        jsonDataList = data;
      });
    } catch (e) {
      _showDialogBox(title: 'Error', content: 'An error occurred: $e');
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OptiWallet'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.grey,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'OptiWallet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                  Text(_did!),
                ],
              ),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Scan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Log Out'),
              onTap: () {
                FirebaseAuthOperations(context: context).signOut();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // _showAddDialog(context);

          // Use call _downloadData
          _downloadData();

          // String? email =Provider.of<MyAuthProvider>(context).getUser?.email;
          // await getDocumentData(
          //     email!,
          //     collectionId: "Credentials");
          // _loadData(); // Refresh the data after download
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: jsonDataList == null
          ? const Center(child: CircularProgressIndicator())
          : jsonDataList.isEmpty
          ? const Center(child: Text('No data available.'))
          : ListView.builder(
        itemCount: jsonDataList.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> jsonData = jsonDataList[index];
          return buildCard(jsonData);
        },
      ),
    );
  }


  Widget buildCard(Map<String, dynamic> jsonData) {
    return Card(
      elevation: 30.0
       , // Add a bit of shadow
      margin: const EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          height: 200.0,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background_image.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 26.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        (jsonData["credentialDocument"]["id"] ?? 'Null id')
                            .substring(0, 20) +
                            (jsonData["credentialDocument"]["id"].length > 20
                                ? '...'
                                : ''),
                        style: const TextStyle(
                          fontSize: 27.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  const SizedBox(height: 10.0),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
                      child: Text(
                        jsonData['credentialDocument']['type'].join(",\n ") ??
                            'Null type values',
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, bottom: 7.0),
                      child: Text(
                        jsonData['credentialStatus']['expirationDate'] ??
                            'Null Expiry',
                        style: const TextStyle(
                          fontSize: 15.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    TextEditingController textEditingController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Item'),
          // content: Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     TextField(
          //       controller: textEditingController,
          //       decoration: const InputDecoration(
          //         labelText: 'Enter text',
          //       ),
          //     ),
          //   ],
          // ),
          actions: [
            // TextButton(
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            //   child: const Text('Cancel'),
            // ),
            TextButton(
              onPressed: () {
                // Use the enteredText as needed, for example, call _downloadData
                // _downloadData(enteredText: enteredText);
                _downloadData();
                Navigator.pop(context);
              },
              child: const Text('Download'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadData() async {
    try {
      // Handle download action or any other logic here
      // await getDocumentData(context,"did:hid:namespace:.......................");

      String? email= FirebaseAuthOperations(context: context).getUserEmail();
      debugPrint('User Email: $email');
      await getDocumentData(
          email!,
          collectionId: "Credentials");
      _loadData(); // Refresh the data after download
    } catch (e) {
      _showDialogBox(
          title: 'Error', content: 'An error occurred during download: $e');
    }
  }

  void _showDialogBox({String title = "Title", String content = "Content"}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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
  }
}
