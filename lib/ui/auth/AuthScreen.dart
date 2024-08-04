import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gromart_customer/constants.dart';
import 'package:gromart_customer/main.dart';
import 'package:gromart_customer/services/helper.dart';
import 'package:gromart_customer/ui/container/ContainerScreen.dart';
import 'package:gromart_customer/ui/location_permission_screen.dart';
import 'package:gromart_customer/ui/login/LoginScreen.dart';
import 'package:gromart_customer/ui/signUp/SignUpScreen.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : AppColors.BG_COLOR,
      body: Stack(children: [
        Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.2),
          child: Center(
            child: Image.asset(
              'assets/images/delivery_guy.png',
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.height * 0.47,
              // height: 150,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
                        // LocationPermission permission =
                        //     await Geolocator.checkPermission();
                        // if (permission == LocationPermission.always ||
                        //     permission == LocationPermission.whileInUse) {
                        //   if (MyAppState.selectedPosotion.location == null) {
                        //     pushAndRemoveUntil(
                        //         context, LocationPermissionScreen(), false);
                        //   } else {
                        //     pushAndRemoveUntil(
                        //         context,
                        //         ContainerScreen(
                        //           user: null,
                        //         ),
                        //         false);
                        //   }
                        // } else {
                        //   pushAndRemoveUntil(
                        //       context, LocationPermissionScreen(), false);
                        // }
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
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width * 0.89, 250),
                painter: BubblePainter(
                  color: isDarkMode(context)
                      ? AppColors.DARK_BG_COLOR
                      : AppColors.WHITE_COLOR,
                ),
              ),
            )
          ],
        ),
        // Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   crossAxisAlignment: CrossAxisAlignment.center,
        // children: <Widget>[

        // Padding(
        //   padding: const EdgeInsets.only(
        //       left: 16, top: 32, right: 16, bottom: 8),
        //   child: Text(
        //     "Welcome to NCR SabjiWala",
        //     textAlign: TextAlign.center,
        //     style: TextStyle(
        //         color: Color(COLOR_PRIMARY),
        //         fontSize: 24.0,
        //         fontWeight: FontWeight.bold),
        //   ).tr(),
        // ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        //   child: Text(
        //     "Order item from Store around you and track item in real-time",
        //     style: TextStyle(fontSize: 18),
        //     textAlign: TextAlign.center,
        //   ).tr(),
        // ),
        // Padding(
        //   padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
        //   child: ConstrainedBox(
        //     constraints: const BoxConstraints(minWidth: double.infinity),
        //     child: ElevatedButton(
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: Color(COLOR_PRIMARY),
        //         padding: EdgeInsets.only(top: 12, bottom: 12),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(25.0),
        //           side: BorderSide(
        //             color: Color(COLOR_PRIMARY),
        //           ),
        //         ),
        //       ),
        //       child: Text(
        //         "Log In",
        //         style: TextStyle(
        //             fontSize: 20,
        //             fontWeight: FontWeight.bold,
        //             color: Colors.white),
        //       ).tr(),
        //       onPressed: () {
        //         push(context, LoginScreen());
        //       },
        //     ),
        //   ),
        // ),
        // Padding(
        //   padding: const EdgeInsets.only(
        //       right: 40.0, left: 40.0, top: 20, bottom: 20),
        //   child: ConstrainedBox(
        //     constraints: const BoxConstraints(minWidth: double.infinity),
        //     child: TextButton(
        //       child: Text(
        //         "Sign Up",
        //         style: TextStyle(
        //             fontSize: 20,
        //             fontWeight: FontWeight.bold,
        //             color: Color(COLOR_PRIMARY)),
        //       ).tr(),
        //       onPressed: () {
        //         push(context, SignUpScreen());
        //       },
        //       style: ButtonStyle(
        //         padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        //           EdgeInsets.only(top: 12, bottom: 12),
        //         ),
        //         shape: MaterialStateProperty.all<OutlinedBorder>(
        //           RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(25.0),
        //             side: BorderSide(
        //               color: Color(COLOR_PRIMARY),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // )
        //   ],
        // ),
      ]),
    );
  }
}

class BubblePainter extends CustomPainter {
  final Color color;

  BubblePainter({super.repaint, required this.color});
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
      // Create slanting top
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

    // Draw the green circle
    final circlePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height - bubbleRadius),
        bubbleRadius - 15, circlePaint);

    // Draw the arrow
    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width / 2 - 8, size.height - bubbleRadius),
      Offset(size.width / 2 + 8, size.height - bubbleRadius),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(size.width / 2, size.height - bubbleRadius - 8),
      Offset(size.width / 2 + 8, size.height - bubbleRadius),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(size.width / 2, size.height - bubbleRadius + 8),
      Offset(size.width / 2 + 8, size.height - bubbleRadius),
      arrowPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
