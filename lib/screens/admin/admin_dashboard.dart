import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../models/property_model.dart';
import '../../models/user_model.dart';
import 'widgets/pending_property_card.dart';
import 'widgets/pending_owner_card.dart';
import 'widgets/rejection_dialog.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    // Load all pending items for moderation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().loadProperties();
      context.read<AuthProvider>().loadPendingOwners();
    });
  }

  Future<void> _handlePropertyVerification(PropertyModel property) async {
    final success = await context.read<PropertyProvider>().moderateProperty(
      propertyId: property.propertyId,
      status: PropertyStatus.verified,
    );
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${property.name} verified!')),
      );
    }
  }

  Future<void> _handlePropertyRejection(PropertyModel property) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => const RejectionDialog(),
    );

    if (reason != null && mounted) {
      final success = await context.read<PropertyProvider>().moderateProperty(
        propertyId: property.propertyId,
        status: PropertyStatus.rejected,
        reason: reason,
      );
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${property.name} rejected.')),
        );
      }
    }
  }

  Future<void> _handleOwnerVerification(UserModel user) async {
    final success = await context.read<AuthProvider>().verifyOwner(user.uid);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Owner ${user.displayName} verified!')),
      );
    }
  }

  Future<void> _handleOwnerRejection(UserModel user) async {
    final success = await context.read<AuthProvider>().rejectOwner(user.uid);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Owner ${user.displayName} reset to Student.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final propertyProvider = context.watch<PropertyProvider>();
    
    // Safety check (redundant but good practice)
    if (!authProvider.isAdmin) {
      return const Scaffold(
        body: Center(child: Text('Unauthorized')),
      );
    }

    // Filter for pending listings
    final pendingProperties = propertyProvider.properties
        .where((p) => p.status == PropertyStatus.pending)
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FBFD),
        appBar: AppBar(
          title: const Text(
            'Admin Portal',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF1D1B16),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Color(0xFF5287B2),
            tabs: [
              Tab(text: 'Properties'),
              Tab(text: 'Owners'),
              Tab(text: 'Ecosystem'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Pending Properties
            _buildPropertyQueue(propertyProvider, pendingProperties),
            
            // Tab 2: Pending Owners
            _buildOwnerQueue(authProvider),

            // Tab 3: Stats Placeholder
            const Center(
              child: Text('Ecosystem statistics coming soon...'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyQueue(PropertyProvider provider, List<PropertyModel> pending) {
    if (provider.isLoading && pending.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pending.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'All Properties Verified',
        subtitle: 'No properties pending verification.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => provider.loadProperties(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${pending.length} listings awaiting review',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...pending.map((p) => PendingPropertyCard(
            property: p,
            onVerify: () => _handlePropertyVerification(p),
            onReject: () => _handlePropertyRejection(p),
          )),
        ],
      ),
    );
  }

  Widget _buildOwnerQueue(AuthProvider provider) {
    final pending = provider.pendingOwners;

    if (provider.isLoading && pending.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pending.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: 'No Pending Owners',
        subtitle: 'All owner registrations are processed.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => provider.loadPendingOwners(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${pending.length} owner registrations awaiting review',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...pending.map((u) => PendingOwnerCard(
            user: u,
            onApprove: () => _handleOwnerVerification(u),
            onReject: () => _handleOwnerRejection(u),
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
