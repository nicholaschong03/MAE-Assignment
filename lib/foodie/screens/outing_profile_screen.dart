import 'package:flutter/material.dart';
import 'package:jom_eat_project/foodie/screens/foodie_profile_screen.dart';
import 'package:jom_eat_project/foodie/widgets/image_display_widget.dart';
import 'package:jom_eat_project/foodie/widgets/profile_picture_widget.dart';
import 'package:jom_eat_project/foodie/widgets/outing_scree_widget/swipe_to_join_outing_widget.dart';
import 'package:jom_eat_project/models/outing_group_model.dart';
import 'package:jom_eat_project/models/user_model.dart';
import 'package:jom_eat_project/services/database_service.dart';

class OutingProfileScreen extends StatefulWidget {
  final String outingId;
  final String userId;

  const OutingProfileScreen(
      {super.key, required this.outingId, required this.userId});

  @override
  State<OutingProfileScreen> createState() => _OutingProfileScreenState();
}

class _OutingProfileScreenState extends State<OutingProfileScreen> {
  bool memberIsJoining = false;
  bool isSwipeWidgetVisible =
      true; // Track visibility of SwipeToJoinOutingWidget
  Key swipeWidgetKey = UniqueKey(); //
  final DataService databaseService = DataService();

  @override
  void initState() {
    super.initState();
    _checkMembershipStatus();
  }

  Future<void> _checkMembershipStatus() async {
    try {
      OutingGroupModel outing =
          await databaseService.getOuting(widget.outingId);
      if (outing.isUserMember(widget.userId)) {
        setState(() {
          memberIsJoining = true;
          isSwipeWidgetVisible = false;
        });
      }
    } catch (e) {
      print("Error checking membership status: $e");
    }
  }

  void _cancelRegistration() async {
    try {
      await databaseService.cancelOuting(widget.outingId, widget.userId);
      setState(() {
        memberIsJoining = false;
        isSwipeWidgetVisible = true; // Make the widget visible again
        swipeWidgetKey =
            UniqueKey(); // Generate a new key to rebuild the widget
      });
    } catch (e) {
      print("Error cancelling outing: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
            print("Outing Data: $outing");
            return _buildBody(outing);
          }
        },
      ),
    );
  }

  _buildBody(OutingGroupModel outing) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildBusinessPhotoSlider(
                businessPhotoUrls: outing.restaurant!.photos),
            _buildOutingBasicDetails(outing),
            if (memberIsJoining == true) _buildCancelJoin(),
            if (outing.members.isNotEmpty)
              _buildJoiningAttendees(members: outing.members),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
        Visibility(
          visible: isSwipeWidgetVisible,
          child: AnimatedOpacity(
            opacity: memberIsJoining ? 0.0 : 1.0,
            duration: const Duration(seconds: 3),
            curve: Curves.easeInExpo,
            onEnd: () {
              if (memberIsJoining) {
                setState(() {
                  isSwipeWidgetVisible = false;
                });
              }
            },
            child: SwipeToJoinOutingWidget(
              key: swipeWidgetKey,
              onRegistrationComplete: () {
                setState(() {
                  memberIsJoining = true;
                });
              },
              outingId: widget.outingId,
              userId: widget.userId,
            ),
          ),
        ),
      ],
    );
  }

  _buildAppBar() {
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

  Widget _buildBusinessPhotoSlider({required List businessPhotoUrls}) {
    double cardWidth = MediaQuery.of(context).size.width - (4 * 16);
    double cardHeight = cardWidth * 3 / 4;
    double cardPadding = 8;

    return SliverToBoxAdapter(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: businessPhotoUrls.length <= 1
            ? (cardHeight + (3 * cardPadding))
            : cardHeight,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: businessPhotoUrls.length,
          padding: EdgeInsets.symmetric(
            horizontal: businessPhotoUrls.length <= 1 ? 16 : 16 - cardPadding,
          ),
          itemBuilder: (context, index) {
            return Padding(
              padding: businessPhotoUrls.length <= 1
                  ? const EdgeInsets.symmetric(horizontal: 0)
                  : EdgeInsets.symmetric(horizontal: cardPadding),
              child: AspectRatio(
                aspectRatio: 4.0 / 3.0,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    child: Image.network(businessPhotoUrls[index],
                        fit: BoxFit.fill),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOutingBasicDetails(OutingGroupModel outing) {
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
                // Display business logo using Image widget
                Container(
                  width: businessProfilePictureSize,
                  height: businessProfilePictureSize,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(businessProfilePictureRadius),
                    image: DecorationImage(
                      image: NetworkImage(outing.restaurant.logo),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Distance between Business's Profile Picture and Business's Name
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Business Name
                      Text(
                        outing.restaurant!.name,
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

            // Organizer
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ImageDisplayWidget(
                    width: 24,
                    height: 24,
                    pixelRatio: 1,
                    imageUrl: outing.createdByUser.profileImage,
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(width: 8),
                Expanded(
                    child: Text('Organized by ${outing.createdByUser.name}')),
              ],
            ),
            const SizedBox(height: 8),

            // Date
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.calendar_month_outlined, size: iconSize),
                const SizedBox(width: 8),
                Text(formatDate(outing.date).toString()),
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
                      outing.restaurant!.location,
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
                Expanded(child: Text('Max. ${outing.maxMembers} participants')),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.food_bank, size: iconSize),
                const SizedBox(width: 8),
                Expanded(child: Text('Max. ${outing.description}')),
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
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 0,
        ).copyWith(
          bottom: 8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                child: Text(
                  'You\'re joining this outing!',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.green,
                      ),
                ),
              ),
            ),
            GestureDetector(
              onTap: _cancelRegistration,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                alignment: Alignment.center,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16 - 4),
                ),
                child: Text(
                  'Cancel Join?',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoiningAttendees({required List<UserModel> members}) {
    const double profilePictureSize = 36;
    const double profilePictureStackPadding = profilePictureSize * 0.7;

    return SliverToBoxAdapter(
      child: GestureDetector(
        // onTap: () => GoRouter.of(context).pushNamed(
        //   Routes.outingAttendees,
        //   pathParameters: {
        //     'outingId': 'widget.outingId',
        //   },
        // ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Stack(
                children: List.generate(
                  members.length,
                  (index) {
                    if (index < 3) {
                      return Padding(
                        padding: EdgeInsets.only(
                            left: index * profilePictureStackPadding),
                        child: ProfilePictureWidget(
                          imageUrl: members[index].profileImage,
                          width: profilePictureSize,
                          height: profilePictureSize,
                          borderRadius: profilePictureSize,
                          borderColor:
                              Theme.of(context).scaffoldBackgroundColor,
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: _buildMembersText(members),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TextSpan> _buildMembersText(List<UserModel> members) {
    List<TextSpan> textSpans = [const TextSpan(text: 'Joined by ')];
    if (members.isNotEmpty) {
      textSpans.add(TextSpan(
        text: members[0].username,
        style: Theme.of(context).textTheme.titleSmall,
      ));
    }
    if (members.length > 1) {
      textSpans.add(const TextSpan(text: ' and '));
      textSpans.add(TextSpan(
        text: members[1].username,
        style: Theme.of(context).textTheme.titleSmall,
      ));
    }
    if (members.length > 2) {
      textSpans.add(const TextSpan(text: ' and '));
      textSpans.add(TextSpan(
        text: '${members.length - 2} others',
        style: Theme.of(context).textTheme.titleSmall,
      ));
    }
    return textSpans;
  }
}
