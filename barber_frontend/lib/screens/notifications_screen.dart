import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final data = await _api.get('/notifications');
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _markAsRead(String id, int index) async {
    try {
      await _api.put('/notifications/$id/read', {});
      setState(() {
        _notifications[index]['read'] = true;
      });
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifications', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _notifications.isEmpty
              ? Center(child: Text('No notifications yet', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 18)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final n = _notifications[index];
                    final isRead = n['read'] ?? false;
                    return GestureDetector(
                      onTap: () => !isRead ? _markAsRead(n['_id'], index) : null,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isRead ? AppColors.surface.withOpacity(0.5) : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isRead ? Colors.transparent : AppColors.primary.withOpacity(0.5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Container(
                               padding: const EdgeInsets.all(10),
                               decoration: BoxDecoration(
                                 color: AppColors.primary.withOpacity(0.1),
                                 shape: BoxShape.circle
                               ),
                               child: Icon(Icons.notifications, color: AppColors.primary, size: 20),
                             ),
                             const SizedBox(width: 16),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text(
                                     n['message'],
                                     style: GoogleFonts.outfit(
                                       color: Colors.white,
                                       fontSize: 16,
                                       fontWeight: isRead ? FontWeight.normal : FontWeight.bold
                                     ),
                                   ),
                                   const SizedBox(height: 6),
                                   Text(
                                     'Just now', // Placeholder for time
                                     style: const TextStyle(color: Colors.white38, fontSize: 12),
                                   ),
                                 ],
                               ),
                             ),
                             if (!isRead)
                               Container(
                                 width: 10,
                                 height: 10,
                                 decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                               )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
