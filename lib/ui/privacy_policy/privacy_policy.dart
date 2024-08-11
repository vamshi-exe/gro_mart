import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:gromart_customer/AppGlobal.dart';
import 'package:gromart_customer/constants.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String? termsAndCondition;

  @override
  void initState() {
    FirebaseFirestore.instance.collection(Setting).doc("privacyPolicy").get().then((value) {
      setState(() {
        termsAndCondition = value['privacy_policy'];
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppGlobal.buildSimpleAppBar(context, 'Privacy Policy', isCenter: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: termsAndCondition != null
                ? HtmlWidget(
                    // the first parameter (`html`) is required
                    '''
                  $termsAndCondition
                     ''',
                    onErrorBuilder: (context, element, error) => Text('$element ${"error:".tr()} $error'),
                    onLoadingBuilder: (context, element, loadingProgress) => const CircularProgressIndicator(),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
