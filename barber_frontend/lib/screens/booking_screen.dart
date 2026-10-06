import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/shop_model.dart';
import '../models/service_model.dart';
import '../providers/appointment_provider.dart';
import '../utils/constants.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final Shop shop;
  final Service service;
  final double? discountedPrice;

  const BookingScreen({super.key, required this.shop, required this.service, this.discountedPrice});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 30)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                onPrimary: Colors.black,
                surface: AppColors.surface,
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        });
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                onPrimary: Colors.black,
                surface: AppColors.surface,
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        });
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _confirmBooking() {
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Navigate to payment screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          shopId: widget.shop.id,
          shopName: widget.shop.name,
          serviceId: widget.service.id,
          serviceName: widget.service.name,
          price: widget.discountedPrice ?? widget.service.price,
          date: dateTime,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 30),
            Text('Select Date & Time', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onBackground)),
            const SizedBox(height: 16),
            _buildDateTimeSelector(
              icon: Icons.calendar_today,
              value: "${_selectedDate.toLocal()}".split(' ')[0],
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            _buildDateTimeSelector(
              icon: Icons.access_time,
              value: _selectedTime.format(context),
              onTap: () => _selectTime(context),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmBooking,
                child: const Text('CONFIRM BOOKING'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Service', style: TextStyle(color: AppColors.secondary)),
              Text(widget.service.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
            ],
          ),
          const Divider(color: Colors.white10, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shop', style: TextStyle(color: AppColors.secondary)),
              Text(widget.shop.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
            ],
          ),
          const Divider(color: Colors.white10, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Price', style: TextStyle(color: AppColors.secondary)),
              widget.discountedPrice != null 
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                          Text('₹${widget.service.price}', style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 14)),
                          Text('₹${widget.discountedPrice}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.greenAccent)),
                      ],
                    )
                  : Text('₹${widget.service.price}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSelector({required IconData icon, required String value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 16),
            Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }
}
