import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cw_app/core/utils/app_colors.dart';
import 'package:cw_app/features/auth/services/auth_service.dart';
import 'package:cw_app/features/client/widget/nav_widget.dart';
import 'package:cw_app/features/auth/pages/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isPasswordObscured = true;
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  late TapGestureRecognizer _signInRecognizer;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _signInRecognizer =
        TapGestureRecognizer()
          ..onTap = () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          };
  }

  @override
  void dispose() {
    // Dispose all controllers and the recognizer to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _signInRecognizer.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    // Basic validation
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name, Email, and Password cannot be empty."),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService
          .signUpWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            name: _nameController.text.trim(),
            weight: int.tryParse(_weightController.text.trim()) ?? 0,
            height: int.tryParse(_heightController.text.trim()) ?? 0,
            age: int.tryParse(_ageController.text.trim()) ?? 0,
          )
          .timeout(
            const Duration(seconds: 45),
          );

      if (user != null) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const NavWidget()),
          );
        }
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Connection timed out. Please check your internet and try again.",
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              _buildTextField(
                label: "Name",
                hint: "Enter name",
                controller: _nameController,
                keyboardType: TextInputType.name,
              ),
              _buildTextField(
                label: "Email",
                hint: "Enter email",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildPasswordTextField(),
              _buildTextField(
                label: "Weight (Kg)",
                hint: "Enter weight",
                controller: _weightController,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                label: "Height (cm)",
                hint: "Enter height",
                controller: _heightController,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                label: "Age",
                hint: "Enter age",
                controller: _ageController,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                          : const Text(
                            "Sign up",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
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
                        recognizer: _signInRecognizer,
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextInputType keyboardType,
    required TextEditingController controller,
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
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

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
        const SizedBox(height: 5),
        TextField(
          controller: _passwordController,
          obscureText: _isPasswordObscured,
          decoration: InputDecoration(
            hintText: "Enter password",
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
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
        const SizedBox(height: 12),
      ],
    );
  }
}
