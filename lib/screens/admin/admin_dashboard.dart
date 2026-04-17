import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../models/property_model.dart';
import 'widgets/pending_property_card.dart';
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
    // Load all properties for moderation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().loadProperties();
    });
  }

  Future<void> _handleVerification(PropertyModel property) async {
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

  Future<void> _handleRejection(PropertyModel property) async {
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
    // Note: In an real app, we'd add an admin-specific stream for efficiency
    final pendingProperties = propertyProvider.properties
        .where((p) => p.status == PropertyStatus.pending)
        .toList();

    return DefaultTabController(
      length: 2,
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
              Tab(text: 'Pending Verification'),
              Tab(text: 'Ecosystem Stats'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Pending Queue
            _buildPendingQueue(propertyProvider, pendingProperties),
            
            // Tab 2: Stats Placeholder
            const Center(
              child: Text('Ecosystem statistics coming soon...'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingQueue(PropertyProvider provider, List<PropertyModel> pending) {
    if (provider.isLoading && pending.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green[200]),
            const SizedBox(height: 16),
            const Text(
              'All caught up!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text('No properties pending verification.'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => provider.loadProperties(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                onVerify: () => _handleVerification(p),
                onReject: () => _handleRejection(p),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
