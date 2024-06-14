// outing_profile_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:jom_eat_project/foodie/widgets/profile_picture_widget.dart';
import 'package:jom_eat_project/foodie/widgets/menu_item_rating.dart';
import 'package:jom_eat_project/foodie/widgets/profile_picture_widget.dart';
import 'package:jom_eat_project/models/outing_group_model.dart';
import 'package:jom_eat_project/models/user_model.dart';
import 'package:jom_eat_project/services/database_service.dart';
import 'package:jom_eat_project/foodie/widgets/swipe_to_join_outing_widget.dart';

class OutingProfileScreen extends StatefulWidget {
  final String outingId;

  const OutingProfileScreen({super.key, required this.outingId});

  @override
  State<OutingProfileScreen> createState() => _OutingProfileScreenState();
}

class _OutingProfileScreenState extends State<OutingProfileScreen> {
  bool userIsJoining = false;
  bool isSwipeWidgetVisible =
      true; // Track visibility of SwipeToJoinOutingWidget
  Key swipeWidgetKey = UniqueKey(); // Key to force rebuild

  void _cancelRegistration() {
    setState(() {
      userIsJoining = false;
      isSwipeWidgetVisible = true; // Make the widget visible again
      swipeWidgetKey = UniqueKey(); // Generate a new key to rebuild the widget
    });
  }

  @override
  Widget build(BuildContext context) {
    final DataService databaseService = DataService();

    return Scaffold(
      body: FutureBuilder<OutingGroupModel>(
        future: databaseService.getOuting(widget.outingId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Outing data not found.'));
          } else {
            OutingGroupModel outing = snapshot.data!;
            return _buildBody(outing);
          }
        },
      ),
    );
  }

  Widget _buildBody(OutingGroupModel outing) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildBusinessPhotoSlider(
                businessPhotoUrls: outing.restaurantPhotos),
            _buildOutingBasicDetails(outing: outing),
            if (userIsJoining == true) _buildCancelJoin(),
            if (outing.members.isNotEmpty)
              _buildJoiningAttendees(userProfiles: outing.members),
          ],
        ),
        Visibility(
          visible: isSwipeWidgetVisible,
          child: AnimatedOpacity(
            opacity: userIsJoining ? 0.0 : 1.0,
            duration: const Duration(seconds: 3),
            curve: Curves.easeInExpo,
            onEnd: () {
              if (userIsJoining) {
                setState(() {
                  isSwipeWidgetVisible = false;
                });
              }
            },
            child: SwipeToJoinOutingWidget(
              key: swipeWidgetKey,
              onRegistrationComplete: () {
                setState(() {
                  userIsJoining = true;
                });
              },
            ),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(
        'Outing Details',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildBusinessPhotoSlider({required List<String> businessPhotoUrls}) {
    double cardWidth = MediaQuery.of(context).size.width - 32;
    double cardHeight = cardWidth * 3 / 4;

    return SliverToBoxAdapter(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: businessPhotoUrls.length <= 1 ? (cardHeight + 24) : cardHeight,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: businessPhotoUrls.length,
          padding: EdgeInsets.symmetric(
              horizontal: businessPhotoUrls.length <= 1 ? 16 : 8),
          itemBuilder: (context, index) {
            return Padding(
              padding: businessPhotoUrls.length <= 1
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 8),
              child: AspectRatio(
                aspectRatio: 4.0 / 3.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    child: Image.network(
                      businessPhotoUrls[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        return progress == null
                            ? child
                            : Container(
                                color: Theme.of(context).shadowColor,
                                child: Center(
                                    child: CircularProgressIndicator(
                                        value: progress.expectedTotalBytes !=
                                                null
                                            ? progress.cumulativeBytesLoaded /
                                                (progress.expectedTotalBytes ??
                                                    1)
                                            : null)),
                              );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Theme.of(context).shadowColor),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOutingBasicDetails({required OutingGroupModel outing}) {
    double businessProfilePictureSize = 64;
    double businessProfilePictureRadius = businessProfilePictureSize / 2;
    double iconSize = 20;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Business Profile Picture
                ProfilePictureWidget(
                  height: businessProfilePictureSize,
                  width: businessProfilePictureSize,
                  borderRadius: businessProfilePictureRadius,
                  imageUrl: '', // outing.restaurantPhotos[0],
                  borderColor: Theme.of(context).scaffoldBackgroundColor,
                ),

                // Distance between Business's Profile Picture and Business's Name
                const SizedBox(width: 12),

                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Business Name
                      Text(
                        outing.restaurantName,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.calendar_month_outlined, size: iconSize),
                const SizedBox(width: 8),
                Text(outing.date.toString()),
              ],
            ),
            const SizedBox(height: 8),

            // Time
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.access_time_rounded, size: iconSize),
                const SizedBox(width: 8),
                Text('${outing.startTime} - ${outing.endTime}'),
              ],
            ),
            const SizedBox(height: 8),

            // Location
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, size: iconSize),
                const SizedBox(width: 8),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      outing.location,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Maximum Participants
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.group_outlined, size: iconSize),
                const SizedBox(width: 8),
                const Expanded(child: Text('Max. 20 participants')),
                Text(
                  'Invite Friends',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelJoin() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0)
            .copyWith(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Text(
                  'You\'re joining this outing!',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: Colors.green),
                ),
              ),
            ),
            GestureDetector(
              onTap: _cancelRegistration,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                alignment: Alignment.center,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16 - 4),
                ),
                child: Text(
                  'Cancel Join?',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.red, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoiningAttendees({required List<UserModel> userProfiles}) {
    const double profilePictureSize = 36;
    const double profilePictureStackPadding = profilePictureSize * 0.7;

    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          // Navigate to outing attendees screen
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Stack(
                children: [
                  if (userProfiles.length >= 3)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 2 * profilePictureStackPadding),
                      child: ProfilePictureWidget(
                        imageUrl: userProfiles[2].profileImage,
                        width: profilePictureSize,
                        height: profilePictureSize,
                        borderRadius: profilePictureSize,
                        borderColor: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                  if (userProfiles.length >= 2)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: profilePictureStackPadding),
                      child: ProfilePictureWidget(
                        imageUrl: userProfiles[1].profileImage,
                        width: profilePictureSize,
                        height: profilePictureSize,
                        borderRadius: profilePictureSize,
                        borderColor: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                  if (userProfiles.isNotEmpty)
                    ProfilePictureWidget(
                      imageUrl: userProfiles[0].profileImage,
                      width: profilePictureSize,
                      height: profilePictureSize,
                      borderRadius: profilePictureSize,
                      borderColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                ],
              ),
              const SizedBox(width: 8),

              // Name
              if (userProfiles.length == 1)
                Flexible(
                  child: RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        const TextSpan(text: 'Joined by '),
                        TextSpan(
                          text: userProfiles[0].name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                )
              else if (userProfiles.length == 2)
                Flexible(
                  child: RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        const TextSpan(text: 'Joined by '),
                        TextSpan(
                          text: userProfiles[0].name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: userProfiles[1].name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                )
              else if (userProfiles.length >= 3)
                Flexible(
                  child: RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        const TextSpan(text: 'Joined by '),
                        TextSpan(
                          text: userProfiles[0].name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const TextSpan(text: ', '),
                        TextSpan(
                          text: userProfiles[1].name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'others',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
