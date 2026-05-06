import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'owner_dashboard.dart';
import 'student_dashboard.dart';
import '../admin/admin_dashboard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Route to appropriate dashboard based on role
    if (authProvider.isAdmin) {
      return const AdminDashboard();
    }
    if (authProvider.isOwner) {
      return const OwnerDashboard();
    }
    return const StudentDashboard();
  }
}
