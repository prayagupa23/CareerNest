import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              const Text(
                'CareerNest',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A1931),
                  fontFamily: 'Montserrat',
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _circleAvatar('https://randomuser.me/api/portraits/men/32.jpg'),
                  const SizedBox(width: 12),
                  _circleAvatar('https://randomuser.me/api/portraits/women/44.jpg'),
                  const SizedBox(width: 12),
                  _circleAvatar('https://randomuser.me/api/portraits/men/65.jpg'),
                  const SizedBox(width: 12),
                  _circleAvatar('https://randomuser.me/api/portraits/women/68.jpg'),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Find More Jobs Easier Than You Ever Imagined',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF22223B),
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Get personalized job recommendations, connect with top employers, and land your dream job faster than ever.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A1931),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(fontSize: 18, fontFamily: 'Montserrat'),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _circleAvatar(String url) {
    return CircleAvatar(
      radius: 32,
      backgroundColor: const Color(0xFFE9ECF5),
      backgroundImage: NetworkImage(url),
    );
  }
} 