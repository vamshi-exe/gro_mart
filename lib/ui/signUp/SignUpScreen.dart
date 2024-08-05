import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' as easyLocal;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gromart_customer/constants.dart';
import 'package:gromart_customer/main.dart';
import 'package:gromart_customer/model/User.dart';
import 'package:gromart_customer/services/FirebaseHelper.dart';
import 'package:gromart_customer/services/helper.dart';
import 'package:gromart_customer/ui/container/ContainerScreen.dart';
import 'package:gromart_customer/ui/location_permission_screen.dart';
import 'package:gromart_customer/ui/login/LoginScreen.dart';
import 'package:gromart_customer/ui/phoneAuth/PhoneNumberInputScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

File? _image;

class SignUpScreen extends StatefulWidget {
  @override
  State createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> with TickerProviderStateMixin {
  late final SmsRetriever smsRetriever;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  TextEditingController emailController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  TextEditingController _passwordController = TextEditingController();
  GlobalKey<FormState> _key = GlobalKey();
  String? firstName,
      lastName,
      email,
      mobile,
      password,
      confirmPassword,
      referralCode;
  AutovalidateMode _validate = AutovalidateMode.disabled;

  bool showVerifyEmailPopup = false;
  bool showEnterOTPPopup = false;
  bool showSuccessPopup = false;
  AnimationController? controller;

  Duration get duration => controller!.duration! * controller!.value;

  bool get expired => duration.inSeconds == 0;

  void toggleVerifyEmailPopup() {
    setState(() {
      showVerifyEmailPopup = !showVerifyEmailPopup;
    });
  }

  void toggleEnterOTPPopup() {
    setState(() {
      showEnterOTPPopup = !showEnterOTPPopup;
    });
  }

  void toggleSuccessPopup() {
    setState(() {
      showSuccessPopup = !showSuccessPopup;
    });
  }

  @override
  void initState() {
    super.initState();
    // formKey = GlobalKey<FormState>();
    // pinController = TextEditingController();
    // focusNode = FocusNode();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 30),
    );

    smsRetriever = SmsRetrieverImpl(
      SmartAuth(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      retrieveLostData();
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
                child: Form(
                  key: _key,
                  autovalidateMode: _validate,
                  child: formUI(),
                ),
              ),
            ),
            if (showVerifyEmailPopup) ...[
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Verify Your Email Address',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        emailController.text,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'We will send the authentication code to the email address you entered. Do you want to continue?',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: toggleVerifyEmailPopup,
                              child: const Text('Cancel'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green,
                                side: const BorderSide(color: Colors.green),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                toggleVerifyEmailPopup();
                                toggleEnterOTPPopup();
                              },
                              child: const Text('Next'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
            if (showEnterOTPPopup) ...[
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.only(left: 12.0, right: 12),
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Enter OTP',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A verification code has been sent to ${emailController.text}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Pinput(
                        smsRetriever: smsRetriever,
                        length: 4,
                        showCursor: true,
                        onCompleted: (pin) => print(pin),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          toggleEnterOTPPopup();
                          toggleSuccessPopup();
                          // _signUp();
                          await _signUpWithEmailAndPassword();
                        },
                        child: const Text('Verify'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Didn't receive the code?"),
                          TextButton(
                            onPressed: () {
                              // Add resend OTP functionality
                            },
                            child: const Text(
                              'Resend (30s)',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
            if (showSuccessPopup) ...[
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Account Created Successfully',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your account created successfully.\nListen to your favourite music.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          toggleSuccessPopup();
                          // Navigator.of(context).pushAndRemoveUntil(
                          //   MaterialPageRoute(builder: (context) => HomePage()),
                          //   (Route<dynamic> route) => false,
                          // );
                        },
                        child: const Text('Go to Home'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse? response = await _imagePicker.retrieveLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image = File(response.file!.path);
      });
    }
  }

  _onCameraClick() {
    final action = CupertinoActionSheet(
      message: Text(
        'Add profile picture',
        style: TextStyle(fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('Choose from gallery').tr(),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null)
              setState(() {
                _image = File(image.path);
              });
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a picture').tr(),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null)
              setState(() {
                _image = File(image.path);
              });
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('cancel').tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  Widget formUI() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 8.0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 24,
          ),
          Image.asset(
            'assets/images/logo.png',
            height: 80,
          ),
          Text(
            'Create new account',
            style: GoogleFonts.poppins(
                color: Color(DARK_BG_COLOR),
                fontWeight: FontWeight.bold,
                fontSize: 25.0),
          ).tr(),

          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Set up your username and password.\nYou can always change it later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(DARK_GREY_TEXT_COLOR),
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600),
            ).tr(),
          ),

          // picture module
          // Padding(
          //   padding:
          //       const EdgeInsets.only(left: 8.0, top: 32, right: 8, bottom: 8),
          //   child: Stack(
          //     alignment: Alignment.bottomCenter,
          //     children: <Widget>[
          //       CircleAvatar(
          //         radius: 65,
          //         backgroundColor: Colors.grey.shade400,
          //         child: ClipOval(
          //           child: SizedBox(
          //             width: 170,
          //             height: 170,
          //             child: _image == null
          //                 ? Image.asset(
          //                     'assets/images/placeholder.jpg',
          //                     fit: BoxFit.cover,
          //                   )
          //                 : Image.file(
          //                     _image!,
          //                     fit: BoxFit.cover,
          //                   ),
          //           ),
          //         ),
          //       ),
          //       Positioned(
          //         left: 80,
          //         right: 0,
          //         child: FloatingActionButton(
          //             backgroundColor: Color(COLOR_ACCENT),
          //             child: Icon(
          //               CupertinoIcons.camera,
          //               color: isDarkMode(context) ? Colors.black : Colors.white,
          //             ),
          //             mini: true,
          //             onPressed: _onCameraClick),
          //       )
          //     ],
          //   ),
          // ),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
              ),
              child: TextFormField(
                cursorColor: Color(COLOR_ACCENT),
                textAlignVertical: TextAlignVertical.center,
                validator: validateName,
                onSaved: (String? val) {
                  firstName = val;
                },
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  fillColor: Colors.white,
                  hintText: easyLocal.tr('First Name'),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          BorderSide(color: Color(COLOR_ACCENT), width: 2.0)),
                  errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
              ),
              child: TextFormField(
                validator: validateName,
                textAlignVertical: TextAlignVertical.center,
                cursorColor: Color(COLOR_ACCENT),
                onSaved: (String? val) {
                  lastName = val;
                },
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  fillColor: Colors.white,
                  hintText: 'Last Name'.tr(),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          BorderSide(color: Color(COLOR_ACCENT), width: 2.0)),
                  errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
              ),
              child: TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textAlignVertical: TextAlignVertical.center,
                textInputAction: TextInputAction.next,
                cursorColor: Color(COLOR_ACCENT),
                validator: validateEmail,
                onSaved: (String? val) {
                  setState(() {
                    email = val;
                  });
                },
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  fillColor: Colors.white,
                  hintText: 'Email Address'.tr(),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          BorderSide(color: Color(COLOR_ACCENT), width: 2.0)),
                  errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ),

          /// user mobile text field, this is hidden in case of sign up with
          /// phone number
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Colors.grey.shade400)),
              child: InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) =>
                    mobile = number.phoneNumber,
                ignoreBlank: true,
                autoValidateMode: AutovalidateMode.onUserInteraction,
                inputDecoration: InputDecoration(
                  hintText: 'Phone Number'.tr(),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
                inputBorder: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                initialValue: PhoneNumber(isoCode: 'IN'),
                selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.DIALOG),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
              ),
              child: TextFormField(
                obscureText: _isPasswordVisible,
                textAlignVertical: TextAlignVertical.center,
                textInputAction: TextInputAction.next,
                controller: _passwordController,
                validator: validatePassword,
                onSaved: (String? val) {
                  password = val;
                },
                style: TextStyle(fontSize: 18.0),
                cursorColor: Color(COLOR_ACCENT),
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
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  fillColor: Colors.white,
                  hintText: 'Password'.tr(),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          BorderSide(color: Color(COLOR_ACCENT), width: 2.0)),
                  errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
              ),
              child: TextFormField(
                textAlignVertical: TextAlignVertical.center,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => toggleVerifyEmailPopup,
                obscureText: _isConfirmPasswordVisible,
                validator: (val) =>
                    validateConfirmPassword(_passwordController.text, val),
                onSaved: (String? val) {
                  confirmPassword = val;
                },
                style: TextStyle(fontSize: 18.0),
                cursorColor: Color(COLOR_ACCENT),
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                      icon: Icon(_isConfirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility)),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  fillColor: Colors.white,
                  hintText: 'Confirm Password'.tr(),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          BorderSide(color: Color(COLOR_ACCENT), width: 2.0)),
                  errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ),

          // ConstrainedBox(
          //   constraints: BoxConstraints(minWidth: double.infinity),
          //   child: Padding(
          //     padding: const EdgeInsets.only(
          //       top: 16.0,
          //     ),
          //     child: TextFormField(
          //       textAlignVertical: TextAlignVertical.center,
          //       textInputAction: TextInputAction.next,
          //       onSaved: (String? val) {
          //         referralCode = val;
          //       },
          //       style: TextStyle(fontSize: 18.0),
          //       cursorColor: Color(COLOR_ACCENT),
          //       decoration: InputDecoration(
          //         contentPadding:
          //             EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          //         fillColor: Colors.white,
          //         hintText: 'Referral Code (Optional)'.tr(),
          //         focusedBorder: OutlineInputBorder(
          //             borderRadius: BorderRadius.circular(8.0),
          //             borderSide:
          //                 BorderSide(color: Color(COLOR_ACCENT), width: 2.0)),
          //         errorBorder: OutlineInputBorder(
          //           borderSide:
          //               BorderSide(color: Theme.of(context).colorScheme.error),
          //           borderRadius: BorderRadius.circular(8.0),
          //         ),
          //         focusedErrorBorder: OutlineInputBorder(
          //           borderSide:
          //               BorderSide(color: Theme.of(context).colorScheme.error),
          //           borderRadius: BorderRadius.circular(8.0),
          //         ),
          //         enabledBorder: OutlineInputBorder(
          //           borderSide: BorderSide(color: Colors.grey.shade400),
          //           borderRadius: BorderRadius.circular(8.0),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    backgroundColor: Color(COLOR_ACCENT),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Color(COLOR_ACCENT),
                      ),
                    ),
                  ),
                  child: Text(
                    'Sign Up'.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode(context) ? Colors.black : Colors.white,
                    ),
                  ),
                  // onPressed: toggleVerifyEmailPopup

                  onPressed: () => _signUp()
                  // toggleVerifyEmailPopup,
                  ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account?",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  " Login",
                  style: TextStyle(
                      color: Color(COLOR_ACCENT),
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          // InkWell(
          //   onTap: () {
          //     push(context, PhoneNumberInputScreen(login: false));
          //   },
          //   child: Padding(
          //     padding: EdgeInsets.only(top: 10, right: 40, left: 40),
          //     child: Container(
          //         alignment: Alignment.bottomCenter,
          //         padding: EdgeInsets.all(10),
          //         decoration: BoxDecoration(
          //             borderRadius: BorderRadius.circular(25),
          //             border:
          //                 Border.all(color: Color(COLOR_ACCENT), width: 1)),
          //         child: Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //             children: [
          //               Icon(
          //                 Icons.phone,
          //                 color: Color(COLOR_ACCENT),
          //               ),
          //               Text(
          //                 "Sign Up With Phone Number".tr(),
          //                 style: TextStyle(
          //                     color: Color(COLOR_ACCENT),
          //                     fontWeight: FontWeight.bold,
          //                     letterSpacing: 1),
          //               ),
          //             ])),
          //   ),
          // )
        ],
      ),
    );
  }

  /// dispose text controllers to avoid memory leaks
  @override
  void dispose() {
    _passwordController.dispose();
    _image = null;
    super.dispose();
  }

  /// if the fields are validated and location is enabled we create a new user
  /// and navigate to [ContainerScreen] else we show error
  _signUp() async {
    if (_key.currentState?.validate() ?? false) {
      _key.currentState!.save();
      toggleVerifyEmailPopup();
      // if (referralCode.toString().isNotEmpty) {
      //   FireStoreUtils.checkReferralCodeValidOrNot(referralCode.toString())
      //       .then((value) async {
      //     if (value == true) {
      //       await _signUpWithEmailAndPassword();
      //     } else {
      //       final snack = SnackBar(
      //         content: Text(
      //           'Referral Code is Invalid'.tr(),
      //           style: TextStyle(color: Colors.white),
      //         ),
      //         duration: Duration(seconds: 2),
      //         backgroundColor: Colors.black,
      //       );
      //       ScaffoldMessenger.of(context).showSnackBar(snack);
      //     }
      //   });
      // } else {
      // await _signUpWithEmailAndPassword();
      // }
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  _signUpWithEmailAndPassword() async {
    await showProgress(
        context, "Creating new account, Please wait...".tr(), false);
    dynamic result = await FireStoreUtils.firebaseSignUpWithEmailAndPassword(
        email!.trim(),
        password!.trim(),
        _image,
        firstName!,
        lastName!,
        mobile!,
        context,
        referralCode.toString());
    await hideProgress();
    if (result != null && result is User) {
      MyAppState.currentUser = result;
      if (MyAppState.currentUser!.shippingAddress != null &&
          MyAppState.currentUser!.shippingAddress!.isNotEmpty) {
        if (MyAppState.currentUser!.shippingAddress!
            .where((element) => element.isDefault == true)
            .isNotEmpty) {
          MyAppState.selectedPosotion = MyAppState.currentUser!.shippingAddress!
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
    } else if (result != null && result is String) {
      showAlertDialog(context, 'failed'.tr(), result, true);
    } else {
      showAlertDialog(context, 'failed'.tr(), "Couldn't sign up".tr(), true);
    }
  }
}

class SmsRetrieverImpl implements SmsRetriever {
  const SmsRetrieverImpl(this.smartAuth);

  final SmartAuth smartAuth;

  @override
  Future<void> dispose() {
    return smartAuth.removeSmsListener();
  }

  @override
  Future<String?> getSmsCode() async {
    final signature = await smartAuth.getAppSignature();
    debugPrint('App Signature: $signature');
    final res = await smartAuth.getSmsCode(
      useUserConsentApi: true,
    );
    if (res.succeed && res.codeFound) {
      return res.code!;
    }
    return null;
  }

  @override
  bool get listenForMultipleSms => false;
}
