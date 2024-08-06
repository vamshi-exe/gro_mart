import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gromart_customer/constants.dart';
import 'package:gromart_customer/globalVariables.dart';
import 'package:gromart_customer/model/User.dart';
import 'package:gromart_customer/ui/cartScreen/CartScreen.dart';
import 'package:gromart_customer/ui/home/HomeScreen.dart';
import 'package:gromart_customer/ui/home/favourite_item.dart';
import 'package:gromart_customer/ui/profile/ProfileScreen.dart';

class NavigationController extends StatefulWidget {
  final User user;
  const NavigationController({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<NavigationController> createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  int _page = 0;
  late PageController pageController;

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void navigationTaped(int page) {
    pageController.jumpToPage(page);
  }

  String? selectedEvent;

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: darkBgColor,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onPageChanged,
        children: [
          HomeScreen(),
          FavouriteItemScreen(),
          CartScreen(),
          ProfileScreen(
            user: widget.user,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: AppColors.WHITE_COLOR,
        showUnselectedLabels: true,
        currentIndex: _page,
        selectedItemColor: Color(COLOR_ACCENT),
        unselectedItemColor: AppColors.DARK_BG_COLOR,
        // iconSize: 35,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            // backgroundColor: AppColors.DARK_BG_COLOR,
            icon: const Icon(
              Icons.home_outlined,
            ),
            label: "",
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_border_outlined,
            ),
            label: "",
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.local_mall_outlined,
            ),
            label: "",
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
            label: "",
          ),
        ],
        onTap: navigationTaped,
      ),
    );
  }
}
