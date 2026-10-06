import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/shop_model.dart';
import '../providers/shop_provider.dart';
import '../utils/constants.dart';
import 'booking_screen.dart';

class ShopDetailScreen extends StatefulWidget {
  final Shop shop;

  const ShopDetailScreen({super.key, required this.shop});

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<ShopProvider>(context, listen: false)
        .fetchServices(widget.shop.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.shop.images != null && widget.shop.images!.isNotEmpty
                      ? Image.network(widget.shop.images![0], fit: BoxFit.cover)
                      : Container(color: Colors.grey[850]),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.background],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.shop.name,
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onBackground,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.black),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.shop.rating}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: AppColors.secondary, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.shop.address,
                          style: TextStyle(color: AppColors.secondary, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.shop.description ?? '',
                    style: TextStyle(color: AppColors.secondary.withOpacity(0.8), height: 1.5),
                  ),
                  const SizedBox(height: 30),

                  // Promotions Section
                  if (widget.shop.promotions != null && widget.shop.promotions!.isNotEmpty) ...[
                      Text(
                        'Special Offers',
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.onBackground),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.shop.promotions!.length,
                          itemBuilder: (context, index) {
                            final promo = widget.shop.promotions![index];
                            return Container(
                              width: 260,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Colors.orange.shade800, Colors.orange.shade600]),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                                    child: Icon(Icons.local_offer, color: Colors.white, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(promo['title'] ?? 'Deal', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        Text(promo['discount'] ?? '', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                        if (promo['description'] != null) Text(promo['description'], style: TextStyle(color: Colors.white70, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                  ],
                  if (widget.shop.images != null && widget.shop.images!.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Gallery',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onBackground,
                          ),
                        ),
                        Text(
                          '${widget.shop.images!.length} photos',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.shop.images!.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _showFullScreenGallery(context, index),
                            child: Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                image: DecorationImage(
                                  image: NetworkImage(widget.shop.images![index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.3),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                  
                  // Employees Section (Meet the Team)
                  if (widget.shop.employees != null && widget.shop.employees!.isNotEmpty) ...[
                    Text(
                      'Meet the Team',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.shop.employees!.length,
                        itemBuilder: (context, index) {
                           final emp = widget.shop.employees![index];
                           return Container(
                             margin: const EdgeInsets.only(right: 16),
                             child: Column(
                               children: [
                                 Container(
                                   decoration: BoxDecoration(
                                     shape: BoxShape.circle,
                                     border: Border.all(color: AppColors.primary, width: 2),
                                     boxShadow: [
                                       BoxShadow(
                                         color: Colors.black.withOpacity(0.3),
                                         blurRadius: 8,
                                         offset: const Offset(0, 4),
                                       ),
                                     ],
                                   ),
                                   child: CircleAvatar(
                                     radius: 35,
                                     backgroundColor: AppColors.surface,
                                     backgroundImage: emp['image'] != null 
                                         ? NetworkImage(emp['image']) 
                                         : null,
                                     child: emp['image'] == null 
                                         ? const Icon(Icons.person, size: 30, color: AppColors.primary)
                                         : null,
                                   ),
                                 ),
                                 const SizedBox(height: 8),
                                 Text(
                                   emp['name'] ?? 'Staff',
                                   style: GoogleFonts.outfit(
                                     color: AppColors.onSurface,
                                     fontWeight: FontWeight.bold,
                                     fontSize: 14,
                                   ),
                                 ),
                                 Text(
                                   emp['role'] ?? 'Barber',
                                   style: TextStyle(
                                     color: AppColors.secondary,
                                     fontSize: 12,
                                   ),
                                 ),
                               ],
                             ),
                           );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],

                  Text(
                    'Services',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Consumer<ShopProvider>(
            builder: (context, shopProvider, child) {
              if (shopProvider.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (shopProvider.services.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('No services available', style: TextStyle(color: Colors.white))),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final service = shopProvider.services[index];
                    
                    // Calc Discount
                    double? discountedPrice;
                    String? discountLabel;
                    
                    if (widget.shop.promotions != null && widget.shop.promotions!.isNotEmpty) {
                        try {
                            // Find best discount
                            double maxPercent = 0;
                            for (var p in widget.shop.promotions!) {
                                final dStr = p['discount']?.toString() ?? '';
                                final val = double.tryParse(dStr.replaceAll(RegExp(r'[^0-9.]'), ''));
                                if (val != null && val > maxPercent) {
                                    maxPercent = val;
                                    discountLabel = dStr;
                                }
                            }
                            
                            if (maxPercent > 0) {
                                discountedPrice = service.price * (1 - (maxPercent / 100));
                            }
                        } catch (e) {
                            // ignore error
                        }
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          service.name,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.onSurface,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${service.duration} mins • ${service.description ?? ""}',
                              style: TextStyle(color: AppColors.secondary, fontSize: 12),
                            ),
                            if (discountLabel != null)
                             Padding(
                               padding: const EdgeInsets.only(top: 4),
                               child: Text('Promo applied: $discountLabel', style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                             )
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                    if (discountedPrice != null) ...[
                                        Text(
                                          '₹${service.price}',
                                          style: TextStyle(
                                            decoration: TextDecoration.lineThrough,
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          '₹${discountedPrice.toStringAsFixed(0)}',
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.greenAccent,
                                          ),
                                        ),
                                    ] else 
                                        Text(
                                          '₹${service.price}',
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                ],
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingScreen(
                                      shop: widget.shop,
                                      service: service,
                                      discountedPrice: discountedPrice
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                minimumSize: Size.zero, 
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Book'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: shopProvider.services.length,
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  void _showFullScreenGallery(BuildContext context, int initialIndex) {
    if (widget.shop.images == null || widget.shop.images!.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: widget.shop.images!.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  child: Center(
                    child: Image.network(
                      widget.shop.images![index],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Swipe to view more photos',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
