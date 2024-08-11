// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_auth/firebase_auth.dart' as auth;
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:gromart_customer/constants.dart';
// import 'package:gromart_customer/main.dart';
// import 'package:gromart_customer/model/User.dart';
// import 'package:gromart_customer/services/FirebaseHelper.dart';
// import 'package:gromart_customer/services/helper.dart';
// import 'package:gromart_customer/ui/accountDetails/AccountDetailsScreen.dart';
// import 'package:gromart_customer/ui/auth/AuthScreen.dart';
// import 'package:gromart_customer/ui/contactUs/ContactUsScreen.dart';
// import 'package:gromart_customer/ui/reauthScreen/reauth_user_screen.dart';
// import 'package:image_picker/image_picker.dart';

// class ProfileScreen extends StatefulWidget {
//   final User user;

//   ProfileScreen({Key? key, required this.user}) : super(key: key);

//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final ImagePicker _imagePicker = ImagePicker();
//   late User user;

//   @override
//   void initState() {
//     user = widget.user;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: isDarkMode(context) ? Color(DARK_COLOR) : null,
//       body: SingleChildScrollView(
//         child: Column(children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.only(top: 32.0, left: 32, right: 32),
//             child: Stack(
//               alignment: Alignment.bottomCenter,
//               children: <Widget>[
//                 Center(
//                     child:
//                         displayCircleImage(user.profilePictureURL, 130, false)),
//                 Positioned(
//                   right: 100,
//                   child: FloatingActionButton(
//                       backgroundColor: Color(COLOR_ACCENT),
//                       child: Icon(
//                         Icons.camera_alt,
//                         color:
//                             isDarkMode(context) ? Colors.black : Colors.white,
//                       ),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30)),
//                       mini: true,
//                       onPressed: _onCameraClick),
//                 )
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 16.0, right: 32, left: 32),
//             child: Text(
//               user.fullName(),
//               style: TextStyle(
//                   color: isDarkMode(context) ? Colors.white : Colors.black,
//                   fontSize: 20),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 8),
//             child: Column(
//               children: <Widget>[
//                 ListTile(
//                   onTap: () {
//                     push(context, AccountDetailsScreen(user: user));
//                   },
//                   title: Text(
//                     "Account Details",
//                     style: TextStyle(fontSize: 16),
//                   ).tr(),
//                   leading: Icon(
//                     CupertinoIcons.person_alt,
//                     color: Colors.blue,
//                   ),
//                 ),
//                 // ListTile(
//                 //   onTap: () {
//                 //     push(context, SettingsScreen(user: user));
//                 //   },
//                 //   title: Text(
//                 //     "settings",
//                 //     style: TextStyle(fontSize: 16),
//                 //   ).tr(),
//                 //   leading: Icon(
//                 //     CupertinoIcons.settings,
//                 //     color: Colors.grey,
//                 //   ),
//                 // ),
//                 ListTile(
//                   onTap: () {
//                     push(context, ContactUsScreen());
//                   },
//                   title: Text(
//                     "Contact Us",
//                     style: TextStyle(fontSize: 16),
//                   ).tr(),
//                   leading: Hero(
//                     tag: "Contact Us".tr(),
//                     child: Icon(
//                       CupertinoIcons.phone_solid,
//                       color: Colors.green,
//                     ),
//                   ),
//                 ),
//                 ListTile(
//                   onTap: () async {
//                     AuthProviders? authProvider;
//                     List<auth.UserInfo> userInfoList =
//                         auth.FirebaseAuth.instance.currentUser?.providerData ??
//                             [];
//                     await Future.forEach(userInfoList, (auth.UserInfo info) {
//                       switch (info.providerId) {
//                         case 'password':
//                           authProvider = AuthProviders.PASSWORD;
//                           break;
//                         case 'phone':
//                           authProvider = AuthProviders.PHONE;
//                           break;
//                         case 'facebook.com':
//                           authProvider = AuthProviders.FACEBOOK;
//                           break;
//                         case 'apple.com':
//                           authProvider = AuthProviders.APPLE;
//                           break;
//                       }
//                     });
//                     bool? result = await showDialog(
//                       context: context,
//                       builder: (context) => ReAuthUserScreen(
//                         provider: authProvider!,
//                         email: auth.FirebaseAuth.instance.currentUser!.email,
//                         phoneNumber:
//                             auth.FirebaseAuth.instance.currentUser!.phoneNumber,
//                         deleteUser: true,
//                       ),
//                     );
//                     if (result != null && result) {
//                       await showProgress(
//                           context, "Deleting account...".tr(), false);
//                       await FireStoreUtils.deleteUser();
//                       await hideProgress();
//                       MyAppState.currentUser = null;
//                       pushAndRemoveUntil(context, AuthScreen(), false);
//                     }
//                   },
//                   title: Text(
//                     'Delete Account'.tr(),
//                     style: TextStyle(fontSize: 16),
//                   ).tr(),
//                   leading: Icon(
//                     CupertinoIcons.delete,
//                     color: Colors.red,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(minWidth: double.infinity),
//               child: TextButton(
//                 style: TextButton.styleFrom(
//                   backgroundColor: Colors.transparent,
//                   padding: EdgeInsets.only(top: 12, bottom: 12),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                       side: BorderSide(
//                           color: isDarkMode(context)
//                               ? Colors.grey.shade700
//                               : Colors.grey.shade200)),
//                 ),
//                 child: Text(
//                   'Log Out',
//                   style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: isDarkMode(context) ? Colors.white : Colors.black),
//                 ).tr(),
//                 onPressed: () async {
//                   //user.active = false;
//                   user.lastOnlineTimestamp = Timestamp.now();
//                   await FireStoreUtils.updateCurrentUser(user);
//                   await auth.FirebaseAuth.instance.signOut();
//                   MyAppState.currentUser = null;
//                   pushAndRemoveUntil(context, AuthScreen(), false);
//                 },
//               ),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }

//   _onCameraClick() {
//     final action = CupertinoActionSheet(
//       message: Text(
//         "Add profile picture",
//         style: TextStyle(fontSize: 15.0),
//       ).tr(),
//       actions: <Widget>[
//         CupertinoActionSheetAction(
//           child: Text("Remove Picture").tr(),
//           isDestructiveAction: true,
//           onPressed: () async {
//             Navigator.pop(context);
//             showProgress(context, "Removing picture...".tr(), false);
//             user.profilePictureURL = '';
//             await FireStoreUtils.updateCurrentUser(user);
//             MyAppState.currentUser = user;
//             hideProgress();
//             setState(() {});
//           },
//         ),
//         CupertinoActionSheetAction(
//           child: Text("Choose from gallery").tr(),
//           onPressed: () async {
//             Navigator.pop(context);
//             XFile? image =
//                 await _imagePicker.pickImage(source: ImageSource.gallery);
//             if (image != null) {
//               await _imagePicked(File(image.path));
//             }
//             setState(() {});
//           },
//         ),
//         CupertinoActionSheetAction(
//           child: Text("Take a picture").tr(),
//           onPressed: () async {
//             Navigator.pop(context);
//             XFile? image =
//                 await _imagePicker.pickImage(source: ImageSource.camera);
//             if (image != null) {
//               await _imagePicked(File(image.path));
//             }
//             setState(() {});
//           },
//         ),
//       ],
//       cancelButton: CupertinoActionSheetAction(
//         child: Text('Cancel').tr(),
//         onPressed: () {
//           Navigator.pop(context);
//         },
//       ),
//     );
//     showCupertinoModalPopup(context: context, builder: (context) => action);
//   }

//   Future<void> _imagePicked(File image) async {
//     showProgress(context, "Uploading image...".tr(), false);
//     File compressedImage = await FireStoreUtils.compressImage(image);
//     final bytes = compressedImage.readAsBytesSync().lengthInBytes;
//     final kb = bytes / 1024;
//     final mb = kb / 1024;

//     if (mb > 2) {
//       hideProgress();
//       showAlertDialog(context, "error".tr(),
//           "Select an image that is less than 2MB".tr(), true);
//       return;
//     }
//     user.profilePictureURL = await FireStoreUtils.uploadUserImageToFireStorage(
//         compressedImage, user.userID);
//     await FireStoreUtils.updateCurrentUser(user);
//     MyAppState.currentUser = user;
//     hideProgress();
//   }
// }

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gromart_customer/constants.dart';
import 'package:gromart_customer/main.dart';
import 'package:gromart_customer/model/User.dart';
import 'package:gromart_customer/services/FirebaseHelper.dart';
import 'package:gromart_customer/services/helper.dart';
import 'package:gromart_customer/ui/accountDetails/AccountDetailsScreen.dart';
import 'package:gromart_customer/ui/auth/AuthScreen.dart';
import 'package:gromart_customer/ui/dineInScreen/my_booking_screen.dart';
import 'package:gromart_customer/ui/login/LoginScreen.dart';
import 'package:gromart_customer/ui/ordersScreen/OrdersScreen.dart';
import 'package:gromart_customer/ui/privacy_policy/privacy_policy.dart';
import 'package:gromart_customer/ui/termsAndCondition/terms_and_codition.dart';
import 'package:gromart_customer/utils/DarkThemeProvider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  late User user;

  @override
  void initState() {
    user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    print("profile pic: ${user.profilePictureURL}");
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Color(DARK_COLOR) : null,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: Container(
                color: Colors.green,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20, left: 20),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'My Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: <Widget>[
                                    user.profilePictureURL.isEmpty
                                        ? CircleAvatar(
                                            backgroundColor: Colors.white,
                                            radius: 40,
                                            backgroundImage: AssetImage('assets/images/pngwing.png'),
                                          )
                                        : CircleAvatar(
                                            backgroundColor: Colors.white,
                                            radius: 40,
                                            backgroundImage: NetworkImage(user.profilePictureURL),
                                          ),
                                    Positioned(
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        child: FloatingActionButton(
                                          backgroundColor: Color(COLOR_ACCENT),
                                          child: Icon(
                                            Icons.camera_alt,
                                            size: 18,
                                            color: isDarkMode(context) ? Colors.black : Colors.white,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          onPressed: _onCameraClick,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.fullName(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      user.email,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Row(
                              children: [
                                !themeChange.darkTheme
                                    ? const Icon(Icons.light_mode_sharp)
                                    : const Icon(Icons.nightlight),
                                Transform.scale(
                                  scale: 0.8,
                                  child: CupertinoSwitch(
                                    // thumb color (round icon)
                                    // splashRadius: 50.0,
                                    // activeThumbImage: const AssetImage('https://lists.gnu.org/archive/html/emacs-devel/2015-10/pngR9b4lzUy39.png'),
                                    // inactiveThumbImage: const AssetImage('http://wolfrosch.com/_img/works/goodies/icon/vim@2x'),

                                    value: themeChange.darkTheme,
                                    trackColor: Colors.white,
                                    onChanged: (value) => setState(() => themeChange.darkTheme = value),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Profile'),
              onTap: () {
                push(context, AccountDetailsScreen(user: user));
              },
              trailing: Icon(Icons.arrow_forward_ios_rounded),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Divider(),
            ),
            // ListTile(
            //   leading: Icon(Icons.lock),
            //   title: Text('Change Password'),
            //   onTap: () {
            //     // Functionality to change password
            //   },
            //   trailing: Icon(Icons.arrow_forward_ios_rounded),
            // ),

            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 12.0),
            //   child: Divider(),
            // ),
            // ListTile(
            //   leading: Icon(Icons.payment),
            //   title: Text('Payment Method'),
            //   onTap: () {
            //     // Functionality to manage payment method
            //   },
            //   trailing: Icon(Icons.arrow_forward_ios_rounded),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Divider(),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('My Orders'),
              onTap: () {
                // Functionality to view orders
                // push(context, OrdersScreen());
                push(context, MyBookingScreen());
              },
              trailing: Icon(Icons.arrow_forward_ios_rounded),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Divider(),
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip),
              title: Text('Privacy Policy'),
              onTap: () {
                push(context, PrivacyPolicyScreen());
              },
              //tri.pathi.gaurav888@gmail.com
              trailing: Icon(Icons.arrow_forward_ios_rounded),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Divider(),
            ),
            ListTile(
              leading: Icon(Icons.verified_user),
              title: Text('Terms & Conditions'),
              onTap: () {
                push(context, TermsAndCondition());
              },
              trailing: Icon(Icons.arrow_forward_ios_rounded),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  child: Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onPressed: () async {
                    user.lastOnlineTimestamp = Timestamp.now();
                    await FireStoreUtils.updateCurrentUser(user);
                    await auth.FirebaseAuth.instance.signOut();
                    MyAppState.currentUser = null;
                    pushAndRemoveUntil(context, LoginScreen(), false);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onCameraClick() {
    final action = CupertinoActionSheet(
      message: Text(
        "Add profile picture",
        style: TextStyle(fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text("Remove Picture").tr(),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);
            showProgress(context, "Removing picture...".tr(), false);
            user.profilePictureURL = '';
            await FireStoreUtils.updateCurrentUser(user);
            MyAppState.currentUser = user;
            hideProgress();
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text("Choose from gallery").tr(),
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              await _imagePicked(File(image.path));
            }
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text("Take a picture").tr(),
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              await _imagePicked(File(image.path));
            }
            setState(() {});
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel').tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  Future<void> _imagePicked(File image) async {
    showProgress(context, "Uploading image...".tr(), false);
    File compressedImage = await FireStoreUtils.compressImage(image);
    final bytes = compressedImage.readAsBytesSync().lengthInBytes;
    final kb = bytes / 1024;
    final mb = kb / 1024;

    if (mb > 2) {
      hideProgress();
      showAlertDialog(context, "error".tr(), "Select an image that is less than 2MB".tr(), true);
      return;
    }
    user.profilePictureURL = await FireStoreUtils.uploadUserImageToFireStorage(compressedImage, user.userID);
    await FireStoreUtils.updateCurrentUser(user);
    MyAppState.currentUser = user;
    hideProgress();
  }
}
