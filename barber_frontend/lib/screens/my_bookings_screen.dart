import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/appointment_provider.dart';
import '../utils/constants.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AppointmentProvider>(context, listen: false).fetchMyAppointments());
  }

  Future<void> _launchMaps(String address) async {
    // Encode address for URL
    final encodedAddress = Uri.encodeComponent(address);
    final url = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
    
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Appointments', style: GoogleFonts.outfit(color: AppColors.primary)),
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, apptProvider, child) {
          if (apptProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Filter for active appointments (pending/confirmed)
          final activeAppointments = apptProvider.myAppointments
              .where((appt) => appt.status != 'completed' && appt.status != 'cancelled')
              .toList()
              ..sort((a, b) => b.date.compareTo(a.date));

          if (activeAppointments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 80, color: AppColors.secondary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'No upcoming appointments',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeAppointments.length,
            itemBuilder: (context, index) {
              final appt = activeAppointments[index];
              final isConfirmed = appt.status == 'confirmed';
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        child: Icon(Icons.cut, color: AppColors.primary),
                      ),
                      title: Text(
                        appt.serviceName,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            appt.shopName,
                            style: TextStyle(color: AppColors.secondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            appt.date.toString().split(' ')[0],
                            style: TextStyle(color: AppColors.secondary, fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${appt.price}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isConfirmed 
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              appt.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isConfirmed ? Colors.green : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Directions button for confirmed appointments
                    if (isConfirmed)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _launchMaps(appt.shopAddress),
                            icon: Icon(Icons.directions, color: AppColors.onPrimary),
                            label: Text(
                              'Get Directions',
                              style: GoogleFonts.outfit(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
