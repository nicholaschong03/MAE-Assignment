import 'package:flutter/material.dart';
import 'package:jom_eat_project/foodie/screens/my_outing_screen.dart';
import 'package:jom_eat_project/services/database_service.dart';
import 'package:jom_eat_project/foodie/widgets/home_screen_widget/promotion_card.dart';
import 'package:jom_eat_project/models/outing_group_model.dart';
import 'package:jom_eat_project/models/promotion_model.dart';
import 'package:jom_eat_project/models/foodie_model.dart';
import 'package:jom_eat_project/foodie/screens/outing_profile_screen.dart';
import 'package:jom_eat_project/foodie/widgets/home_screen_widget/discover_group_card.dart';
import 'package:jom_eat_project/foodie/widgets/home_screen_widget/popular_outing_card.dart';
import 'package:jom_eat_project/foodie/widgets/section_title_row.dart';

class FoodieHomeScreen extends StatefulWidget {
  final String userId;

  const FoodieHomeScreen({super.key, required this.userId});

  @override
  State<FoodieHomeScreen> createState() => _FoodieHomeScreenState();
}

class _FoodieHomeScreenState extends State<FoodieHomeScreen> {
  final DataService _dataService = DataService();

  late Future<FoodieModel> _foodieFuture;

  @override
  void initState() {
    super.initState();
    _foodieFuture = _dataService.getFoodie(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<FoodieModel>(
        future: _foodieFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('User data not found.'));
          } else {
            FoodieModel foodie = snapshot.data!;
            return _buildAppBar(context, foodie);
          }
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, FoodieModel foodie) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            surfaceTintColor: Colors.transparent,
            expandedHeight: 160,
            floating: false,
            pinned: true,
            title: Text(
              'Foodie Home Dashboard',
              style: Theme.of(context).textTheme.titleLarge,
            ),
                    actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyOutingsScreen(userId: widget.userId),
                ),
              );
            },
          ),
        ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade200, Colors.yellow.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        const Color.fromRGBO(242, 244, 249, 1).withOpacity(1),
                        const Color.fromRGBO(255, 155, 104, 1)
                            .withOpacity(0.5),
                      ],
                      center: const Alignment(0.1, 1.0),
                      radius: 5,
                      focalRadius: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 64,
                              width: 64,
                              decoration: BoxDecoration(
                                color:
                                    const Color.fromRGBO(242, 244, 249, 1),
                                borderRadius: BorderRadius.circular(64),
                              ),
                              padding: const EdgeInsets.all(2),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(82),
                                child: Image.network(
                                  foodie.profileImage,
                                  height: 62,
                                  width: 62,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return Image.asset(
                                      'assets/images/profile.jpg',
                                      fit: BoxFit.cover,
                                      height: 62,
                                      width: 62,
                                    );
                                  },
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          Image.asset(
                                              'assets/images/profile.jpg',
                                              fit: BoxFit.cover,
                                              height: 62,
                                              width: 62),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Hi ${foodie.name}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _membershipStatus(
                                        context, foodie.membershipStatus),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${foodie.points} Points',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: const Color.fromARGB(
                                                255, 243, 132, 42),
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ];
      },
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOutingSection(context),
          _buildPromotionSection(context),
          _buildPopularOutingSection(context),
        ],
      ),
    );
  }

  Widget _buildOutingSection(BuildContext context) {
    return StreamBuilder<List<OutingGroupModel>>(
      stream: _dataService.getTodayDiningGroups(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No outings found.'));
        } else {
          var outings = snapshot.data!;
          double imageAspectRatio = 16 / 9;

          // View
          double viewWidth = MediaQuery.of(context).size.width;
          double viewHorizontalPadding = 2;
          double viewVerticalPadding = 16;
          // Card
          double showCardAmount = 2.2;
          double cardHorizontalMargin = 8;
          double cardWidth = (viewWidth -
                  (2 * viewHorizontalPadding) -
                  (showCardAmount.floor() * (2 * cardHorizontalMargin))) /
              showCardAmount;
          // Card Height: Image + Name + Rating + (Halal Label / Cuisine Type) + Influencer Name + Safety Margin
          double cardHeight = (cardWidth / imageAspectRatio) +
              (8 + 14) +
              (4 + 12) +
              (4 + 14) +
              (8 + 14) +
              4;
          double cardBorderRadius = 12;
          // View Height
          double viewHeight = cardHeight + (2 * viewVerticalPadding);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitleRow(title: "Today's Outings"),
              SizedBox(
                width: viewWidth,
                height: viewHeight,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: outings.length,
                  padding: EdgeInsets.symmetric(
                    horizontal: viewHorizontalPadding,
                    vertical: viewVerticalPadding,
                  ),
                  itemBuilder: (context, index) {
                    var outing = outings[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OutingProfileScreen(
                              outingId: outing.id,
                              userId: widget.userId,
                            ),
                          ),
                        );
                      },
                      child: DiscoverGroupCard(
                        group: outing,
                        cardWidth: cardWidth,
                        cardHeight: cardHeight,
                        cardBorderRadius: cardBorderRadius,
                        cardHorizontalMargin: cardHorizontalMargin,
                        imageAspectRatio: imageAspectRatio,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildPromotionSection(BuildContext context) {
    return StreamBuilder<List<PromotionModel>>(
      stream: _dataService.getPromotions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No promotions found'));
        } else {
          var promotions = snapshot.data!;
          double imageAspectRatio = 16 / 9;

          // View
          double viewWidth = MediaQuery.of(context).size.width;
          double viewHorizontalPadding = 2;
          double viewVerticalPadding = 16;
          // Card
          double showCardAmount = 1.7;
          double cardHorizontalMargin = 8;
          double cardWidth = (viewWidth -
                  (2 * viewHorizontalPadding) -
                  (showCardAmount.floor() * (2 * cardHorizontalMargin))) /
              showCardAmount;
          // Card Height: Image + Name + Rating + (Halal Label / Cuisine Type) + Influencer Name + Safety Margin
          double cardHeight = (cardWidth / imageAspectRatio) + 4;
          double cardBorderRadius = 12;
          // View Height
          double viewHeight = cardHeight + (2 * viewVerticalPadding);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitleRow(title: "Promotions"),
              SizedBox(
                width: viewWidth,
                height: viewHeight,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: promotions.length,
                  padding: EdgeInsets.symmetric(
                    horizontal: viewHorizontalPadding,
                    vertical: viewVerticalPadding,
                  ),
                  itemBuilder: (context, index) {
                    var promotion = promotions[index];
                    return PromotionCard(
                      promotion: promotion,
                      cardWidth: cardWidth,
                      cardHeight: cardHeight,
                      cardBorderRadius: cardBorderRadius,
                      cardHorizontalMargin: cardHorizontalMargin,
                      imageAspectRatio: imageAspectRatio,
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildPopularOutingSection(BuildContext context) {
    return StreamBuilder<List<OutingGroupModel>>(
      stream: _dataService.getAllOutingGroups(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No popular outings found."));
        } else {
          var popularOutings = snapshot.data!;
          double viewWidth = MediaQuery.of(context).size.width;

          const double viewHorizontalPadding = 8;
          const double viewVerticalPadding = 8;

          // Card
          const double showCardAmount = 1.15;
          const double cardAspectRatio = 0.35;

          double cardWidth =
              (viewWidth - viewHorizontalPadding) / showCardAmount;

          // Non-editable (maths calculation)
          double cardHeight = cardWidth * cardAspectRatio;

          double viewHeight = (2 * viewVerticalPadding) + (2 * cardHeight);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitleRow(title: "Popular Outings"),
              SizedBox(
                width: viewWidth,
                height: viewHeight,
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 0,
                    childAspectRatio: cardAspectRatio,
                  ),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: popularOutings.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: viewHorizontalPadding,
                    vertical: viewVerticalPadding,
                  ),
                  itemBuilder: (context, index) {
                    var outing = popularOutings[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OutingProfileScreen(
                              outingId: outing.id,
                              userId: widget.userId,
                            ),
                          ),
                        );
                      },
                      child: PopularOutingCard(
                        outing: outing,
                        cardWidth: cardWidth,
                        cardHeight: cardHeight,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _membershipStatus(BuildContext context, String status) {
    if (status == 'gold') {
      return _goldMembershipStatus(context);
    } else if (status == 'silver') {
      return _silverMembershipStatus(context);
    } else {
      return Container();
    }
  }

  Widget _goldMembershipStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 246, 212, 125),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Gold',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color.fromARGB(255, 165, 115, 26),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _silverMembershipStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 224, 226, 225),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Silver',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color.fromARGB(255, 78, 73, 80),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
