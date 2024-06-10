import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePanel extends StatelessWidget {
  const HomePanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16), // Set the common edge spacing
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add your button 1 logic here
                    },
                    child: const Text('User Management'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Add your button 2 logic here
                    },
                    child: const Text('Event Management'),
                  ),
                ],
              ),
              const SizedBox(
                  height:
                      16.0), // Add some spacing between the buttons and the text
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent Posts',
                  style: GoogleFonts.nunitoSans(
                    color: const Color(0xFFF88232),
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Expanded(
          child: SingleChildScrollView(
            child: Column(
                // Add your content here
                ),
          ),
        ),
      ],
    );
  }
}
