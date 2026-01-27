import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('CONTACT US'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: const Text(
                'GET IN\nTOUCH',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: const Text('Have questions? We are here to help you style your life.'),
            ),
            const SizedBox(height: 50),
            _contactTile(FontAwesomeIcons.instagram, 'INSTAGRAM', '@KHIN.SZN'),
            _contactTile(Icons.email_outlined, 'EMAIL', 'HELLO@NOVAWEAR.TECH'),
            _contactTile(Icons.phone_outlined, 'PHONE', '+254 7XX XXX XXX'),
            _contactTile(Icons.location_on_outlined, 'OFFICE', 'MOMBASA, KENYA'),
            const SizedBox(height: 50),
            const Text(
              'CUSTOMER SERVICE HOURS:',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12),
            ),
            const SizedBox(height: 10),
            const Text('MON - FRI: 9AM - 6PM', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('SAT: 10AM - 4PM', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _contactTile(IconData icon, String label, String value) {
    return FadeInUp(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: Row(
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 25),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, color: Colors.grey)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
