import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class ReportsPanel extends StatelessWidget {
  const ReportsPanel({super.key});

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter'),
          content: const Text('Filter options will be here.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 234, 211),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 234, 211),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Statistics & Reports',
              style: GoogleFonts.dosis(
                color: const Color(0xFFF35000),
                fontSize: 22.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              icon: const Icon(Iconsax.filter5, color: Color(0xFFF35000)),
              onPressed: () {
                _showFilterDialog(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bar Chart Placeholder
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[300],
              child: Center(
                child: Text(
                  'Bar Chart Placeholder',
                  style: GoogleFonts.niramit(fontSize: 16.0, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            // Pie Chart Placeholder or Text Lines
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[300],
              child: Center(
                child: Text(
                  'Pie Chart / User Stats Placeholder',
                  style: GoogleFonts.niramit(fontSize: 16.0, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Text Lines for User Stats
            Text(
              'User Stats for the selected period:',
              style: GoogleFonts.niramit(fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              '• Foodies: XX',
              style: GoogleFonts.niramit(fontSize: 16.0, color: Colors.black),
            ),
            Text(
              '• Content Creators: XX',
              style: GoogleFonts.niramit(fontSize: 16.0, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
