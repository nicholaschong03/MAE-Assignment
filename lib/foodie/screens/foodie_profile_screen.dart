import 'package:flutter/material.dart';
import 'package:jom_eat_project/foodie/widgets/profile_picture_widget.dart';
import 'package:jom_eat_project/foodie/widgets/progress_indicator_widget.dart';
import 'package:jom_eat_project/foodie/widgets/section_title_row.dart';
import 'package:jom_eat_project/foodie/widgets/badge_widget.dart';
import 'package:jom_eat_project/foodie/widgets/points_breakdown_widget.dart';
import 'package:jom_eat_project/models/foodie_model.dart';
import 'package:jom_eat_project/services/database_service.dart';
import 'dart:ui'; // Add this import


class FoodieProfileScreen extends StatefulWidget {
  const FoodieProfileScreen({super.key});

  @override
  State<FoodieProfileScreen> createState() => _FoodieProfileScreenState();
}

class _FoodieProfileScreenState extends State<FoodieProfileScreen> {
  bool darkMode = true;

  @override
  Widget build(BuildContext ) {
    final String userId = 'AZwrBrL0xBcNKOkdqdDBvBMWRyJ3'; // Replace with the actual user ID
    final DataService _databaseService = DataService();

    return Scaffold(
      body: FutureBuilder<FoodieModel>(
        future: _databaseService.getFoodie(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            print('User data not found.');
            return const Center(child: Text('User data not found.'));
          } else {
            FoodieModel user = snapshot.data!;
            print('User data: ${user.name}, ${user.email}, ${user.profileImage}');
            return _buildBody(user);
          }
        },
      ),
    );
  }

  Widget _buildBody(FoodieModel user) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.5,
              colors: [Color.fromARGB(255, 236, 163, 95), Color.fromARGB(255, 255, 102, 0)],
              stops: [0.1, 0.7],
            ),
          ),
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              _buildProfileSection(user),
              _buildAchievementsOverview(user),
              _buildPointsBreakdown(user),
              _buildMyBadges(user),
              const SliverToBoxAdapter(
                child: SizedBox(height: 64),
              ),
            ],
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(0.1),
      surfaceTintColor: Colors.white,
      title: Text(
        'My Profile',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildProfileSection(FoodieModel user) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ProfilePictureWidget(
                  imageUrl: user.profileImage.isNotEmpty ? user.profileImage : 'https://example.com/default_image.png',
                  width: 96,
                  height: 96,
                  borderRadius: 48,
                  borderColor: Colors.white.withOpacity(0.2),
                ),
              ),
              Container(
                width: 96,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 1.5,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.8),
                      Colors.white.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Lv23',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      ' · ',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      user.points.toString(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Foodie',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: darkMode ? Colors.white : Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: darkMode ? Colors.white : null,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                user.points.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: darkMode ? Colors.white : null,
                    ),
              ),
              Text(
                ' points',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: darkMode
                          ? Colors.white
                          : Theme.of(context).textTheme.titleMedium?.color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const ProgressIndicatorWidget(progressPercentage: 0.25),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lv ${user.level}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: darkMode
                            ? Colors.white
                            : Theme.of(context).textTheme.titleMedium?.color,
                      ),
                ),
                Text(
                  'Lv ${user.level + 1}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: darkMode
                            ? Colors.white
                            : Theme.of(context).textTheme.titleMedium?.color,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsOverview(FoodieModel user) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ).copyWith(top: 24),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        user.badgeCount.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: darkMode ? Colors.white : null,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Badges',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: darkMode
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        user.points.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: darkMode ? Colors.white : null,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Points',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: darkMode
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        user.level.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: darkMode ? Colors.white : null,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Levels',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: darkMode
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsBreakdown(FoodieModel user) {
    return PointsBreakdownWidget(darkMode: darkMode, points: user.outingParticipationPoint, engagementScore: user.engagementScore);
  }

  Widget _buildMyBadges(FoodieModel user) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Badges',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: darkMode ? Colors.white : null,
                  ),
            ),
            const SizedBox(height: 16),
            BadgeWidget(
              title: user.badgeTitle,
              imageUrl: user.badgeImage,
              darkMode: darkMode,
            ),
          ],
        ),
      ),
    );
  }
}
