import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_eat_project/adminfunction/user_manage.dart';
import 'package:jom_eat_project/adminfunction/event_manage.dart';

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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserManagementPage()),
                      );
                    },
                    child: Text('User Management',style: GoogleFonts.georama(
                      color: const Color(0xFFF88232),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  const EventManagePage()),
                      );
                    },
                    child: Text('Event Management',style: GoogleFonts.georama(
                      color: const Color(0xFFF88232),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),),
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
                  style: GoogleFonts.georama(
                      color: const Color(0xFFF88232),
                      fontSize: 22.0,
                      fontWeight: FontWeight.w500,
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
