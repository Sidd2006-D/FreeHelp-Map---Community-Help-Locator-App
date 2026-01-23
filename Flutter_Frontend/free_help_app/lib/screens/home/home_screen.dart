import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    printFirebaseToken(); // 👈 runs once when screen opens
  }

  Future<void> printFirebaseToken() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("❌ No user logged in");
      return;
    }

    final token = await user.getIdToken(true);

    print("🔥 FIREBASE ID TOKEN ↓↓↓");
    print(token);
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FreeHelp")),
      body: Center(
        child:ElevatedButton(
  onPressed: () async {
    await FirebaseAuth.instance.signOut();
  },
  child: const Text("Logout"),
)
      ),
    );
  }
}


Future<void> fetchUserFromBackend() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print("User not logged in");
    return;
  }

  final token = await user.getIdToken(true);
  print("🔥 Firebase ID Token:");
  print(token);
}
