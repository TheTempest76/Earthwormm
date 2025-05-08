import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'buyer_home.dart';
import 'buyer_profile_setup.dart';

class BuyerMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('buyers')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Show loading while waiting for data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Handle authentication errors
        if (FirebaseAuth.instance.currentUser == null) {
          return const Scaffold(
            body: Center(
              child: Text('Please sign in to continue'),
            ),
          );
        }

        // If buyer profile doesn't exist or isn't complete, show setup
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final isProfileComplete = data?['profileCompleted'] ?? false;

        if (!snapshot.hasData || !snapshot.data!.exists || !isProfileComplete) {
          return BuyerProfileSetup();
        }

        return BuyerHome();
      },
    );
  }
}
