// main.dart
import 'package:OptiWallet/firebaseHandlers/firebase_notification.dart';
import 'package:OptiWallet/pages/login.dart';
import 'package:OptiWallet/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:OptiWallet/firebase_options.dart';
import 'package:OptiWallet/pages/home_page.dart';
// Import the SplashScreen file


late final FirebaseApp app;
final navigator = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessagingHandler().initNotifications();
  // runApp(
  //   ChangeNotifierProvider(
  //     create: (context) => MyAuthProvider(),
  //     child: const MainApp(),
  //   ),
  // );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OptiWallet App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Use SplashScreen as the initial screen
      home: const SplashScreen(),
      // home: const HomePage(),
      // initialRoute: '/login',
      navigatorKey: navigator,
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

