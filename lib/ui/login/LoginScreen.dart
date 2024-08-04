import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gromart_customer/ui/location_permission_screen.dart';
import 'package:gromart_customer/ui/signUp/SignUpScreen.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple;
import 'package:gromart_customer/constants.dart';
import 'package:gromart_customer/main.dart';
import 'package:gromart_customer/model/User.dart';
import 'package:gromart_customer/services/FirebaseHelper.dart';
import 'package:gromart_customer/services/helper.dart';
import 'package:gromart_customer/ui/container/ContainerScreen.dart';
import 'package:gromart_customer/ui/phoneAuth/PhoneNumberInputScreen.dart';
import 'package:gromart_customer/ui/resetPasswordScreen/ResetPasswordScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  GlobalKey<FormState> _key = GlobalKey();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _key,
        autovalidateMode: _validate,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 16.0),
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              children: <Widget>[
                SizedBox(
                  height: 24,
                ),
                Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 32.0,
                  ),
                  child: Center(
                    child: Text(
                      'Welcome Back',
                      style: GoogleFonts.poppins(
                          color: AppColors.DARK_BG_COLOR,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold),
                    ).tr(),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                  ),
                  child: Text(
                    'Log in to your account using email or social networks',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(DARK_GREY_TEXT_COLOR),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w100),
                  ).tr(),
                ),
                SizedBox(
                  height: 20,
                ),
                Platform.isIOS
                    ? GestureDetector(
                        onTap: () => loginWithApple(),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.BORDER_COLOR_GREY
                                    .withOpacity(0.4)),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.apple,
                                  color: Colors.black,
                                  size: 32,
                                ),
                                SizedBox(width: 8),
                                Text('Login with Apple',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () async => loginWithFacebook(),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.BORDER_COLOR_GREY
                                    .withOpacity(0.4)),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/images/facebook_logo.png',
                                    height: 28),
                                SizedBox(width: 8),
                                Text('Login with Facebook',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),

                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.BORDER_COLOR_GREY.withOpacity(0.4)),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network('https://www.google.com/favicon.ico',
                            height: 28),
                        const SizedBox(width: 8),
                        const Text(
                          'Login with Google',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          height: 1,
                          width: 50,
                          color: AppColors.BORDER_COLOR_GREY.withOpacity(0.4)),
                      Text(
                        'Or continue with social account',
                        style: TextStyle(
                            color: Color(DARK_GREY_TEXT_COLOR),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w100),
                      ),
                      Container(
                          height: 1,
                          width: 50,
                          color: AppColors.BORDER_COLOR_GREY.withOpacity(0.4)),
                    ],
                  ),
                ),

                /// email address text field, visible when logging with email
                /// and password
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: double.infinity),
                  child: TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.next,
                      validator: validateEmail,
                      controller: _emailController,
                      style: TextStyle(fontSize: 18.0),
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: Color(COLOR_PRIMARY),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 16, right: 16),
                        hintText: 'Email Address'.tr(),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Color(COLOR_ACCENT), width: 2.0)),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      )),
                ),

                /// password text field, visible when logging with email and
                /// password
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: double.infinity),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 24.0,
                    ),
                    child: TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        controller: _passwordController,
                        obscureText: _isPasswordVisible,
                        validator: validatePassword,
                        onFieldSubmitted: (password) => _login(),
                        textInputAction: TextInputAction.done,
                        style: TextStyle(fontSize: 18.0),
                        cursorColor: Color(COLOR_PRIMARY),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: Icon(_isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility)),
                          contentPadding: EdgeInsets.only(left: 16, right: 16),
                          hintText: 'Password'.tr(),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Color(COLOR_ACCENT), width: 2.0)),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        )),
                  ),
                ),

                /// forgot password text, navigates user to ResetPasswordScreen
                /// and this is only visible when logging with email and password
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => push(context, ResetPasswordScreen()),
                      child: Text(
                        'Forgot password?'.tr(),
                        style: TextStyle(
                            color: Color(COLOR_ACCENT),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                    ),
                  ),
                ),

                /// the main action button of the screen, this is hidden if we
                /// received the code from firebase
                /// the action and the title is base on the state,
                /// * logging with email and password: send email and password to
                /// firebase
                /// * logging with phone number: submits the phone number to
                /// firebase and await for code verification
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: double.infinity),
                    child: GestureDetector(
                      onTap: () => _login(),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Color(COLOR_ACCENT),
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: Text(
                            'Login'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't have an account?",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    GestureDetector(
                      onTap: () {
                        push(context, SignUpScreen());
                      },
                      child: Text(
                        " Register",
                        style: TextStyle(
                            color: Color(COLOR_ACCENT),
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // FutureBuilder<bool>(
                //   future: apple.TheAppleSignIn.isAvailable(),
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return CircularProgressIndicator.adaptive(
                //         valueColor:
                //             AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                //       );
                //     }
                //     if (!snapshot.hasData || (snapshot.data != true)) {
                //       return Container();
                //     } else {
                //       return Padding(
                //         padding: const EdgeInsets.only(
                //             right: 40.0, left: 40.0, bottom: 20),
                //         child: apple.AppleSignInButton(
                //           cornerRadius: 25.0,
                //           type: apple.ButtonType.signIn,
                //           style: isDarkMode(context)
                //               ? apple.ButtonStyle.white
                //               : apple.ButtonStyle.black,
                //           onPressed: () => loginWithApple(),
                //         ),
                //       );
                //     }
                //   },
                // ),

                /// switch between login with phone number and email login states
                // InkWell(
                //   onTap: () {
                //     push(context, PhoneNumberInputScreen(login: true));
                //   },
                //   child: Padding(
                //     padding: EdgeInsets.only(top: 10, right: 40, left: 40),
                //     child: Container(
                //         alignment: Alignment.bottomCenter,
                //         padding: EdgeInsets.all(10),
                //         decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(25),
                //             border: Border.all(
                //                 color: Color(COLOR_PRIMARY), width: 1)),
                //         child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //             children: [
                //               Icon(
                //                 Icons.phone,
                //                 color: Color(COLOR_PRIMARY),
                //               ),
                //               Text(
                //                 'Login with phone number'.tr(),
                //                 style: TextStyle(
                //                     color: Color(COLOR_PRIMARY),
                //                     fontWeight: FontWeight.bold,
                //                     fontSize: 16,
                //                     letterSpacing: 1),
                //               ),
                //             ])),
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _login() async {
    if (_key.currentState?.validate() ?? false) {
      _key.currentState!.save();
      await _loginWithEmailAndPassword(
          _emailController.text.trim(), _passwordController.text.trim());
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  /// login with email and password with firebase
  /// @param email user email
  /// @param password user password
  _loginWithEmailAndPassword(String email, String password) async {
    await showProgress(context, "Logging in, please wait...".tr(), false);
    dynamic result = await FireStoreUtils.loginWithEmailAndPassword(
        email.trim(), password.trim());
    await hideProgress();
    if (result != null && result is User && result.role == USER_ROLE_CUSTOMER) {
      result.fcmToken = await FireStoreUtils.firebaseMessaging.getToken() ?? '';
      await FireStoreUtils.updateCurrentUser(result).then((value) {
        MyAppState.currentUser = result;
        print(MyAppState.currentUser!.active.toString() + "===S");
        if (MyAppState.currentUser!.active == true) {
          if (MyAppState.currentUser!.shippingAddress != null &&
              MyAppState.currentUser!.shippingAddress!.isNotEmpty) {
            if (MyAppState.currentUser!.shippingAddress!
                .where((element) => element.isDefault == true)
                .isNotEmpty) {
              MyAppState.selectedPosotion = MyAppState
                  .currentUser!.shippingAddress!
                  .where((element) => element.isDefault == true)
                  .single;
            } else {
              MyAppState.selectedPosotion =
                  MyAppState.currentUser!.shippingAddress!.first;
            }
            pushAndRemoveUntil(context, ContainerScreen(user: result), false);
          } else {
            pushAndRemoveUntil(context, LocationPermissionScreen(), false);
          }
        } else {
          showAlertDialog(
              context,
              "Your account has been disabled, Please contact to admin.".tr(),
              "",
              true);
        }
      });
    } else if (result != null && result is String) {
      showAlertDialog(context, "Couldn't Authenticate".tr(), result, true);
    } else {
      showAlertDialog(context, "Couldn't Authenticate".tr(),
          'Login failed, Please try again.'.tr(), true);
    }
  }

  ///dispose text editing controllers to avoid memory leaks
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  loginWithFacebook() async {
    try {
      await showProgress(context, "Logging in, please wait...".tr(), false);
      dynamic result = await FireStoreUtils.loginWithFacebook();
      await hideProgress();
      if (result != null && result is User) {
        MyAppState.currentUser = result;

        if (MyAppState.currentUser!.active == true) {
          if (MyAppState.currentUser!.shippingAddress != null &&
              MyAppState.currentUser!.shippingAddress!.isNotEmpty) {
            if (MyAppState.currentUser!.shippingAddress!
                .where((element) => element.isDefault == true)
                .isNotEmpty) {
              MyAppState.selectedPosotion = MyAppState
                  .currentUser!.shippingAddress!
                  .where((element) => element.isDefault == true)
                  .single;
            } else {
              MyAppState.selectedPosotion =
                  MyAppState.currentUser!.shippingAddress!.first;
            }
            pushAndRemoveUntil(context, ContainerScreen(user: result), false);
          } else {
            pushAndRemoveUntil(context, LocationPermissionScreen(), false);
          }
        } else {
          showAlertDialog(
              context,
              "Your account has been disabled, Please contact to admin.".tr(),
              "",
              true);
        }
      } /*else if (result != null && result is String) {
        showAlertDialog(context, 'Error'.tr(), result.tr(), true);
      } else {
        showAlertDialog(
            context, 'Error', "Couldn't login with facebook.".tr(), true);
      }*/
    } catch (e, s) {
      await hideProgress();
      print('_LoginScreen.loginWithFacebook $e $s');
      showAlertDialog(
          context, 'error'.tr(), "Couldn't login with facebook.".tr(), true);
    }
  }

  loginWithApple() async {
    try {
      await showProgress(context, "Logging in, please wait...".tr(), false);
      dynamic result = await FireStoreUtils.loginWithApple();
      await hideProgress();
      if (result != null && result is User) {
        MyAppState.currentUser = result;
        if (MyAppState.currentUser!.active == true) {
          if (MyAppState.currentUser!.shippingAddress != null &&
              MyAppState.currentUser!.shippingAddress!.isNotEmpty) {
            if (MyAppState.currentUser!.shippingAddress!
                .where((element) => element.isDefault == true)
                .isNotEmpty) {
              MyAppState.selectedPosotion = MyAppState
                  .currentUser!.shippingAddress!
                  .where((element) => element.isDefault == true)
                  .single;
            } else {
              MyAppState.selectedPosotion =
                  MyAppState.currentUser!.shippingAddress!.first;
            }
            pushAndRemoveUntil(context, ContainerScreen(user: result), false);
          } else {
            pushAndRemoveUntil(context, LocationPermissionScreen(), false);
          }
        } else {
          showAlertDialog(
              context,
              "Your account has been disabled, Please contact to admin.".tr(),
              "",
              true);
        }
      } else if (result != null && result is String) {
        showAlertDialog(context, 'error'.tr(), result.tr(), true);
      } else {
        showAlertDialog(
            context, 'error', "Couldn't login with apple.".tr(), true);
      }
    } catch (e, s) {
      await hideProgress();
      print('_LoginScreen.loginWithApple $e $s');
      showAlertDialog(
          context, 'error'.tr(), "Couldn't login with apple.".tr(), true);
    }
  }
}
