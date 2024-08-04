import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gromart_customer/constants.dart';

// class Styles {
//   static ThemeData themeData(bool isDarkTheme, BuildContext context) {
//     return ThemeData(
//       primaryColor: isDarkTheme ? const Color(0xff131218) : Color(COLOR_PRIMARY),
//       indicatorColor: isDarkTheme ? const Color(0xff0E1D36) : const Color(0xffCBDCF8),
//       hintColor: isDarkTheme ? Colors.white38 : Colors.black38,
//       highlightColor: isDarkTheme ? Colors.white38 : Colors.black38,
//       hoverColor: isDarkTheme ? const Color(0xff3A3A3B) : const Color(0xff4285F4),
//       focusColor: isDarkTheme ? const Color(0xff0B2512) : const Color(0xffA8DAB5),
//       iconTheme: IconThemeData(color: isDarkTheme ? Colors.white : Colors.black),
//       cardColor: isDarkTheme ? const Color(0xFF151515) : Colors.white,
//       canvasColor: isDarkTheme ? Colors.black : Colors.grey[50],
//       brightness: isDarkTheme ? Brightness.dark : Brightness.light,
//       bottomSheetTheme: isDarkTheme ? BottomSheetThemeData(backgroundColor: Colors.grey.shade900) : const BottomSheetThemeData(backgroundColor: Colors.white),
//       buttonTheme: Theme.of(context).buttonTheme.copyWith(colorScheme: isDarkTheme ? const ColorScheme.dark() : const ColorScheme.light()),
//      textSelectionTheme: TextSelectionThemeData(selectionColor: isDarkTheme ? Colors.white : Colors.black), colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red).copyWith(background: isDarkTheme ? const Color(0xff131218) : const Color(0xffF1F5FB)),
//     );
//   }
// }

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      useMaterial3: false,
      textTheme: GoogleFonts.poppinsTextTheme(),
      primaryColor:
          isDarkTheme ? const Color(0xff131218) : Color(COLOR_PRIMARY),
      indicatorColor:
          isDarkTheme ? const Color(0xff0E1D36) : const Color(0xffCBDCF8),
      hintColor: isDarkTheme ? Colors.white38 : Colors.black38,
      highlightColor: isDarkTheme ? Colors.white38 : Colors.black38,
      disabledColor: Colors.grey,
      iconTheme:
          IconThemeData(color: isDarkTheme ? Colors.white : Colors.black),
      cardColor: isDarkTheme ? const Color(0xFF151515) : Colors.white,
      canvasColor: isDarkTheme ? Colors.black : Colors.grey[50],
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      bottomSheetTheme: isDarkTheme
          ? BottomSheetThemeData(backgroundColor: Colors.grey.shade900)
          : const BottomSheetThemeData(backgroundColor: Colors.white),
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
          colorScheme: isDarkTheme
              ? const ColorScheme.dark()
              : const ColorScheme.light()),
      appBarTheme: isDarkTheme
          ? AppBarTheme(
              backgroundColor: const Color(0xff131218),
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.white),
              elevation: 0)
          : AppBarTheme(
              titleTextStyle: TextStyle(color: Color(COLOR_PRIMARY)),
              backgroundColor: Colors.white,
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.black),
              elevation: 0),
      textSelectionTheme: TextSelectionThemeData(
          selectionColor: isDarkTheme ? Colors.white : Colors.black),
      colorScheme: ColorScheme(
          background:
              isDarkTheme ? const Color(0xff131218) : const Color(0xffF1F5FB),
          brightness: isDarkTheme ? Brightness.dark : Brightness.light,
          primary: isDarkTheme ? const Color(0xff131218) : Color(COLOR_PRIMARY),
          onPrimary:
              isDarkTheme ? const Color(0xff131218) : Color(COLOR_PRIMARY),
          secondary:
              isDarkTheme ? const Color(0xff131218) : Color(COLOR_PRIMARY),
          onSecondary:
              isDarkTheme ? const Color(0xff131218) : Color(COLOR_PRIMARY),
          error: isDarkTheme ? const Color(0xff131218) : Color(COLOR_PRIMARY),
          onError: isDarkTheme ? const Color(0xff131218) : Color(COLOR_PRIMARY),
          surface: isDarkTheme ? const Color(0xff131218) : Color(COLOR_PRIMARY),
          onSurface:
              isDarkTheme ? const Color(0xff131218) : Color(COLOR_PRIMARY)),
    );
  }
}
