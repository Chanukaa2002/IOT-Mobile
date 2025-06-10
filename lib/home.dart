import 'package:flutter/material.dart';
import 'package:cw_app/core/utils/app_colors.dart'; // Make sure this import path is correct

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: <Widget>[
          // 1. Top "EATRO" Image
          Positioned(
            top: screenHeight * 0.1, // Position from top
            left: 0,
            right: 0,
            child: Image.asset(
              'lib/core/assets/app_name.png',
              height: 150, // Made the image larger
            ),
          ),

          // 2. The custom-shaped blue background
          ClipPath(
            clipper: WaveClipper(), // Using a custom clipper for the curve
            child: Container(
              color: AppColors.primaryBlue,
              height: screenHeight,
              width: screenWidth,
            ),
          ),

          // 3. The content on top of the blue background
          Positioned(
            top: screenHeight * 0.50, // Start content below the curve
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align content to the left
                children: [
                  // Logo inside a white circle
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'lib/core/assets/logo.png',
                      height: 40, // Adjust size as needed
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title Text
                  const Text(
                    "Let's set your food\nhabit today with us!",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                      height: 1.3, // Line height
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. The Continue Button at the very bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity, // Make button span full width
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement continue action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// CustomClipper class to create the wave/curve shape
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Defines the path for the custom curve
    var path = Path();
    // Start from a point before the screen to create the curve effect
    path.moveTo(0, size.height * 0.4);
    // Defines the curve using a quadratic Bezier curve
    path.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.60,
      size.width,
      size.height * 0.45,
    );
    // Lines to the bottom corners to fill the rest of the screen
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close(); // Close the path to form a shape
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // Should not reclip, as the path is static
    return false;
  }
}
