import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_earthworm/services/auth_service.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        return StreamBuilder<User?>(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingScreen();
            }

            if (snapshot.hasData) {
              // User is logged in, check their type and redirect
              _checkUserTypeAndRedirect(context, snapshot.data!.uid);
              return _buildLoadingScreen();
            }

            // User is not logged in, redirect to login
            Future.microtask(
                () => Navigator.pushReplacementNamed(context, '/signin'));
            return _buildLoadingScreen();
          },
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/earthworm_logo.png', width: 150),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkUserTypeAndRedirect(
      BuildContext context, String uid) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userType = userDoc.data()?['userType'];

    if (userType == 'farmer') {
      Navigator.pushReplacementNamed(context, '/farmer/home');
    } else if (userType == 'buyer') {
      Navigator.pushReplacementNamed(context, '/buyer/home');
    } else {
      // Handle invalid user type
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }
}
