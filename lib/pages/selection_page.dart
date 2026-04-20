import 'package:flutter/material.dart';
import 'about_page.dart';
import './signup_page.dart';
import 'user_home_premium.dart';
import './user/user_home.dart';

class SelectionPage extends StatefulWidget {
  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage>
    with SingleTickerProviderStateMixin {
  final Color blackColor = Colors.black;
  final Color lightPeach = const Color(0xFFFFE5B4);
  final Color babyPink = const Color(0xFFFFC0CB);
  final Color lightBlue = const Color(0xFFB3E5FC);

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showPremiumLoginPage() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) {
          return Center(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _controller,
                curve: Curves.easeOut,
              )),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(parent: _controller, curve: Curves.easeOutBack)),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 380,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: lightPeach,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.workspace_premium,
                            size: 48, color: Colors.amber),
                        const SizedBox(height: 12),
                        const Text(
                          'Premium Member Login ✨',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Unlock exclusive features and enjoy!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () {
                              final email = emailController.text.trim();
                              final password = passwordController.text.trim();
                              if (email == 'ammasajid@gmail.com' &&
                                  password == 'aeman123') {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const UserHomePagePremium()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Invalid credentials!'),
                                      duration: Duration(seconds: 1)),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: blackColor),
                            child: const Text('Login'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPeach,
      appBar: AppBar(
        backgroundColor: blackColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '🍴 Bite Book',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: ScaleTransition(
              scale: _scale,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.fastfood,
                            size: 56, color: Colors.black),
                        const SizedBox(height: 16),
                        const Text(
                          'Welcome to Bite Book',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Select how you want to continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 28),

                        // Admin
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.admin_panel_settings),
                            label: const Text('Admin Portal 🛠️'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: blackColor),
                            onPressed: () =>
                                Navigator.pushNamed(context, '/admin_login'),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Premium
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.workspace_premium),
                            label: const Text(
                                'Premium Member 👑 - Unlock Exclusive'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: blackColor,
                              side: BorderSide(color: babyPink, width: 2),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _showPremiumLoginPage,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Guest
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.lock),
                            label: const Text('Guest Access 🎭 - Quick Entry'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: blackColor,
                              side: BorderSide(color: lightBlue, width: 2),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const UserHomePage()),
                              );
                            },
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
      ),
    );
  }
}
