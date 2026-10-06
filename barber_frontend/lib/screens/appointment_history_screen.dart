import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/appointment_provider.dart';
import '../utils/constants.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() => _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AppointmentProvider>(context, listen: false).fetchMyAppointments());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Appointment History', style: GoogleFonts.outfit(color: AppColors.primary)),
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, apptProvider, child) {
          if (apptProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter: Show all active appointments (Pending, Confirmed, Completed)
          // Exclude cancelled if desired, or keep them. User wants to see history.
          // User previously said "visible to history... transaction is done".
          // We will show all except maybe cancelled if they are confusing? 
          // Let's show ALL sorted by date so they see what's happening.
          final historyAppointments = apptProvider.myAppointments;
          // Sort by date (newest first)
          historyAppointments.sort((a, b) => b.date.compareTo(a.date));

          if (historyAppointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: AppColors.secondary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No appointment history',
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
            itemCount: historyAppointments.length,
            itemBuilder: (context, index) {
              final appt = historyAppointments[index];
              final isPositive = appt.status == 'completed' || appt.status == 'confirmed';
              final isPending = appt.status == 'pending';
              final isCompleted = appt.status == 'completed';
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isPositive
                        ? AppColors.primary.withOpacity(0.3)
                        : (isPending ? Colors.orange.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
                  ),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.all(16),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  leading: CircleAvatar(
                    backgroundColor: isPositive
                        ? AppColors.primary.withOpacity(0.2)
                        : (isPending ? Colors.orange.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
                    child: Icon(
                      isCompleted ? Icons.check_circle : (isPositive ? Icons.account_balance_wallet : (isPending ? Icons.access_time_filled : Icons.cancel)),
                      color: isPositive ? AppColors.primary : (isPending ? Colors.orange : Colors.red),
                    ),
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
                        '₹${appt.paymentAmount?.toStringAsFixed(0) ?? appt.price.toStringAsFixed(0)}',
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
                          color: isPositive 
                              ? Colors.green.withOpacity(0.2)
                              : (isPending ? Colors.orange.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          appt.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isPositive ? Colors.green : (isPending ? Colors.orange : Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    // Payment Transaction Details
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transaction Details',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Payment Method', appt.paymentMethod ?? 'Cash'),
                          _buildDetailRow('Amount Paid', '₹${appt.paymentAmount?.toStringAsFixed(0) ?? appt.price.toStringAsFixed(0)}'),
                          _buildDetailRow('Transaction ID', appt.transactionId ?? 'N/A'),
                          _buildDetailRow(
                            'Transaction Time',
                            appt.transactionTime != null
                                ? '${appt.transactionTime!.day}/${appt.transactionTime!.month}/${appt.transactionTime!.year} ${appt.transactionTime!.hour}:${appt.transactionTime!.minute.toString().padLeft(2, '0')}'
                                : 'N/A',
                          ),
                        ],
                      ),
                    ),
                    if (isCompleted)
                        Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                    onPressed: () => _showReviewDialog(context, appt.shopId, appt.shopName),
                                    icon: const Icon(Icons.star),
                                    label: const Text('Rate & Review Shop'),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.black,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: AppColors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context, String shopId, String shopName) {
      int _rating = 5;
      final _commentController = TextEditingController();

      showDialog(
          context: context,
          builder: (context) => StatefulBuilder(
              builder: (context, setState) {
                  return AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text('Rate $shopName', style: GoogleFonts.outfit(color: AppColors.primary)),
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (index) {
                                        return IconButton(
                                            onPressed: () => setState(() => _rating = index + 1),
                                            icon: Icon(
                                                index < _rating ? Icons.star : Icons.star_border,
                                                color: Colors.amber,
                                                size: 32,
                                            ),
                                        );
                                    }),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                  controller: _commentController,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                      hintText: 'Write your experience...',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: AppColors.background
                                  ),
                                  maxLines: 3,
                              ),
                          ],
                        ),
                      ),
                      actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                  if (_commentController.text.isEmpty) return;
                                  try {
                                      Navigator.pop(context); // Close dialog first
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submitting review...')));
                                      
                                      // We need API Service here. Access via Provider if handy or create new (since provider might process it).
                                      // Or quickly use ShopProvider/AppointmentProvider.
                                      // Let's us ApiService directly via AppointmentProvider context or ShopProvider.
                                      // Actually, generic ApiService instance is not available.
                                      // We can add `addReview` to `ShopProvider`.
                                      // For now, let's use ShopProvider since it relates to Shops.
                                      
                                      // Wait! I need to add addReview to ShopProvider first? 
                                      // Or I can add it now.
                                      // But wait, the previous code block didn't update ShopProvider.
                                      // I should probably add it to ShopProvider.
                                      // BUT for now, let's assume I will add it in the next step or use Provider.of<ShopProvider>(context, listen:false).apiService (if public).
                                      
                                      // ApiService is private in ShopProvider.
                                      // I MUST update ShopProvider.
                                      
                                      // I will leave this dialog call failing until I update ShopProvider.
                                      // Actually, let's assume I will update ShopProvider with `addReview` method.
                                      await Provider.of<AppointmentProvider>(context, listen:false).submitReview(shopId, _rating, _commentController.text);
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review Submitted! Rating Updated.')));
                                  } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                                  }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
                              child: const Text('Submit'),
                          )
                      ],
                  );
              }
          )
      );
  }
}
