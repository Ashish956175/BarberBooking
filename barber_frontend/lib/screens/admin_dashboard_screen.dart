import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';
import '../widgets/breathing_card.dart';
import '../widgets/liquid_button.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _api = ApiService();
  int _currentIndex = 0; // 0=Home, 1=Shops, 2=Content, 3=Users, 4=Bookings
  
  Map<String, dynamic> _stats = {'users': 0, 'shops': 0, 'appointments': 0, 'reviews': 0};
  List<dynamic> _users = [];
  List<dynamic> _shops = [];
  List<dynamic> _bookings = [];
  List<dynamic> _reviews = [];
  List<dynamic> _tickets = [];
  
  bool _isLoading = false;
  final TextEditingController _broadcastController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _api.get('/admin/stats');
      final users = await _api.get('/admin/users');
      final shops = await _api.get('/admin/shops');
      final bookings = await _api.get('/admin/appointments');
      final reviews = await _api.get('/admin/reviews');
      final tickets = await _api.get('/tickets');

      setState(() {
        _stats = stats;
        _users = users;
        _shops = shops;
        _bookings = bookings;
        _reviews = reviews;
        _tickets = tickets;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading admin data: $e')));
    }
  }

  // ... (Delete functions remain the same, I will assume they are preserved or I should include them if I'm replacing the whole class body? The tool allows range replacement. I'll replace the structural parts.) 
  
  // I need to keep the delete functions. I'll use the replace tool carefully or just include them if I replace a large chunk.
  // To be safe and clean, I will replace the START of the class and the BUILD method, and the DASHBOARD tab.

  // Let's replace from `class _AdminDashboardScreenState ...` down to `Widget build ...` first.
  
  // Wait, I can't effectively split the class definition and the `build` method if I want to remove `SingleTickerProviderStateMixin`.
  // I'll replace the class declaration line first.
  
  // Actually, I'll allow multiple edits in one go if possible, or just one big edit. The file is small enough (336 lines).
  // Let's try to keep the `_delete` functions intact by targeting around them? No, that's brittle.
  // I will replace the whole file content to be sure, or just the relevant parts.
  
  // Let's replace the `_AdminDashboardScreenState` class definition line to remove the mixin.
  // Then replace `build` and `_buildDashboardTab` and `_buildStatCard`.

  Future<void> _deleteUser(String id) async {
    try {
      await _api.delete('/admin/users/$id');
      setState(() {
        _users.removeWhere((u) => u['_id'] == id);
        _stats['users'] = (_stats['users'] as int) - 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted')));
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteShop(String id) async {
    try {
       await _api.delete('/admin/shops/$id');
       setState(() {
         _shops.removeWhere((s) => s['_id'] == id);
         _stats['shops'] = (_stats['shops'] as int) - 1;
       });
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shop deleted')));
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
  
  Future<void> _verifyShop(String id, String status) async {
      try {
          await _api.put('/admin/shops/$id/verify', {'status': status});
          setState(() {
              final index = _shops.indexWhere((s) => s['_id'] == id);
              if (index != -1) {
                  _shops[index]['status'] = status;
              }
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Shop $status')));
      } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
  }

  Future<void> _deleteReview(String id) async {
      try {
          await _api.delete('/admin/reviews/$id');
          setState(() {
              _reviews.removeWhere((r) => r['_id'] == id);
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review removed')));
      } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
  }

  Future<void> _resolveTicket(String id) async {
      try {
          await _api.put('/tickets/$id', {'status': 'resolved'});
          setState(() {
              final index = _tickets.indexWhere((t) => t['_id'] == id);
              if (index != -1) _tickets[index]['status'] = 'resolved';
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket Resolved')));
      } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
  }

  Future<void> _sendBroadcast() async {
      if (_broadcastController.text.isEmpty) return;
      try {
          await _api.post('/admin/broadcast', {'message': _broadcastController.text, 'targetRole': 'all'});
          _broadcastController.clear();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Broadcast sent!')));
      } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    
    // Determine title based on view
    String title = 'Admin Command';
    if (_currentIndex == 1) title = 'Manage Shops';
    if (_currentIndex == 2) title = 'Content Moderation';
    if (_currentIndex == 3) title = 'User Management';
    if (_currentIndex == 4) title = 'All Bookings';
    if (_currentIndex == 5) title = 'Issue Management';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: _currentIndex != 0 
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => setState(() => _currentIndex = 0),
            )
          : null, // Use default drawer icon when index is 0
      ),
      drawer: _currentIndex == 0 ? Drawer(
        backgroundColor: AppColors.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.surface),
              accountName: Text(user?.name ?? 'Admin', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              accountEmail: Text(user?.email ?? 'admin@barber.com', style: GoogleFonts.outfit(color: Colors.white70)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppColors.primary,
                backgroundImage: (user?.profilePic != null && user!.profilePic!.isNotEmpty)
                    ? NetworkImage(AppConstants.fixImageUrl(user!.profilePic!))
                    : null,
                child: (user?.profilePic == null || user!.profilePic!.isEmpty)
                    ? Text(user?.name.substring(0, 1).toUpperCase() ?? 'A', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24))
                    : null,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.white),
              title: Text('Refresh Data', style: GoogleFonts.outfit(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _loadData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: Text('Edit Profile', style: GoogleFonts.outfit(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile-edit');
              },
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: GoogleFonts.outfit(color: Colors.red)),
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            ),
          ],
        ),
      ) : null, // No drawer on sub-pages
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildDashboardTab();
      case 1: return _buildShopsTab();
      case 2: return _buildContentTab();
      case 3: return _buildUsersTab();
      case 4: return _buildBookingsTab();
      case 5: return _buildIssuesTab();
      default: return _buildDashboardTab();
    }
  }

  Widget _buildDashboardTab() {
      return ListView(
          padding: const EdgeInsets.all(20),
          children: [
              Text('System Pulse', style: GoogleFonts.playfairDisplay(fontSize: 28, color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 20),
              // Revenue Card (Full Width) - Breathing Effect for importance
              BreathingCard(
                child: _buildStatCard('Total Revenue', '₹${_stats['revenue']}', Icons.attach_money, AppColors.primary, () {}),
              ),
              const SizedBox(height: 16),
              Row(
                  children: [
                      Expanded(child: _buildStatCard('Users', '${_stats['users']}', Icons.people, Colors.blueAccent, () => setState(() => _currentIndex = 3))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Shops', '${_stats['shops']}', Icons.store, Colors.greenAccent, () => setState(() => _currentIndex = 1))),
                  ],
              ),
              const SizedBox(height: 16),
              Row(
                  children: [
                       Expanded(child: _buildStatCard('Bookings', '${_stats['appointments']}', Icons.calendar_today, Colors.orangeAccent, () => setState(() => _currentIndex = 4))),
                       const SizedBox(width: 16),
                       Expanded(child: _buildStatCard('Issues', '${_tickets.length}', Icons.support_agent, Colors.redAccent, () => setState(() => _currentIndex = 5))),
                  ],
              ),
              const SizedBox(height: 40),
              
              Text('Broadcast Center', style: GoogleFonts.playfairDisplay(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GlassContainer(
                  padding: const EdgeInsets.all(24),
                  borderGradient: true, // Use new gradient border
                  child: Column(
                      children: [
                          TextField(
                              controller: _broadcastController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                  hintText: 'Send system-wide alert...',
                                  hintStyle: TextStyle(color: Colors.white38),
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.campaign, color: Colors.white38)
                              ),
                          ),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 12),
                          LiquidButton(
                            text: 'Broadcast',
                            icon: Icons.send,
                            onPressed: _sendBroadcast,
                          )
                      ],
                  ),
              )
          ],
      );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: GlassContainer(
            borderRadius: BorderRadius.circular(20),
            color: color.withOpacity(0.05), // More subtle
            borderGradient: true, // Gradient borders
            padding: const EdgeInsets.all(24), // More breathing room
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(value, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(title, style: const TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 0.5)),
                ],
            ),
        ),
      );
  }
  
  Widget _buildShopsTab() {
      final pending = _shops.where((s) => s['status'] == 'pending').toList();
      final approved = _shops.where((s) => s['status'] == 'approved').toList();

      return ListView(
          padding: const EdgeInsets.all(16),
          children: [
              if (pending.isNotEmpty) ...[
                  Text('Pending Approval (${pending.length})', style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...pending.map((s) => Card(
                      color: Colors.orange.withOpacity(0.1),
                      child: ListTile(
                          title: Text(s['name'], style: const TextStyle(color: Colors.white)),
                          subtitle: Text(s['address'] ?? 'No Address', style: const TextStyle(color: Colors.grey)),
                          trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                  IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => _verifyShop(s['_id'], 'approved')),
                                  IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => _verifyShop(s['_id'], 'rejected')),
                              ],
                          ),
                      ),
                  )),
                  const SizedBox(height: 20),
              ],
              Text('Active Shops (${approved.length})', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...approved.map((s) => ListTile(
                  leading: const Icon(Icons.store, color: Colors.white54),
                  title: Text(s['name'], style: const TextStyle(color: Colors.white70)),
                  trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _deleteShop(s['_id'])),
              ))
          ],
      );
  }

  Widget _buildContentTab() {
      return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _reviews.length,
          itemBuilder: (ctx, i) {
              final r = _reviews[i];
              return Card(
                  color: AppColors.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                      leading: const Icon(Icons.comment, color: AppColors.secondary),
                      title: Text(r['comment'] ?? 'No Comment', style: const TextStyle(color: Colors.white)),
                      subtitle: Text('${r['rating']} ⭐ • by ${r['user']?['name'] ?? 'Unknown'}', style: const TextStyle(color: Colors.grey)),
                      trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _deleteReview(r['_id'])),
                  ),
              );
          },
      );
  }
  
  Widget _buildUsersTab() {
      return ListView.builder(
          itemCount: _users.length,
          itemBuilder: (context, index) {
              final u = _users[index];
              return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surface,
                    backgroundImage: (u['profilePic'] != null && u['profilePic'].toString().isNotEmpty)
                        ? NetworkImage(AppConstants.fixImageUrl(u['profilePic']))
                        : null,
                    child: (u['profilePic'] == null || u['profilePic'].toString().isEmpty)
                        ? Text(u['name'][0].toUpperCase(), style: const TextStyle(color: AppColors.primary))
                        : null,
                  ),
                  title: Text(u['name'], style: const TextStyle(color: Colors.white)),
                  subtitle: Text(u['email'], style: const TextStyle(color: Colors.grey)),
                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteUser(u['_id'])),
              );
          },
      );
  }
  
  Widget _buildBookingsTab() {
      return ListView.builder(
          itemCount: _bookings.length,
          itemBuilder: (ctx, i) {
              final b = _bookings[i];
              return ListTile(
                  title: Text('${b['service']?['name']} @ ${b['shop']?['name']}', style: const TextStyle(color: Colors.white)),
                  subtitle: Text('${b['date']} • ${b['status']}', style: TextStyle(color: b['status'] == 'confirmed' ? Colors.green : Colors.grey)),
                  trailing: Text(b['user']?['name'] ?? 'Guest', style: const TextStyle(color: AppColors.primary)),
              );
          },
      );
  }

  Widget _buildIssuesTab() {
    return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _tickets.length,
        separatorBuilder: (ctx, i) => const Divider(color: Colors.white24),
        itemBuilder: (ctx, i) {
            final t = _tickets[i];
            bool isResolved = t['status'] == 'resolved';
            return ListTile(
                leading: CircleAvatar(
                    backgroundColor: isResolved ? Colors.green : Colors.orange,
                    child: Icon(isResolved ? Icons.check : Icons.priority_high, color: Colors.white, size: 20),
                ),
                title: Text(t['subject'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(t['description'], style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text('By: ${t['user']?['name'] ?? 'Unknown'} • ${t['status'].toString().toUpperCase()}', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                    ],
                ),
                trailing: !isResolved 
                    ? IconButton(
                        icon: const Icon(Icons.check_circle_outline, color: Colors.blue),
                        onPressed: () => _resolveTicket(t['_id']),
                        tooltip: 'Mark Resolved',
                    )
                    : const Icon(Icons.done_all, color: Colors.green),
            );
        },
    );
  }
}
