import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/shop_provider.dart';
import '../utils/constants.dart';

class ReviewsScreen extends StatefulWidget {
  final String shopId;

  const ReviewsScreen({super.key, required this.shopId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  bool _isLoading = true;
  List<dynamic> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
      try {
          final data = await Provider.of<ShopProvider>(context, listen: false).fetchReviews(widget.shopId);
          setState(() {
              _reviews = data;
              _isLoading = false;
          });
      } catch (e) {
          setState(() => _isLoading = false);
          // Handle error silently or show snackbar
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Customer Reviews', style: GoogleFonts.outfit(color: AppColors.primary)),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: AppColors.secondary),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _reviews.isEmpty 
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(Icons.star_outline, size: 80, color: Colors.white24),
                        const SizedBox(height: 16),
                        Text('No reviews yet', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 18)),
                    ],
                )
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                    final review = _reviews[index];
                    final user = review['user'] ?? {};
                    final name = user['name'] ?? 'Anonymous';
                    final image = user['profilePic'] ?? '';
                    final rating = (review['rating'] ?? 0).toDouble();
                    final comment = review['comment'] ?? '';
                    final date = DateTime.tryParse(review['createdAt'] ?? '') ?? DateTime.now();
                    final formattedDate = DateFormat.yMMMd().format(date);

                    return Card(
                        color: AppColors.surface,
                        margin: const EdgeInsets.only(bottom: 12),
                        child:Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Row(
                                        children: [
                                            CircleAvatar(
                                                backgroundImage: NetworkImage(AppConstants.fixImageUrl(image)),
                                                radius: 20,
                                                onBackgroundImageError: (_, __) => const Icon(Icons.person),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                    Text(formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                                ]
                                            ),
                                            const Spacer(),
                                            Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                    color: AppColors.primary.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(12)
                                                ),
                                                child: Row(
                                                    children: [
                                                        const Icon(Icons.star, color: AppColors.primary, size: 14),
                                                        const SizedBox(width: 4),
                                                        Text('$rating', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
                                                    ],
                                                ),
                                            )
                                        ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(comment, style: const TextStyle(color: Colors.white70)),
                                ],
                            ),
                        )
                    );
                },
              ),
    );
  }
}
