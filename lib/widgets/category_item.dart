import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../screens/product_category_screen.dart';

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryItem({
    required this.icon,
    required this.label,
  });

  // List<Map<String, dynamic>> _getDummyProducts() {
  //   switch (label.toLowerCase()) {
  //     case 'foundation':
  //       return [
  //         {
  //           'name': 'Luminous Silk Foundation',
  //           'description': 'Lightweight, buildable coverage for a natural glow',
  //           'image': 'assets/images/foundation1.png',
  //           'rating': 4.8,
  //         },
  //         {
  //           'name': 'Double Wear Foundation',
  //           'description': 'Long-lasting, flawless coverage for all day wear',
  //           'image': 'assets/images/foundation2.png',
  //           'rating': 4.9,
  //         },
  //         {
  //           'name': 'Fit Me Matte Foundation',
  //           'description': 'Oil-free formula for a natural matte finish',
  //           'image': 'assets/images/foundation3.png',
  //           'rating': 4.5,
  //         },
  //         {
  //           'name': 'Born This Way Foundation',
  //           'description': 'Medium to full coverage with skincare benefits',
  //           'image': 'assets/images/foundation4.png',
  //           'rating': 4.7,
  //         },
  //       ];
  //     case 'moisturizer':
  //       return [
  //         {
  //           'name': 'Hydro Boost Gel-Cream',
  //           'description': 'Oil-free hydration for smooth, supple skin',
  //           'image': 'assets/images/moisturizer1.png',
  //           'rating': 4.7,
  //         },
  //         {
  //           'name': 'Ceramidin Cream',
  //           'description': 'Rich moisturizer with ceramides for barrier repair',
  //           'image': 'assets/images/moisturizer2.png',
  //           'rating': 4.8,
  //         },
  //         {
  //           'name': 'Ultra Facial Cream',
  //           'description': '24-hour hydration for all skin types',
  //           'image': 'assets/images/moisturizer3.png',
  //           'rating': 4.6,
  //         },
  //         {
  //           'name': 'Water Cream',
  //           'description': 'Lightweight, oil-free moisturizer for pore refinement',
  //           'image': 'assets/images/moisturizer4.png',
  //           'rating': 4.9,
  //         },
  //       ];
  //     case 'sunscreen':
  //       return [
  //         {
  //           'name': 'UV Clear Facial SPF 46',
  //           'description': 'Lightweight protection for sensitive skin',
  //           'image': 'assets/images/sunscreen1.png',
  //           'rating': 4.8,
  //         },
  //         {
  //           'name': 'Invisible Shield SPF 35',
  //           'description': 'Clear gel sunscreen with antioxidants',
  //           'image': 'assets/images/sunscreen2.png',
  //           'rating': 4.7,
  //         },
  //         {
  //           'name': 'Ultra Light Daily UV Defense',
  //           'description': 'Daily protection with anti-aging benefits',
  //           'image': 'assets/images/sunscreen3.png',
  //           'rating': 4.6,
  //         },
  //         {
  //           'name': 'Unseen Sunscreen SPF 40',
  //           'description': 'Universal invisible protection for all skin tones',
  //           'image': 'assets/images/sunscreen4.png',
  //           'rating': 4.9,
  //         },
  //       ];
  //     default:
  //       return [];
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductCategoryScreen(
              category: label,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.purple.shade800,
              size: 24,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
