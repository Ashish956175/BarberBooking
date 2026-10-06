import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/shop_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';

class AnalyticsScreen extends StatefulWidget {
  final String shopId;
  const AnalyticsScreen({super.key, required this.shopId});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await Provider.of<ShopProvider>(context, listen: false).fetchAnalytics(widget.shopId);
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Analytics', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Earnings Card
                  GlassContainer(
                    color: AppColors.surface,
                    opacity: 0.5,
                    child: Column(
                      children: [
                        Text('Total Earnings', style: GoogleFonts.outfit(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Text(
                          '₹${_data?['totalEarnings'] ?? 0}',
                          style: GoogleFonts.outfit(
                            fontSize: 36, 
                            fontWeight: FontWeight.bold, 
                            color: AppColors.primary
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Appointments', '${_data?['completedAppointments'] ?? 0}', Icons.calendar_today),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard('Pending', '${_data?['statusDistribution']?['pending'] ?? 0}', Icons.hourglass_empty),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  Text('Recent Transactions', style: GoogleFonts.outfit(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Recent List
                  ...(_data?['recentTransactions'] as List? ?? []).map((t) {
                     return Container(
                       margin: const EdgeInsets.only(bottom: 12),
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         color: AppColors.surface,
                         borderRadius: BorderRadius.circular(12),
                         border: Border.all(color: Colors.white10),
                       ),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(t['service']['name'], style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                               Text(t['user']['name'], style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                             ],
                           ),
                           Text(
                             '+₹${t['payment']['amount']}', 
                             style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold)
                           ),
                         ],
                       ),
                     );
                  }).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return GlassContainer(
      color: AppColors.surface,
      opacity: 0.3,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(title, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}
