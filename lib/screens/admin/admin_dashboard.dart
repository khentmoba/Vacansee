import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../models/property_model.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import 'widgets/pending_property_card.dart';
import 'widgets/pending_owner_card.dart';
import 'widgets/rejection_dialog.dart';
import 'widgets/admin_profile_menu.dart';
import 'widgets/stats_card.dart';

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
      context.read<AdminProvider>().loadStats();
    });
  }

  Future<void> _handlePropertyVerification(PropertyModel property) async {
    final success = await context.read<PropertyProvider>().moderateProperty(
      propertyId: property.propertyId,
      status: PropertyStatus.verified,
    );
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${property.name} verified!')),
        );
      } else {
        final error = context.read<PropertyProvider>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to verify: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${property.name} rejected.')),
          );
        } else {
          final error = context.read<PropertyProvider>().errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reject: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleOwnerVerification(UserModel user) async {
    final success = await context.read<AuthProvider>().verifyOwner(user.uid);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Owner ${user.displayName} verified!')),
        );
      } else {
        final error = context.read<AuthProvider>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to verify owner: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleOwnerRejection(UserModel user) async {
    final success = await context.read<AuthProvider>().rejectOwner(user.uid);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Owner ${user.displayName} reset to Student.')),
        );
      } else {
        final error = context.read<AuthProvider>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset owner: $error'),
            backgroundColor: Colors.red,
          ),
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
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D1B16)),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: const [
            AdminProfileMenu(),
            SizedBox(width: 8),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFF5287B2),
            labelColor: Color(0xFF5287B2),
            unselectedLabelColor: Color(0xFF666666),
            tabs: [
              Tab(text: 'Properties'),
              Tab(text: 'Owners'),
              Tab(text: 'Ecosystem'),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                // Tab 1: Pending Properties
                _buildTabWrapper(
                  context,
                  _buildPropertyQueue(propertyProvider, pendingProperties),
                ),
                
                // Tab 2: Pending Owners
                _buildTabWrapper(
                  context,
                  _buildOwnerQueue(authProvider),
                ),

                // Tab 3: Ecosystem Stats
                _buildTabWrapper(
                  context,
                  _buildEcosystemTab(context),
                ),
              ],
            ),
            if (propertyProvider.isLoading || authProvider.isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabWrapper(BuildContext context, Widget child) {
    final adminProvider = context.watch<AdminProvider>();
    final stats = adminProvider.stats;

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<AdminProvider>().loadStats();
        if (!context.mounted) return;
        context.read<PropertyProvider>().loadProperties();
        await context.read<AuthProvider>().loadPendingOwners();
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          if (stats != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 160,
                      child: StatsCard(
                        title: 'Total Properties',
                        value: stats.totalProperties.toString(),
                        icon: Icons.home_work_outlined,
                        color: const Color(0xFF5287B2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 160,
                      child: StatsCard(
                        title: 'Property Owners',
                        value: stats.totalOwners.toString(),
                        icon: Icons.people_alt_outlined,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 160,
                      child: StatsCard(
                        title: 'Registered Students',
                        value: stats.totalStudents.toString(),
                        icon: Icons.school_outlined,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildEcosystemTab(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final stats = adminProvider.stats;

    if (adminProvider.isLoading && stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (stats == null) {
      return const Center(child: Text('Failed to load platform data.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Platform Integrity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildStatDetailRow(
          'Verified Properties',
          '${stats.verifiedProperties} / ${stats.totalProperties}',
          (stats.verifiedProperties / stats.totalProperties),
          const Color(0xFF10B981),
        ),
        const SizedBox(height: 16),
        _buildStatDetailRow(
          'Verification Rate',
          '${((stats.verifiedProperties / stats.totalProperties) * 100).toStringAsFixed(1)}%',
          (stats.verifiedProperties / stats.totalProperties),
          const Color(0xFF5287B2),
        ),
        const SizedBox(height: 32),
        Text(
          'Last aggregated: ${stats.lastUpdated.toString().split('.').first}',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatDetailRow(String label, String value, double progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.isNaN ? 0 : progress,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
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

    return Column(
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
          onVerify: () => _handlePropertyVerification(p),
          onReject: () => _handlePropertyRejection(p),
        )),
      ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
