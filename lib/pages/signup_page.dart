import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // New Controller

  bool _isLoading = false;

  void _signup() {
    if (!_formKey.currentState!.validate()) return;

    // Additional check for password match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate network delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      // In a real app, you would handle successful sign-up here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup successful for ${_emailController.text}!'),
        ),
      );
      // Navigate to the profile page
      Navigator.pushNamed(context, '/profile');
    });
  }

  // Helper method for common TextFormField style
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    const Color black = Colors.black;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        // Hint text styling to mimic a clean web form
        labelStyle: const TextStyle(color: black),
        prefixIcon: Icon(icon, color: black.withOpacity(0.7)),
        // Clean, slightly rounded border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        // Focused border for better user experience
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: black, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color black = Colors.black;
    const Color lightPeach = Color(0xFFFFE5B4);
    // Removed babyPink as it wasn't used

    // Define max width for web-friendly centered layout
    const double maxFormWidth = 400;

    return Scaffold(
      // Background color kept as requested
      backgroundColor: lightPeach,
      // AppBar kept as requested
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'User Signup',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center( // Center widget for web-friendly layout
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: maxFormWidth, // Constrain width for a compact, centered look
            child: Card(
              color: Colors.white,
              elevation: 10, // Increased elevation for a more polished look
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: black.withOpacity(0.1), width: 1), // Subtle border
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0), // Increased padding
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Use minimum space
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch fields
                    children: [
                      // Form Title
                      const Text(
                        'Join Our Community', // Updated title
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 28, // Larger title
                            fontWeight: FontWeight.w600,
                            color: black),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle/Instruction
                      const Text(
                        'Create an account to get started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey),
                      ),
                      const SizedBox(height: 30),

                      // Full Name Field (Using helper)
                      _buildTextFormField(
                        controller: _nameController,
                        labelText: 'Username or Full Name',
                        icon: Icons.person,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your name or username' : null,
                      ),
                      const SizedBox(height: 16),

                      // Email Field (Using helper)
                      _buildTextFormField(
                        controller: _emailController,
                        labelText: 'Email Address',
                        icon: Icons.email,
                        validator: (value) =>
                            value!.contains('@') && value.contains('.') ? null : 'Enter a valid email address',
                      ),
                      const SizedBox(height: 16),

                      // Password Field (Using helper)
                      _buildTextFormField(
                        controller: _passwordController,
                        labelText: 'Password',
                        icon: Icons.lock,
                        obscureText: true,
                        validator: (value) => value!.length < 8 // Stronger password minimum
                            ? 'Password must be at least 8 characters'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field (New)
                      _buildTextFormField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirm Password',
                        icon: Icons.check_circle_outline,
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please confirm your password';
                          } else if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      // Signup Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: black, // Solid black button
                          disabledBackgroundColor: black.withOpacity(0.6), // Disabled color
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Less rounded corners
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'Create Account', // Updated button text
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                      const SizedBox(height: 20),

                      // 'Go to Profile' TextButton
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/profile'),
                        style: TextButton.styleFrom(
                          foregroundColor: black,
                        ),
                        child: Text(
                          'Already have an account? Sign In',
                          style: TextStyle(
                              color: black.withOpacity(0.8),
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}