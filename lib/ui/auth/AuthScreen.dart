import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gromart_customer/constants.dart';
import 'package:gromart_customer/services/helper.dart';
import 'package:gromart_customer/ui/login/LoginScreen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> _titlesList = [
    'Welcome to NCR SabjiWala',
    'Fresh and Quality Products',
    'Fast and Reliable Delivery',
  ];

  final List<String> _subtitlesList = [
    'Order items from stores around you and track your order in real-time.',
    'We provide the best quality products directly from the farms to your doorstep.',
    'Get your products delivered fast and on time, every time.',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onArrowPressed() {
    if (_pageController.page == _titlesList.length - 1) {
      // Navigate to LoginScreen when the last page is reached
      pushAndRemoveUntil(context, LoginScreen(), false);
    } else {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : AppColors.BG_COLOR,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.width * 0.2),
            child: Center(
              child: Image.asset(
                'assets/images/delivery_guy.png',
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.height * 0.47,
              ),
            ),
          ),
          PageView.builder(
            controller: _pageController,
            itemCount: _titlesList.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Positioned(
                    bottom: 35,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: CustomPaint(
                        size:
                            Size(MediaQuery.of(context).size.width * 0.89, 250),
                        painter: BubblePainter(
                          color: isDarkMode(context)
                              ? AppColors.DARK_BG_COLOR
                              : AppColors.WHITE_COLOR,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.73,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        Text(
                          _titlesList[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(COLOR_PRIMARY),
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold),
                        ).tr(),
                        SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _subtitlesList[index],
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ).tr(),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 48,
                    left: MediaQuery.of(context).size.width / 2 - 25,
                    child: GestureDetector(
                      onTap: _onArrowPressed,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 230,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _titlesList.length,
                effect: ScrollingDotsEffect(
                  activeDotColor: Color(COLOR_PRIMARY),
                  dotColor: Colors.grey,
                  dotHeight: 8.0,
                  dotWidth: 8.0,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 20.0, left: 20.0, top: 40, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text(
                      'Skip',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(COLOR_ACCENT)),
                    ).tr(),
                    onPressed: () {
                      pushAndRemoveUntil(context, LoginScreen(), false);
                    },
                  ),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Color(COLOR_ACCENT)),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  final Color color;

  BubblePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double cornerRadius = 30;
    final double bubbleSize = 90;
    final double bubbleRadius = bubbleSize / 2;
    final double slopeHeight = 20;

    final path = Path()
      ..moveTo(0, cornerRadius)
      ..quadraticBezierTo(0, 0, cornerRadius, 0)
      ..lineTo(size.width - cornerRadius, slopeHeight)
      ..quadraticBezierTo(
          size.width, slopeHeight, size.width, cornerRadius + slopeHeight)
      ..lineTo(size.width, size.height - cornerRadius - bubbleRadius)
      ..quadraticBezierTo(size.width, size.height - bubbleRadius,
          size.width - cornerRadius, size.height - bubbleRadius)
      ..lineTo((size.width / 2) + bubbleRadius, size.height - bubbleRadius)
      ..arcToPoint(
          Offset((size.width / 2) - bubbleRadius, size.height - bubbleRadius),
          radius: Radius.circular(bubbleRadius),
          clockwise: true)
      ..lineTo(cornerRadius, size.height - bubbleRadius)
      ..quadraticBezierTo(0, size.height - bubbleRadius, 0,
          size.height - cornerRadius - bubbleRadius)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
