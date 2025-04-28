import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  String selectedRole = 'Applicant';
  final List<String> roles = ['Applicant', 'Employer', 'Admin'];

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _handleAuth() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final email = selectedRole == 'Admin'
        ? '${emailController.text.trim()}@admin.careernest.com'
        : emailController.text.trim();
    final password = passwordController.text.trim();
    String? error;
    if (isLogin) {
      error = await AuthService.login(email: email, password: password, role: selectedRole);
    } else {
      error = await AuthService.signUp(email: email, password: password, role: selectedRole, name: nameController.text.trim());
    }
    setState(() => _loading = false);
    if (error != null) {
      setState(() => _error = error);
    } else {
      // On success, navigate to dashboard
      String route = '/applicant';
      if (selectedRole == 'Employer') route = '/employer';
      if (selectedRole == 'Admin') route = '/admin';
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Tabs for Login/Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _tabButton('Login', isLogin, () {
                        setState(() => isLogin = true);
                      }),
                      const SizedBox(width: 16),
                      _tabButton('Sign Up', !isLogin, () {
                        setState(() => isLogin = false);
                      }),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Role selection
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF0A1931), width: 1.2),
                    ),
                    child: DropdownButton<String>(
                      value: selectedRole,
                      underline: const SizedBox(),
                      borderRadius: BorderRadius.circular(12),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0A1931)),
                      style: const TextStyle(
                        color: Color(0xFF0A1931),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                      ),
                      items: roles.map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedRole = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Name field (Sign Up only)
                  if (!isLogin)
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Name', style: _labelStyle),
                        ),
                        const SizedBox(height: 6),
                        _inputField(nameController, 'Enter your name'),
                        const SizedBox(height: 18),
                      ],
                    ),
                  // Email field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(selectedRole == 'Admin' ? 'Username' : 'Email', style: _labelStyle),
                  ),
                  const SizedBox(height: 6),
                  _inputField(emailController, selectedRole == 'Admin' ? 'Enter your username' : 'Enter your email'),
                  const SizedBox(height: 18),
                  // Password field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Password', style: _labelStyle),
                  ),
                  const SizedBox(height: 6),
                  _inputField(passwordController, 'Enter your password', isPassword: true),
                  const SizedBox(height: 24),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(_error!, style: const TextStyle(color: Colors.red, fontFamily: 'Montserrat')),
                    ),
                  // Login/Sign Up button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _handleAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A1931),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18, fontFamily: 'Montserrat'),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(isLogin ? 'Login' : 'Sign Up'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0A1931) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFF0A1931), width: 1.5),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0A1931).withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF0A1931),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String hint, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF7F9FC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0A1931)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0A1931)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0A1931), width: 2),
        ),
      ),
      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16),
    );
  }

  TextStyle get _labelStyle => const TextStyle(
        fontWeight: FontWeight.w600,
        fontFamily: 'Montserrat',
        fontSize: 15,
        color: Color(0xFF0A1931),
      );
} 