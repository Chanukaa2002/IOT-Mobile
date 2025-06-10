import 'package:flutter/material.dart';
// Adjust this import path to point to your AppColors file
import 'package:cw_app/core/utils/app_colors.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // State variable to toggle password visibility
  bool _isPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Use SingleChildScrollView to prevent overflow on smaller screens
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top spacing - Further reduced
              const SizedBox(height: 40),

              // --- FORM FIELDS ---
              _buildTextField(
                label: "Name",
                hint: "Enter name",
                keyboardType: TextInputType.name,
              ),
              _buildTextField(
                label: "Email",
                hint: "Enter email",
                keyboardType: TextInputType.emailAddress,
              ),
              _buildPasswordTextField(),
              _buildTextField(
                label: "Weight (Kg)",
                hint: "Enter weight",
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                label: "Height (cm)",
                hint: "Enter height",
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                label: "Age",
                hint: "Enter age",
                keyboardType: TextInputType.number,
              ),

              // Spacing before button - Further reduced
              const SizedBox(height: 24),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Handle sign up logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Spacing after button - Further reduced
              const SizedBox(height: 20),

              // "OR SIGNUP WITH" Divider
              const Center(
                child: Text(
                  "OR SIGNUP WITH",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Google Login Button
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Handle Google sign up
                  },
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(14),
                    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: Image.asset('lib/core/assets/google.png', height: 28),
                ),
              ),

              // Spacing before bottom text - Further reduced
              const SizedBox(height: 20),

              // "Already have an account?" Text
              Center(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                    children: <TextSpan>[
                      const TextSpan(text: "Already have an account? "),
                      TextSpan(
                        text: 'Sign in',
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                        // recognizer: TapGestureRecognizer()..onTap = () {
                        //    TODO: Navigate back to Sign In page
                        // },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a standard text field to reduce code repetition
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5), // Further reduced
        TextField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            // Content padding - Further reduced to make field shorter
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
        ),
        // Spacing after field - Further reduced
        const SizedBox(height: 12),
      ],
    );
  }

  // Helper method specifically for the password field
  Widget _buildPasswordTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Password",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5), // Further reduced
        TextField(
          obscureText: _isPasswordObscured,
          decoration: InputDecoration(
            hintText: "Enter password",
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            // Content padding - Further reduced to make field shorter
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _isPasswordObscured = !_isPasswordObscured;
                });
              },
            ),
          ),
        ),
        // Spacing after field - Further reduced
        const SizedBox(height: 12),
      ],
    );
  }
}
