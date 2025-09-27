import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductCategoryScreen extends StatelessWidget {
  final String category;

  ProductCategoryScreen({super.key, required this.category});

  // Dummy data for products
  final Map<String, List<Map<String, dynamic>>> categoryProducts = {
    'Foundation': [
      {
        'name': 'Perfect Match Foundation',
        'brand': 'SkinGlow',
        'price': '\$29.99',
        'rating': 4.8,
        'image': 'assets/images/guide_image.jpg',
        'description': 'Lightweight, buildable coverage with SPF 30',
        'skinType': ['All Skin Types'],
        'benefits': ['Natural Finish', 'Long-lasting', '24h Hydration']
      },
      {
        'name': 'Matte Perfection',
        'brand': 'BeautyPro',
        'price': '\$34.99',
        'rating': 4.7,
        'image': 'assets/images/guide_image.jpg',
        'description': 'Oil-free matte foundation for lasting coverage',
        'skinType': ['Oily', 'Combination'],
        'benefits': ['Oil Control', 'Pore Minimizing', 'Transfer-proof']
      },
      // Add more foundation products...
    ],
    'Moisturizer': [
      {
        'name': 'Hydra-Boost Cream',
        'brand': 'SkinCare+',
        'price': '\$24.99',
        'rating': 4.9,
        'image': 'assets/images/guide_image.jpg',
        'description': 'Intense hydration with hyaluronic acid',
        'skinType': ['Dry', 'Normal'],
        'benefits': ['Deep Hydration', 'Plumping', 'Anti-aging']
      },
      {
        'name': 'Oil-Free Moisture',
        'brand': 'PureGlow',
        'price': '\$19.99',
        'rating': 4.6,
        'image': 'assets/images/guide_image.jpg',
        'description': 'Lightweight gel moisturizer for oily skin',
        'skinType': ['Oily', 'Combination'],
        'benefits': ['Oil Control', 'Non-comedogenic', 'Cooling']
      },
      // Add more moisturizer products...
    ],
    'Sunscreen': [
      {
        'name': 'Ultra Light SPF 50',
        'brand': 'SunDefense',
        'price': '\$27.99',
        'rating': 4.8,
        'image': 'assets/images/guide_image.jpg',
        'description': 'Lightweight broad-spectrum protection',
        'skinType': ['All Skin Types'],
        'benefits': ['UVA/UVB Protection', 'Non-greasy', 'Water-resistant']
      },
      {
        'name': 'Mineral Shield SPF 40',
        'brand': 'NaturalGuard',
        'price': '\$32.99',
        'rating': 4.7,
        'image': 'assets/images/guide_image.jpg',
        'description': 'Mineral-based sunscreen for sensitive skin',
        'skinType': ['Sensitive', 'Normal'],
        'benefits': ['Reef-safe', 'Non-irritating', 'Natural ingredients']
      },
      // Add more sunscreen products...
    ],
  };

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Color(0xFF8E44AD);
    final backgroundColor = isDarkMode ? Color(0xFF121212) : Color(0xFFF8F0FE);
    final cardColor = isDarkMode ? Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Color(0xFF333333);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          category,
          style: GoogleFonts.montserrat(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: primaryColor),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF3E5F5),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildCategoryHeader(category, cardColor, textColor),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  _buildProductGrid(context, categoryProducts[category] ?? []),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(
      String category, Color cardColor, Color textColor) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 8), // Reduced margin
      padding: EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended for Your Skin Type',
            style: GoogleFonts.montserrat(
              fontSize: 16, // Reduced font size
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 4), // Reduced spacing
          Text(
            _getCategoryDescription(category),
            style: GoogleFonts.montserrat(
              fontSize: 13, // Reduced font size
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(
      BuildContext context, List<Map<String, dynamic>> products) {
    // Further adjusted aspect ratio to prevent overflow
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58, // Further reduced from 0.65
        crossAxisSpacing: 12, // Reduced spacing
        mainAxisSpacing: 12, // Reduced spacing
      ),
      itemCount: products.length,
      itemBuilder: (context, index) =>
          _buildProductCard(context, products[index]),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => _showProductDetails(context, product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Further reduced image height
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                product['image'],
                height: 120, // Further reduced from 130
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['brand'],
                      style: GoogleFonts.montserrat(
                        fontSize: 11, // Reduced font size
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 2), // Reduced spacing
                    Text(
                      product['name'],
                      style: GoogleFonts.montserrat(
                        fontSize: 13, // Reduced font size
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1, // Limit to 1 line
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(), // Push price and rating to bottom
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product['price'],
                          style: GoogleFonts.montserrat(
                            fontSize: 14, // Reduced font size
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8E44AD),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star,
                                size: 14,
                                color: Colors.amber), // Reduced icon size
                            SizedBox(width: 2),
                            Text(
                              product['rating'].toString(),
                              style: GoogleFonts.montserrat(
                                  fontSize: 11), // Reduced font size
                            ),
                          ],
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

  void _showProductDetails(BuildContext context, Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.asset(
                    product['image'],
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    child: IconButton(
                      icon: Icon(Icons.favorite_border, color: Colors.white),
                      onPressed: () {
                        // Add to favorites functionality
                      },
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['brand'],
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      product['name'],
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product['price'],
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8E44AD),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              SizedBox(width: 4),
                              Text(
                                '${product['rating']}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Wrap(
                      spacing: 8,
                      children: (product['skinType'] as List<String>)
                          .map((type) => Chip(
                                label: Text(type),
                                backgroundColor: Color(0xFFF3E5F5),
                                labelStyle: GoogleFonts.montserrat(
                                  color: Color(0xFF8E44AD),
                                  fontSize: 12,
                                ),
                              ))
                          .toList(),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Description',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      product['description'],
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24),
                    _buildBenefitsList(product['benefits']),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF8E44AD)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove,
                                    color: Color(0xFF8E44AD)),
                                onPressed: () {
                                  // Decrease quantity
                                },
                              ),
                              Text(
                                '1',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add, color: Color(0xFF8E44AD)),
                                onPressed: () {
                                  // Increase quantity
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Add to cart functionality
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF8E44AD),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Add to Cart',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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

  Widget _buildBenefitsList(List<String> benefits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Benefits',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ...benefits
            .map((benefit) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Color(0xFF8E44AD), size: 20),
                      SizedBox(width: 12),
                      Text(
                        benefit,
                        style: GoogleFonts.montserrat(fontSize: 14),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Filter Products',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('Price Range'),
              _buildFilterOption('Skin Type'),
              _buildFilterOption('Brand'),
              _buildFilterOption('Rating'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Reset',
              style: GoogleFonts.montserrat(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8E44AD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Apply',
              style: GoogleFonts.montserrat(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String title) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.montserrat(),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Implement filter option selection
      },
    );
  }

  String _getCategoryDescription(String category) {
    switch (category) {
      case 'Foundation':
        return 'Find your perfect match with our range of foundations suited for your skin tone and type.';
      case 'Moisturizer':
        return 'Discover hydrating moisturizers that keep your skin nourished and healthy.';
      case 'Sunscreen':
        return 'Protect your skin with our selection of broad-spectrum sunscreens for daily use.';
      default:
        return 'Explore our carefully curated selection of skincare products.';
    }
  }
}
