import 'package:flutter/material.dart';
import 'package:jom_eat_project/models/restaurant_model.dart';
import 'package:jom_eat_project/services/database_service.dart';

class SelectRestaurantModal extends StatelessWidget {
  final Function(RestaurantModel) onSelect;
  final DataService _dataService = DataService();

  SelectRestaurantModal({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<RestaurantModel>>(
              stream: _dataService.getRestaurants(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No businesses found.'));
                }

                final restaurants = snapshot.data!;
                return ListView.builder(
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurants[index];
                    return ListTile(
                      title: Text(restaurant.name),
                      subtitle: Text(restaurant.location),
                      onTap: () => onSelect(restaurant),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
