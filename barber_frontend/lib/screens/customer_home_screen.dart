import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/shop_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../models/shop_model.dart';
import 'shop_detail_screen.dart';
import '../widgets/glass_container.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();

  final List<String> _categories = ['All', 'Haircut', 'Beard', 'Facial', 'Color', 'Massage'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShopProvider>(context, listen: false).fetchShops();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
        setState(() {
          _searchQuery = query;
          _selectedCategory = 'All';
        });
        Provider.of<ShopProvider>(context, listen: false).fetchShops(query: query);
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _searchQuery = '';
    });
    Provider.of<ShopProvider>(context, listen: false).fetchShops(query: category);
  }

  List<Shop> _getFilteredShops(List<Shop> shops) {
    List<Shop> filtered = List.from(shops);
    filtered.sort((a, b) {
      int ratingCompare = (b.rating ?? 0).compareTo(a.rating ?? 0);
      if (ratingCompare != 0) return ratingCompare;
      return (b.reviewCount ?? 0).compareTo(a.reviewCount ?? 0);
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    print('DEBUG: CustomerHomeScreen User ProfilePic: ${user?.profilePic}');
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Glass Arc Header
          SliverAppBar(
            expandedHeight: 260.0, // Increased to 260 to push text down from camera
            floating: false,
            pinned: true,
            backgroundColor: AppColors.background,
            actions: [
               Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                     Icon(Icons.location_on, color: AppColors.accent, size: 16),
                     const SizedBox(width: 4),
                     Text(
                        user?.location ?? 'Pune',
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                     ),
                     const SizedBox(width: 12),
                     GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/notifications'), // Navigate to notifications
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Icon(Icons.notifications_outlined, color: Colors.white70, size: 20),
                      ),
                     ),
                     GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/profile-edit'),
                      child: Container(
                        padding: const EdgeInsets.all(2), // White border spacing
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                          border: Border.all(color: Colors.white12, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.surface,
                            backgroundImage: (user?.profilePic != null && user!.profilePic!.isNotEmpty)
                                ? NetworkImage(AppConstants.fixImageUrl(user!.profilePic!))
                                : null,
                            child: (user?.profilePic == null || user!.profilePic!.isEmpty)
                                ? const Icon(Icons.person, color: Colors.white70, size: 20)
                                : null,
                          ),

                        ),
                      ),

                  ],
                ),
              ),
            ],
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.royalDark,
                ),
                child: Stack(
                  children: [
                    Positioned(
                       bottom: 140, // Adjusted for larger bottom height
                       left: 20,
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             'Hello, ${user?.name ?? "Guest"} 👋',
                             style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
                           ),
                           Text(
                             'Find the Best\nBarber for You',
                             style: GoogleFonts.outfit(
                               color: Colors.white,
                               fontSize: 28,
                               fontWeight: FontWeight.bold,
                               height: 1.1,
                             ),
                           ),
                         ],
                       ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(130),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.background.withOpacity(0.0), // Fade in from top? No, just solid/glass
                      AppColors.background, // Solid background when pinned to hide list behind
                    ],
                    stops: const [0.0, 0.3], // Gradient to blend with header?
                  ),
                  color: AppColors.background, // Fallback solid
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 12),
                    _buildHorizontalCategories(),
                  ],
                ),
              ),
            ),
          ),

          // Shop List Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 21, 16, 16), // Added 5px top margin (16+5)
              child: Text(
                'Top Rated Shops',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground,
                ),
              ),
            ),
          ),

          // Shop List
          Consumer<ShopProvider>(
            builder: (context, shopProvider, child) {
              if (shopProvider.isLoading) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
              }
              if (shopProvider.shops.isEmpty) {
                return const SliverFillRemaining(child: Center(child: Text('No shops found', style: TextStyle(color: Colors.white54))));
              }

              final filteredShops = _getFilteredShops(shopProvider.shops);

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final shop = filteredShops[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: _buildShopCard(shop),
                    );
                  },
                  childCount: filteredShops.length,
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GlassContainer(
      color: Colors.black, // Dark glass
      opacity: 0.3,
      blur: 20,
      borderRadius: BorderRadius.circular(30),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      borderGradient: true, // Use new API
      child: TextField(
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search name, service...",
          hintStyle: TextStyle(color: Colors.white38),
          icon: Icon(Icons.search, color: AppColors.primary),
          border: InputBorder.none,
        ),
      ),
    );
  }


  Widget _buildHorizontalCategories() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          
          return GestureDetector(
            onTap: () => _onCategorySelected(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: isSelected ? AppColors.primary : Colors.white10),
                boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 10)] : [],
              ),
              child: Center(
                child: Text(
                  category,
                  style: GoogleFonts.outfit(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShopCard(Shop shop) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ShopDetailScreen(shop: shop)),
        );
      },
      child: Container(
        height: 300, // Increased to 300 to fully fix overflow
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          children: [
            // Image Area
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: shop.images != null && shop.images!.isNotEmpty
                        ? Image.network(
                            AppConstants.fixImageUrl(shop.images!.first),
                            fit: BoxFit.cover,
                          )
                        : Container(color: Colors.grey[900], child: const Icon(Icons.store, color: Colors.white24, size: 50)),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                        ),
                      ),
                    ),
                  ),

                  
                  // Promo Badge
                  if (shop.promotions != null && shop.promotions!.isNotEmpty)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_offer, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text('PROMO', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),

                  // Rating Badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GlassContainer(
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      blur: 5,
                      opacity: 0.2,
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.primary, size: 14),
                          const SizedBox(width: 4),
                          Text('${shop.rating}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details Area
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.name,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: AppColors.accent, size: 14),
                            const SizedBox(width: 4),
                            Expanded(child: Text(shop.address, style: const TextStyle(color: Colors.white54, fontSize: 13), maxLines: 1)),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                           '9:00 AM - 9:00 PM',
                           style: const TextStyle(color: Colors.white38, fontSize: 12),
                         ),
                         Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: AppColors.primary,
                             borderRadius: BorderRadius.circular(12),
                           ),
                           child: const Icon(Icons.arrow_forward, color: Colors.black, size: 16),
                         ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
