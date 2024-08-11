import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gromart_customer/AppGlobal.dart';
import 'package:gromart_customer/constants.dart';
import 'package:gromart_customer/main.dart';
import 'package:gromart_customer/model/AddressModel.dart';
import 'package:gromart_customer/model/BannerModel.dart';
import 'package:gromart_customer/model/FavouriteModel.dart';
import 'package:gromart_customer/model/ProductModel.dart';
import 'package:gromart_customer/model/User.dart';
import 'package:gromart_customer/model/VendorCategoryModel.dart';
import 'package:gromart_customer/model/VendorModel.dart';
import 'package:gromart_customer/model/offer_model.dart';
import 'package:gromart_customer/model/story_model.dart';
import 'package:gromart_customer/services/FirebaseHelper.dart';
import 'package:gromart_customer/services/helper.dart';
import 'package:gromart_customer/services/localDatabase.dart';
import 'package:gromart_customer/ui/categoryDetailsScreen/CategoryDetailsScreen.dart';
import 'package:gromart_customer/ui/cuisinesScreen/CuisinesScreen.dart';
import 'package:gromart_customer/ui/deliveryAddressScreen/DeliveryAddressScreen.dart';
import 'package:gromart_customer/ui/home/view_all_category_product_screen.dart';
import 'package:gromart_customer/ui/home/view_all_new_arrival_restaurant_screen.dart';
import 'package:gromart_customer/ui/home/view_all_offer_screen.dart';
import 'package:gromart_customer/ui/home/view_all_popular_food_near_by_screen.dart';
import 'package:gromart_customer/ui/home/view_all_popular_restaurant_screen.dart';
import 'package:gromart_customer/ui/home/view_all_restaurant.dart';
import 'package:gromart_customer/ui/productDetailsScreen/ProductDetailsScreen.dart';
import 'package:gromart_customer/ui/vendorProductsScreen/newVendorProductsScreen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gromart_customer/widget/permission_dialog.dart';
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_view/story_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';

class HomeScreen extends StatefulWidget {
  final User? user;

  HomeScreen({Key? key, this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final fireStoreUtils = FireStoreUtils();

  late Future<List<ProductModel>> productsFuture;
  final PageController _controller = PageController(viewportFraction: 1, keepPage: true);
  List<VendorModel> vendors = [];
  List<VendorModel> popularRestaurantLst = [];
  List<VendorModel> newArrivalLst = [];
  List<VendorModel> offerVendorList = [];
  List<OfferModel> offersList = [];
  Stream<List<VendorModel>>? lstAllRestaurant;
  List<ProductModel> lstNearByFood = [];

  //Stream<List<FavouriteModel>>? lstFavourites;
  late Future<List<FavouriteModel>> lstFavourites;
  List<String> lstFav = [];

  String? name = "";
  bool showLoader = true;

  String? selctedOrderTypeValue = "Delivery".tr();

  bool isLocationPermissionAllowed = false;
  loc.Location location = loc.Location();

  // Database db;

  @override
  void initState() {
    super.initState();
    getLocationData();
    getBanner();
    getTopPickDetails();
  }

  getTopPickDetails() async {
    fireStoreUtils.getRestaurantNearBy().whenComplete(() {
      lstAllRestaurant = fireStoreUtils.getAllRestaurants().asBroadcastStream();
      lstAllRestaurant!.listen((event) {
        print(event.toString() + "==={}{}===");
        vendors.clear();
        vendors.addAll(event);
      });
      if (selctedOrderTypeValue == "Delivery") {
        productsFuture = fireStoreUtils.getAllDelevryProducts();
      } else {
        productsFuture = fireStoreUtils.getAllTakeAWayProducts();
      }

      productsFuture.then((value) {
        lstNearByFood.addAll(value);
        setState(() {
          showLoader = false;
        });
      });
    });
  }

  List<VendorCategoryModel> categoryWiseProductList = [];

  List<BannerModel> bannerTopHome = [];
  List<BannerModel> bannerMiddleHome = [];

  bool isHomeBannerLoading = true;
  bool isHomeBannerMiddleLoading = true;
  List<OfferModel> offerList = [];
  bool? storyEnable = false;

  getBanner() async {
    await fireStoreUtils.getHomeTopBanner().then((value) {
      setState(() {
        bannerTopHome = value;
        isHomeBannerLoading = false;
      });
    });

    await fireStoreUtils.getHomePageShowCategory().then((value) {
      setState(() {
        categoryWiseProductList = value;
      });
    });

    await fireStoreUtils.getHomeMiddleBanner().then((value) {
      setState(() {
        bannerMiddleHome = value;
        isHomeBannerMiddleLoading = false;
      });
    });
    await FireStoreUtils().getPublicCoupons().then((value) {
      setState(() {
        offerList = value;
      });
    });

    await FirebaseFirestore.instance.collection(Setting).doc('story').get().then((value) {
      setState(() {
        storyEnable = value.data()!['isEnabled'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: isDarkMode(context) ? const Color(DARK_BG_COLOR) : const Color(0xffFFFFFF),
        body: isLoading == true
            ? Center(child: CircularProgressIndicator())
            : (MyAppState.selectedPosotion.location!.latitude == 0 &&
                    MyAppState.selectedPosotion.location!.longitude == 0)
                ? Center(
                    child: showEmptyState("We don't have your location.".tr(), context,
                        description: "Set your location to started searching for stores in your area".tr(),
                        action: () async {
                      checkPermission(
                        () async {
                          await showProgress(context, "Please wait...".tr(), false);
                          AddressModel addressModel = AddressModel();
                          try {
                            await Geolocator.requestPermission();
                            await Geolocator.getCurrentPosition();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlacePicker(
                                  apiKey: GOOGLE_API_KEY,
                                  onPlacePicked: (result) async {
                                    await hideProgress();
                                    AddressModel addressModel = AddressModel();
                                    addressModel.locality = result.formattedAddress!.toString();
                                    addressModel.location = UserLocation(
                                        latitude: result.geometry!.location.lat,
                                        longitude: result.geometry!.location.lng);
                                    MyAppState.selectedPosotion = addressModel;
                                    setState(() {});
                                    getData();
                                    Navigator.of(context).pop();
                                  },
                                  initialPosition: LatLng(-33.8567844, 151.213108),
                                  useCurrentLocation: true,
                                  selectInitialPosition: true,
                                  usePinPointingSearch: true,
                                  usePlaceDetailSearch: true,
                                  zoomGesturesEnabled: true,
                                  zoomControlsEnabled: true,
                                  resizeToAvoidBottomInset:
                                      false, // only works in page mode, less flickery, remove if wrong offsets
                                ),
                              ),
                            );
                          } catch (e) {
                            await placemarkFromCoordinates(19.228825, 72.854118).then((valuePlaceMaker) {
                              Placemark placeMark = valuePlaceMaker[0];
                              setState(() {
                                addressModel.location = UserLocation(latitude: 19.228825, longitude: 72.854118);
                                String currentLocation =
                                    "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
                                addressModel.locality = currentLocation;
                              });
                            });

                            MyAppState.selectedPosotion = addressModel;
                            await hideProgress();
                            getData();
                          }
                        },
                      );
                    }, buttonTitle: 'Select'.tr()),
                  )
                : SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          color: isDarkMode(context) ? const Color(DARK_COLOR) : const Color(0xffFFFFFF),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10, top: 8),
                                child: Container(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                        left: 10,
                                        right: 10,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.zero,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              color: AppColors.MAIN_GREEN,
                                              size: 24,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      if (MyAppState.currentUser != null) {
                                                        await Navigator.of(context)
                                                            .push(MaterialPageRoute(
                                                                builder: (context) => DeliveryAddressScreen()))
                                                            .then((value) {
                                                          if (value != null) {
                                                            AddressModel addressModel = value;
                                                            MyAppState.selectedPosotion = addressModel;
                                                            setState(() {});
                                                            getData();
                                                          }
                                                        });
                                                      } else {
                                                        checkPermission(
                                                          () async {
                                                            await showProgress(context, "Please wait...".tr(), true);
                                                            AddressModel addressModel = AddressModel();
                                                            try {
                                                              await Geolocator.requestPermission();
                                                              await Geolocator.getCurrentPosition();
                                                              await hideProgress();
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => PlacePicker(
                                                                    apiKey: GOOGLE_API_KEY,
                                                                    onPlacePicked: (result) async {
                                                                      print("-========>$GOOGLE_API_KEY");
                                                                      print(result);
                                                                      await hideProgress();
                                                                      AddressModel addressModel = AddressModel();
                                                                      addressModel.locality =
                                                                          result.formattedAddress!.toString();
                                                                      addressModel.location = UserLocation(
                                                                          latitude: result.geometry!.location.lat,
                                                                          longitude: result.geometry!.location.lng);
                                                                      MyAppState.selectedPosotion = addressModel;
                                                                      setState(() {});
                                                                      getData();
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                    initialPosition: LatLng(-33.8567844, 151.213108),
                                                                    useCurrentLocation: true,
                                                                    selectInitialPosition: true,
                                                                    usePinPointingSearch: true,
                                                                    usePlaceDetailSearch: true,
                                                                    zoomGesturesEnabled: true,
                                                                    zoomControlsEnabled: true,
                                                                    resizeToAvoidBottomInset:
                                                                        false, // only works in page mode, less flickery, remove if wrong offsets
                                                                  ),
                                                                ),
                                                              );
                                                            } catch (e) {
                                                              await placemarkFromCoordinates(19.228825, 72.854118)
                                                                  .then((valuePlaceMaker) {
                                                                Placemark placeMark = valuePlaceMaker[0];
                                                                setState(() {
                                                                  addressModel.location = UserLocation(
                                                                      latitude: 19.228825, longitude: 72.854118);
                                                                  String currentLocation =
                                                                      "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
                                                                  addressModel.locality = currentLocation;
                                                                });
                                                              });

                                                              MyAppState.selectedPosotion = addressModel;
                                                              await hideProgress();
                                                              getData();
                                                            }
                                                          },
                                                        );
                                                      }
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          '${MyAppState.selectedPosotion.addressAs}',
                                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                                        ),
                                                        Icon(Icons.keyboard_arrow_down)
                                                      ],
                                                    ),
                                                  ),
                                                  Text(MyAppState.selectedPosotion.getFullAddress().toString(),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Color(GREY_TEXT_COLOR),
                                                        fontFamily: "Poppinsr",
                                                      )).tr(),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              splashRadius: 1,
                                              padding: EdgeInsets.zero,
                                              onPressed: () {},
                                              icon: Icon(Icons.local_mall_outlined),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: CupertinoSearchTextField(
                                            // focusNode: ,
                                            decoration: BoxDecoration(
                                                color: Colors.grey.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(6)),
                                            padding: EdgeInsets.all(12),
                                          )),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(Icons.tune, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Container(
                                    //     padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                                    //     child: Row(
                                    //       children: [
                                    //         Expanded(
                                    //           child:
                                    //               Text("Find your Store".tr(), style: TextStyle(fontSize: 22, color: Colors.white, fontFamily: "Poppinssb")).tr(),
                                    //         ),
                                    //         DropdownButton(
                                    //           // Not necessary for Option 1
                                    //           value: selctedOrderTypeValue,
                                    //           isDense: true,
                                    //           dropdownColor: Colors.black,
                                    //           onChanged: (newValue) async {
                                    //             int cartProd = 0;
                                    //             await Provider.of<CartDatabase>(context, listen: false).allCartProducts.then((value) {
                                    //               cartProd = value.length;
                                    //             });
                                    //
                                    //             if (cartProd > 0) {
                                    //               showDialog(
                                    //                 context: context,
                                    //                 builder: (BuildContext context) => ShowDialogToDismiss(
                                    //                   title: '',
                                    //                   content: "Do you really want to change the delivery option?".tr() + "Your cart will be empty".tr(),
                                    //                   buttonText: 'CLOSE'.tr(),
                                    //                   secondaryButtonText: 'OK'.tr(),
                                    //                   action: () {
                                    //                     Navigator.of(context).pop();
                                    //                     Provider.of<CartDatabase>(context, listen: false).deleteAllProducts();
                                    //                     setState(() {
                                    //                       selctedOrderTypeValue = newValue.toString();
                                    //                       saveFoodTypeValue();
                                    //                       getData();
                                    //                     });
                                    //                   },
                                    //                 ),
                                    //               );
                                    //             } else {
                                    //               setState(() {
                                    //                 selctedOrderTypeValue = newValue.toString();
                                    //
                                    //                 saveFoodTypeValue();
                                    //                 getData();
                                    //               });
                                    //             }
                                    //           },
                                    //           icon: const Icon(
                                    //             Icons.keyboard_arrow_down,
                                    //             color: Colors.white,
                                    //           ),
                                    //           items: [
                                    //             'Delivery'.tr(),
                                    //             'Takeaway'.tr(),
                                    //           ].map((location) {
                                    //             return DropdownMenuItem(
                                    //               child: Text(location, style: TextStyle(color: Colors.white)),
                                    //               value: location,
                                    //             );
                                    //           }).toList(),
                                    //         )
                                    //       ],
                                    //     )),
                                  ]),
                                ),
                              ),

                              buildTitleRow(
                                titleValue: "Shop by Category".tr(),
                                onClick: () {
                                  push(
                                    context,
                                    const CuisinesScreen(
                                      isPageCallFromHomeScreen: true,
                                    ),
                                  );
                                },
                              ),
                              Container(
                                color: isDarkMode(context) ? const Color(DARK_COLOR) : const Color(0xffFFFFFF),
                                child: FutureBuilder<List<VendorCategoryModel>>(
                                  future: fireStoreUtils.getCuisines(),
                                  initialData: const [],
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(
                                        child: CircularProgressIndicator.adaptive(
                                          valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                                        ),
                                      );
                                    }

                                    if ((snapshot.hasData || (snapshot.data?.isNotEmpty ?? false)) && mounted) {
                                      return GridView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: 6,
                                        itemBuilder: (context, index) {
                                          return buildCategoryItem(index, snapshot.data![index], snapshot.data!);
                                        },
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          childAspectRatio: 0.7,
                                        ),
                                      );
                                    } else {
                                      return showEmptyState('No Categories'.tr(), context);
                                    }
                                  },
                                ),
                              ),

                              Visibility(
                                visible: bannerTopHome.isNotEmpty,
                                child: Container(
                                  width: double.infinity,
                                  color: isDarkMode(context) ? const Color(DARK_COLOR) : const Color(0xffFFFFFF),
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: isHomeBannerLoading
                                      ? const Center(child: CircularProgressIndicator())
                                      : SizedBox(
                                          height: MediaQuery.of(context).size.height * 0.23,
                                          width: MediaQuery.of(context).size.width,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: PageView.builder(
                                              padEnds: false,
                                              itemCount: bannerTopHome.length,
                                              scrollDirection: Axis.horizontal,
                                              controller: _controller,
                                              itemBuilder: (context, index) {
                                                print("length is: ${bannerTopHome.length}");
                                                return buildBestDealPage(
                                                  bannerTopHome[index],
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  buildTitleRow(
                                    titleValue: "Top Picks".tr(),
                                    onClick: () {
                                      push(
                                        context,
                                        const ViewAllPopularFoodNearByScreen(),
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    height: 220,
                                    child: lstNearByFood.isEmpty
                                        ? showEmptyState('No popular Item found'.tr(), context)
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemCount: lstNearByFood.length >= 15 ? 15 : lstNearByFood.length,
                                            itemBuilder: (context, index) {
                                              VendorModel? popularNearFoodVendorModel;
                                              if (vendors.isNotEmpty) {
                                                for (int a = 0; a < vendors.length; a++) {
                                                  if (vendors[a].id == lstNearByFood[index].vendorID) {
                                                    popularNearFoodVendorModel = vendors[a];
                                                  }
                                                }
                                              }
                                              return popularNearFoodVendorModel == null
                                                  ? Container()
                                                  : popularFoodItem(
                                                      context, lstNearByFood[index], popularNearFoodVendorModel);
                                            }),
                                  ),
                                  SizedBox(
                                    height: 12,
                                  )
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  buildTitleRow(
                                    titleValue: "New Arrivals".tr(),
                                    onClick: () {
                                      push(
                                        context,
                                        const ViewAllNewArrivalRestaurantScreen(),
                                      );
                                    },
                                  ),
                                  StreamBuilder<List<VendorModel>>(
                                    stream: fireStoreUtils.getVendorsForNewArrival().asBroadcastStream(),
                                    initialData: const [],
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(
                                          child: CircularProgressIndicator.adaptive(
                                            valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                                          ),
                                        );
                                      }

                                      if ((snapshot.hasData || (snapshot.data?.isNotEmpty ?? false)) && mounted) {
                                        newArrivalLst = snapshot.data!;

                                        return newArrivalLst.isEmpty
                                            ? showEmptyState('No Vendors'.tr(), context)
                                            : Container(
                                                width: MediaQuery.of(context).size.width,
                                                height: 260,
                                                margin: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  scrollDirection: Axis.horizontal,
                                                  physics: const BouncingScrollPhysics(),
                                                  itemCount: newArrivalLst.length >= 15 ? 15 : newArrivalLst.length,
                                                  itemBuilder: (context, index) => buildNewArrivalItem(
                                                    newArrivalLst[index],
                                                  ),
                                                ),
                                              );
                                      } else {
                                        return showEmptyState('No Vendors'.tr(), context);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              // buildTitleRow(
                              //   titleValue: "Offers For You".tr(),
                              //   onClick: () {
                              //     push(
                              //       context,
                              //       OffersScreen(
                              //         vendors: vendors,
                              //       ),
                              //     );
                              //   },
                              // ),
                              // offerVendorList.isEmpty
                              //     ? showEmptyState('No Offers Found'.tr(), context)
                              //     : Container(
                              //         width: MediaQuery.of(context).size.width,
                              //         height: 300,
                              //         margin: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                              //         child: ListView.builder(
                              //           shrinkWrap: true,
                              //           scrollDirection: Axis.horizontal,
                              //           physics: const BouncingScrollPhysics(),
                              //           itemCount: offerVendorList.length >= 15 ? 15 : offerVendorList.length,
                              //           itemBuilder: (context, index) {
                              //             return buildCouponsForYouItem(
                              //                 context, offerVendorList[index], offersList[index]);
                              //           },
                              //         ),
                              //       ),
                              // middle
                              Visibility(
                                visible: bannerMiddleHome.isNotEmpty,
                                child: Container(
                                  color: isDarkMode(context) ? const Color(DARK_COLOR) : const Color(0xffFFFFFF),
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: isHomeBannerMiddleLoading
                                      ? const Center(child: CircularProgressIndicator())
                                      : SizedBox(
                                          height: MediaQuery.of(context).size.height * 0.23,
                                          // width: MediaQuery.of(context).size.width * 0.9,
                                          child: PageView.builder(
                                            padEnds: false,
                                            itemCount: bannerMiddleHome.length,
                                            scrollDirection: Axis.horizontal,
                                            controller: _controller,
                                            itemBuilder: (context, index) => buildBestDealPage(
                                              bannerMiddleHome[index],
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              // Column(
                              //   children: [
                              //     buildTitleRow(
                              //       titleValue: "Popular Stores".tr(),
                              //       onClick: () {
                              //         push(
                              //           context,
                              //           const ViewAllPopularRestaurantScreen(),
                              //         );
                              //       },
                              //     ),
                              //     popularRestaurantLst.isEmpty
                              //         ? showEmptyState('No Popular store'.tr(), context)
                              //         : Container(
                              //             width: MediaQuery.of(context).size.width,
                              //             height: 260,
                              //             margin: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                              //             child: ListView.builder(
                              //                 shrinkWrap: true,
                              //                 scrollDirection: Axis.horizontal,
                              //                 physics: const BouncingScrollPhysics(),
                              //                 itemCount: popularRestaurantLst.length >= 5 ? 5 : popularRestaurantLst.length,
                              //                 itemBuilder: (context, index) => buildPopularsItem(popularRestaurantLst[index]))),
                              //   ],
                              // ),
                              ListView.builder(
                                itemCount: categoryWiseProductList.length,
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  return StreamBuilder<List<VendorModel>>(
                                    stream: FireStoreUtils()
                                        .getCategoryRestaurants(categoryWiseProductList[index].id.toString()),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(
                                          child: CircularProgressIndicator.adaptive(
                                            valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                                          ),
                                        );
                                      }
                                      if ((snapshot.hasData || (snapshot.data?.isNotEmpty ?? false)) && mounted) {
                                        return snapshot.data!.isEmpty
                                            ? Container()
                                            : Column(
                                                children: [
                                                  buildTitleRow(
                                                    titleValue: categoryWiseProductList[index].title.toString(),
                                                    onClick: () {
                                                      push(
                                                        context,
                                                        ViewAllCategoryProductScreen(
                                                          vendorCategoryModel: categoryWiseProductList[index],
                                                        ),
                                                      );
                                                    },
                                                    isViewAll: false,
                                                  ),
                                                  SizedBox(
                                                      width: MediaQuery.of(context).size.width,
                                                      height: MediaQuery.of(context).size.height * 0.28,
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                                        child: ListView.builder(
                                                          shrinkWrap: true,
                                                          scrollDirection: Axis.horizontal,
                                                          physics: const BouncingScrollPhysics(),
                                                          padding: EdgeInsets.zero,
                                                          itemCount: snapshot.data!.length,
                                                          itemBuilder: (context, index) {
                                                            VendorModel vendorModel = snapshot.data![index];
                                                            double distanceInMeters = Geolocator.distanceBetween(
                                                                vendorModel.latitude,
                                                                vendorModel.longitude,
                                                                MyAppState.selectedPosotion.location!.latitude,
                                                                MyAppState.selectedPosotion.location!.longitude);
                                                            double kilometer = distanceInMeters / 1000;
                                                            double minutes = 1.2;
                                                            double value = minutes * kilometer;
                                                            final int hour = value ~/ 60;
                                                            final double minute = value % 60;
                                                            return Container(
                                                              margin: const EdgeInsets.symmetric(
                                                                  horizontal: 10, vertical: 8),
                                                              child: GestureDetector(
                                                                onTap: () async {
                                                                  push(
                                                                    context,
                                                                    NewVendorProductsScreen(vendorModel: vendorModel),
                                                                  );
                                                                },
                                                                child: SizedBox(
                                                                  width: MediaQuery.of(context).size.width * 0.65,
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(20),
                                                                      border: Border.all(
                                                                          color: isDarkMode(context)
                                                                              ? const Color(DarkContainerBorderColor)
                                                                              : Colors.grey.shade100,
                                                                          width: 1),
                                                                      color: isDarkMode(context)
                                                                          ? const Color(DarkContainerColor)
                                                                          : Colors.white,
                                                                      boxShadow: [
                                                                        isDarkMode(context)
                                                                            ? const BoxShadow()
                                                                            : BoxShadow(
                                                                                color: Colors.grey.withOpacity(0.5),
                                                                                blurRadius: 5,
                                                                              ),
                                                                      ],
                                                                    ),
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Expanded(
                                                                            child: Stack(
                                                                          children: [
                                                                            CachedNetworkImage(
                                                                              imageUrl:
                                                                                  getImageVAlidUrl(vendorModel.photo),
                                                                              imageBuilder: (context, imageProvider) =>
                                                                                  Container(
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.only(
                                                                                      topLeft: Radius.circular(20),
                                                                                      topRight: Radius.circular(20)),
                                                                                  image: DecorationImage(
                                                                                      image: imageProvider,
                                                                                      fit: BoxFit.cover),
                                                                                ),
                                                                              ),
                                                                              placeholder: (context, url) => Center(
                                                                                  child: CircularProgressIndicator
                                                                                      .adaptive(
                                                                                valueColor: AlwaysStoppedAnimation(
                                                                                    Color(COLOR_PRIMARY)),
                                                                              )),
                                                                              errorWidget: (context, url, error) =>
                                                                                  ClipRRect(
                                                                                borderRadius: BorderRadius.only(
                                                                                    topLeft: Radius.circular(20),
                                                                                    topRight: Radius.circular(20)),
                                                                                child: Image.network(
                                                                                  AppGlobal.placeHolderImage!,
                                                                                  width: MediaQuery.of(context)
                                                                                          .size
                                                                                          .width *
                                                                                      0.75,
                                                                                  fit: BoxFit.contain,
                                                                                ),
                                                                              ),
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                            Positioned(
                                                                              bottom: 10,
                                                                              right: 10,
                                                                              child: Container(
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.green,
                                                                                  borderRadius:
                                                                                      BorderRadius.circular(5),
                                                                                ),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.symmetric(
                                                                                      horizontal: 5, vertical: 2),
                                                                                  child: Row(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Text(
                                                                                          vendorModel.reviewsCount != 0
                                                                                              ? (vendorModel
                                                                                                          .reviewsSum /
                                                                                                      vendorModel
                                                                                                          .reviewsCount)
                                                                                                  .toStringAsFixed(1)
                                                                                              : 0.toString(),
                                                                                          style: const TextStyle(
                                                                                            fontFamily: "Poppinsm",
                                                                                            letterSpacing: 0.5,
                                                                                            fontSize: 12,
                                                                                            color: Colors.white,
                                                                                          )),
                                                                                      const SizedBox(width: 3),
                                                                                      const Icon(
                                                                                        Icons.star,
                                                                                        size: 16,
                                                                                        color: Colors.white,
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                        const SizedBox(height: 5),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.symmetric(horizontal: 5),
                                                                          child: Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(vendorModel.title,
                                                                                      maxLines: 1,
                                                                                      style: TextStyle(
                                                                                          fontFamily: "Poppinsm",
                                                                                          fontSize: 16,
                                                                                          fontWeight: FontWeight.w700,
                                                                                          letterSpacing: 0.2))
                                                                                  .tr(),
                                                                              const SizedBox(
                                                                                height: 5,
                                                                              ),
                                                                              Row(
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.location_pin,
                                                                                    color: Color(COLOR_PRIMARY),
                                                                                    size: 20,
                                                                                  ),
                                                                                  SizedBox(width: 5),
                                                                                  Expanded(
                                                                                    child: Text(vendorModel.location,
                                                                                            maxLines: 1,
                                                                                            style: TextStyle(
                                                                                                fontFamily: "Poppinsm",
                                                                                                color: isDarkMode(
                                                                                                        context)
                                                                                                    ? Colors.white
                                                                                                    : Colors.black
                                                                                                        .withOpacity(
                                                                                                            0.60)))
                                                                                        .tr(),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              const SizedBox(
                                                                                height: 5,
                                                                              ),
                                                                              Row(
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.timer_sharp,
                                                                                    color: Color(COLOR_PRIMARY),
                                                                                    size: 20,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  Text(
                                                                                    '${hour.toString().padLeft(2, "0")}h ${minute.toStringAsFixed(0).padLeft(2, "0")}m',
                                                                                    style: TextStyle(
                                                                                        fontFamily: "Poppinsm",
                                                                                        letterSpacing: 0.5,
                                                                                        color: isDarkMode(context)
                                                                                            ? Colors.white
                                                                                            : Colors.black
                                                                                                .withOpacity(0.60)),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 10,
                                                                                  ),
                                                                                  Icon(
                                                                                    Icons.my_location_sharp,
                                                                                    color: Color(COLOR_PRIMARY),
                                                                                    size: 20,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 10,
                                                                                  ),
                                                                                  Text(
                                                                                    "${kilometer.toDouble().toStringAsFixed(currencyModel!.decimal)} km",
                                                                                    style: TextStyle(
                                                                                        fontFamily: "Poppinsm",
                                                                                        letterSpacing: 0.5,
                                                                                        color: isDarkMode(context)
                                                                                            ? Colors.white
                                                                                            : Colors.black
                                                                                                .withOpacity(0.60)),
                                                                                  ).tr(),
                                                                                ],
                                                                              ),
                                                                              SizedBox(
                                                                                height: 5,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      )),
                                                ],
                                              );
                                      } else {
                                        return Container();
                                      }
                                    },
                                  );
                                },
                              ),
                              // buildTitleRow(
                              //   titleValue: "All Stores".tr(),
                              //   onClick: () {},
                              //   isViewAll: true,
                              // ),
                              // vendors.isEmpty
                              //     ? showEmptyState('No Vendors'.tr(), context)
                              //     : Container(
                              //         width: MediaQuery.of(context).size.width,
                              //         margin: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                              //         child: ListView.builder(
                              //           shrinkWrap: true,
                              //           scrollDirection: Axis.vertical,
                              //           physics: const BouncingScrollPhysics(),
                              //           itemCount: vendors.length > 15 ? 15 : vendors.length,
                              //           itemBuilder: (context, index) {
                              //             VendorModel vendorModel = vendors[index];
                              //             return buildAllRestaurantsData(vendorModel);
                              //           },
                              //         ),
                              //       ),
                              // Center(
                              //   child: Padding(
                              //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              //     child: SizedBox(
                              //       width: MediaQuery.of(context).size.width,
                              //       height: MediaQuery.of(context).size.height * 0.06,
                              //       child: ElevatedButton(
                              //         style: ElevatedButton.styleFrom(
                              //           backgroundColor: Color(COLOR_PRIMARY),
                              //           shape: RoundedRectangleBorder(
                              //             borderRadius: BorderRadius.circular(10.0),
                              //             side: BorderSide(
                              //               color: Color(COLOR_PRIMARY),
                              //             ),
                              //           ),
                              //         ),
                              //         child: Text(
                              //           'See All Stores around you'.tr(),
                              //           style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
                              //         ).tr(),
                              //         onPressed: () {
                              //           push(
                              //             context,
                              //             const ViewAllRestaurant(),
                              //           );
                              //         },
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  void checkPermission(Function() onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      SnackBar snack = SnackBar(
        content: const Text(
          'You have to allow location permission to use your location',
          style: TextStyle(color: Colors.white),
        ).tr(),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black,
      );
      ScaffoldMessenger.of(context).showSnackBar(snack);
    } else if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return PermissionDialog();
        },
      );
    } else {
      onTap();
    }
  }

  final StoryController controller = StoryController();

  Widget storyWidget() {
    return storyList.isEmpty
        ? Container()
        : Container(
            height: 190,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ListView.builder(
                itemCount: storyList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MoreStories(
                                  storyList: storyList,
                                  index: index,
                                )));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        child: Container(
                          height: 180,
                          width: 130,
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                  imageUrl: storyList[index].videoThumbnail.toString(),
                                  imageBuilder: (context, imageProvider) => Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                                      ),
                                  errorWidget: (context, url, error) => ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(
                                        AppGlobal.placeHolderImage!,
                                        fit: BoxFit.cover,
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.height,
                                      ))),
                              FutureBuilder(
                                  future: FireStoreUtils().getVendorByVendorID(storyList[index].vendorID.toString()),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    } else {
                                      if (snapshot.hasError)
                                        return Center(child: Text('${"Error:"} ${snapshot.error}'));
                                      else
                                        return Positioned(
                                            bottom: 0,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 8, right: 10, bottom: 10, top: 10),
                                              child: Text(
                                                snapshot.data != null ? snapshot.data!.title.toString() : "cdc",
                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                            ));
                                    }
                                  }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
  }

  Widget buildVendorItemData(
    BuildContext context,
    ProductModel product,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: getImageVAlidUrl(product.photo),
              height: 100,
              width: 100,
              memCacheHeight: 100,
              memCacheWidth: 100,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => Center(
                  child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
              )),
              errorWidget: (context, url, error) => ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  AppGlobal.placeHolderImage!,
                ),
              ),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontFamily: "Poppinsm",
                    fontSize: 18,
                    color: Color(0xff000000),
                  ),
                  maxLines: 1,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  product.description,
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: "Poppinsm",
                    fontSize: 16,
                    color: Color(0xff9091A4),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "${amountShow(amount: product.price)}",
                  style: TextStyle(
                    fontFamily: "Poppinsm",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(COLOR_PRIMARY),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget popularFoodItem(
    BuildContext context,
    ProductModel product,
    VendorModel popularNearFoodVendorModel,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        VendorModel? vendorModel = await FireStoreUtils.getVendor(product.vendorID);
        if (vendorModel != null) {
          push(
            context,
            ProductDetailsScreen(
              vendorModel: vendorModel,
              productModel: product,
            ),
          );
        }
      },
      // onTap: () => push(
      //   context,
      //   NewVendorProductsScreen(vendorModel: popularNearFoodVendorModel),
      // ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
          color: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
          boxShadow: [
            isDarkMode(context)
                ? const BoxShadow()
                : BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 5,
                  ),
          ],
        ),
        width: MediaQuery.of(context).size.width * 0.4,
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  child: CachedNetworkImage(
                    imageUrl: getImageVAlidUrl(product.photo),
                    height: 100,
                    width: 100,
                    memCacheHeight: 100,
                    memCacheWidth: 100,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                    placeholder: (context, url) => Center(
                        child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                    )),
                    errorWidget: (context, url, error) => ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          AppGlobal.placeHolderImage!,
                          fit: BoxFit.cover,
                        )),
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontFamily: "Poppinsm",
                      fontSize: 18,
                      color: isDarkMode(context) ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                  ),
                  // const SizedBox(
                  //   height: 5,
                  // ),
                  // Text(
                  //   product.description,
                  //   maxLines: 1,
                  //   style: const TextStyle(
                  //     fontFamily: "Poppinsm",
                  //     fontSize: 16,
                  //     color: Color(0xff9091A4),
                  //   ),
                  // ),
                  Spacer(),

                  /*Text(
                    product.disPrice=="" || product.disPrice =="0"?"\$${product.price}":"\$${product.disPrice}",
                    style: TextStyle(
                      fontFamily: "Poppinsm",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffE87034),
                    ),
                  ),*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      product.disPrice == "" || product.disPrice == "0"
                          ? Text(
                              amountShow(amount: product.price),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "Poppinsm",
                                  letterSpacing: 0.5,
                                  color: Color(COLOR_PRIMARY)),
                            )
                          : Row(
                              children: [
                                Text(
                                  "${amountShow(amount: product.disPrice)}",
                                  style: TextStyle(
                                    fontFamily: "Poppinsm",
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(COLOR_PRIMARY),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '${amountShow(amount: product.price)}',
                                  style: const TextStyle(
                                      fontFamily: "Poppinsm",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough),
                                ),
                              ],
                            ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Color(COLOR_ACCENT)),
                          onPressed: () async {
                            await Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsScreen(
                                      productModel: product,
                                      vendorModel: VendorModel(),
                                    ),
                                  ),
                                )
                                .whenComplete(() => setState(() {}));
                          },
                          child: Text(
                            'Add',
                            style: TextStyle(color: AppColors.WHITE_COLOR),
                          ))
                    ],
                  ),

                  SizedBox(
                    height: 12,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildAllRestaurantsData(VendorModel vendorModel) {
    debugPrint(vendorModel.photo);
    List<OfferModel> tempList = [];
    List<double> discountAmountTempList = [];
    offerList.forEach((element) {
      if (vendorModel.id == element.restaurantId && element.expireOfferDate!.toDate().isAfter(DateTime.now())) {
        tempList.add(element);
        discountAmountTempList.add(double.parse(element.discount.toString()));
      }
    });
    return GestureDetector(
      onTap: () => push(
        context,
        NewVendorProductsScreen(vendorModel: vendorModel),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
            color: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
            boxShadow: [
              isDarkMode(context)
                  ? const BoxShadow()
                  : BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 5,
                    ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      // child: Image.network(height: 80,
                      //     width: 80,vendorModel.photo),
                      child: CachedNetworkImage(
                        imageUrl: vendorModel.photo,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              AppGlobal.placeHolderImage!,
                              fit: BoxFit.cover,
                            )),
                      ),
                    ),
                    if (discountAmountTempList.isNotEmpty)
                      Positioned(
                        bottom: -6,
                        left: -1,
                        child: Container(
                          decoration: const BoxDecoration(
                              image: DecorationImage(image: AssetImage('assets/images/offer_badge.png'))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              discountAmountTempList.reduce(min).toStringAsFixed(currencyModel!.decimal) + "% OFF".tr(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              vendorModel.title,
                              style: TextStyle(
                                fontFamily: "Poppinsm",
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode(context) ? Colors.white : Colors.black,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_pin,
                            size: 20,
                            color: Color(COLOR_PRIMARY),
                          ),
                          Expanded(
                            child: Text(
                              vendorModel.location,
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: "Poppinsm",
                                color: isDarkMode(context) ? Colors.white70 : const Color(0xff9091A4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 20,
                            color: Color(COLOR_PRIMARY),
                          ),
                          const SizedBox(width: 3),
                          Text(
                              vendorModel.reviewsCount != 0
                                  ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}'
                                  : 0.toString(),
                              style: TextStyle(
                                fontFamily: "Poppinsm",
                                letterSpacing: 0.5,
                                color: isDarkMode(context) ? Colors.white : const Color(0xff000000),
                              )),
                          const SizedBox(width: 3),
                          Text('(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                              style: TextStyle(
                                fontFamily: "Poppinsm",
                                letterSpacing: 0.5,
                                color: isDarkMode(context) ? Colors.white60 : const Color(0xff666666),
                              )),
                          const SizedBox(width: 5),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildCategoryItem(int index, VendorCategoryModel model, List<VendorCategoryModel> categoryList) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          print('index is: $index');
          push(
              context,
              CategoryDetailsScreen(
                vendorModel: VendorModel(),
                title: model.title ?? '',
                list: categoryList,
                index: index,
              )
              // CategoryDetailsScreen(
              //   category: model,
              //   isDineIn: false,
              // ),
              );
        },
        child: Container(
          // color: Colors.amber,
          child: Column(
            children: [
              CachedNetworkImage(
                imageUrl: getImageVAlidUrl(model.photo.toString()),
                imageBuilder: (context, imageProvider) => Container(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                          color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100,
                          width: 1),
                      color: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
                      boxShadow: [
                        isDarkMode(context)
                            ? const BoxShadow()
                            : BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 5,
                              ),
                      ],
                    ),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )),
                    ),
                  ),
                ),
                memCacheHeight: (MediaQuery.of(context).size.height * 0.15).toInt(),
                memCacheWidth: (MediaQuery.of(context).size.width * 0.23).toInt(),
                placeholder: (context, url) => ClipOval(
                  child: Container(
                    child: Icon(
                      Icons.fastfood,
                      color: Color(COLOR_PRIMARY),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      AppGlobal.placeHolderImage!,
                      fit: BoxFit.cover,
                    )),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  model.title.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode(context) ? Colors.white : const Color(0xFF000000),
                    fontFamily: "Poppinsr",
                  ),
                ).tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    fireStoreUtils.closeVendorStream();
    fireStoreUtils.closeNewArrivalStream();
    super.dispose();
  }

  Widget buildBestDealPage(BannerModel categoriesModel) {
    return InkWell(
      onTap: () async {
        if (categoriesModel.redirect_type == "store") {
          VendorModel? vendorModel = await FireStoreUtils.getVendor(categoriesModel.redirect_id.toString());
          push(
            context,
            NewVendorProductsScreen(vendorModel: vendorModel!),
          );
        } else if (categoriesModel.redirect_type == "product") {
          ProductModel? productModel =
              await fireStoreUtils.getProductByProductID(categoriesModel.redirect_id.toString());
          VendorModel? vendorModel = await FireStoreUtils.getVendor(productModel.vendorID);

          if (vendorModel != null) {
            push(
              context,
              ProductDetailsScreen(
                vendorModel: vendorModel,
                productModel: productModel,
              ),
            );
          }
        } else if (categoriesModel.redirect_type == "external_link") {
          final uri = Uri.parse(categoriesModel.redirect_id.toString());
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            throw "Could not launch".tr() + " ${categoriesModel.redirect_id.toString()}";
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: CachedNetworkImage(
            // width: MediaQuery.of(context).size.width,
            imageUrl: getImageVAlidUrl(categoriesModel.photo.toString()),
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            color: Colors.black.withOpacity(0.5),
            placeholder: (context, url) => Center(
                child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
            )),
            errorWidget: (context, url, error) => ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  AppGlobal.placeHolderImage!,
                  width: MediaQuery.of(context).size.width * 0.75,
                  fit: BoxFit.fitWidth,
                )),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  openCouponCode(
    BuildContext context,
    OfferModel offerModel,
  ) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              margin: const EdgeInsets.only(
                left: 40,
                right: 40,
              ),
              padding: const EdgeInsets.only(
                left: 50,
                right: 50,
              ),
              decoration:
                  const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/offer_code_bg.png"))),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  offerModel.offerCode!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: 0.9),
                ),
              )),
          GestureDetector(
            onTap: () {
              FlutterClipboard.copy(offerModel.offerCode!).then((value) {
                final SnackBar snackBar = SnackBar(
                  content: Text(
                    "Coupon code copied".tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.black38,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return Navigator.pop(context);
              });
            },
            child: Container(
              margin: const EdgeInsets.only(top: 30, bottom: 30),
              child: Text(
                "COPY CODE".tr(),
                style: TextStyle(color: Color(COLOR_PRIMARY), fontWeight: FontWeight.w500, letterSpacing: 0.1),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            child: RichText(
              text: TextSpan(
                text: "Use code".tr(),
                style: const TextStyle(fontSize: 16.0, color: Colors.grey, fontWeight: FontWeight.w700),
                children: <TextSpan>[
                  TextSpan(
                    text: offerModel.offerCode,
                    style: TextStyle(color: Color(COLOR_PRIMARY), fontWeight: FontWeight.w500, letterSpacing: 0.1),
                  ),
                  TextSpan(
                    text: " & get".tr() +
                        " ${offerModel.discountType == "Fix Price" ? "${currencyModel!.symbol}" : ""}${offerModel.discount} ${offerModel.discountType == "Percentage" ? "% off".tr() : "off".tr()} ",
                    style: const TextStyle(fontSize: 16.0, color: Colors.grey, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNewArrivalItem(VendorModel vendorModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => push(
          context,
          NewVendorProductsScreen(vendorModel: vendorModel),
        ),
        child: SizedBox(
          // margin: EdgeInsets.all(5),
          width: MediaQuery.of(context).size.width * 0.75,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
              color: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
              boxShadow: [
                isDarkMode(context)
                    ? const BoxShadow()
                    : BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 5,
                      ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                    child: CachedNetworkImage(
                  imageUrl: getImageVAlidUrl(vendorModel.photo),
                  width: MediaQuery.of(context).size.width * 0.75,
                  memCacheWidth: (MediaQuery.of(context).size.width * 0.75).toInt(),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => Center(
                      child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                  )),
                  errorWidget: (context, url, error) => ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        AppGlobal.placeHolderImage!,
                        width: MediaQuery.of(context).size.width * 0.75,
                        fit: BoxFit.fitWidth,
                      )),
                  fit: BoxFit.cover,
                )),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 5, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vendorModel.title,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: "Poppinsm",
                            letterSpacing: 0.5,
                            color: isDarkMode(context) ? Colors.white : Colors.black,
                          )).tr(),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                            const AssetImage('assets/images/location3x.png'),
                            size: 15,
                            color: Color(COLOR_PRIMARY),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text(vendorModel.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: "Poppinsm",
                                  letterSpacing: 0.5,
                                  color: isDarkMode(context) ? Colors.white60 : const Color(0xff555353),
                                )),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 20,
                                  color: Color(COLOR_PRIMARY),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                    vendorModel.reviewsCount != 0
                                        ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}'
                                        : 0.toString(),
                                    style: TextStyle(
                                      fontFamily: "Poppinsm",
                                      letterSpacing: 0.5,
                                      color: isDarkMode(context) ? Colors.white : const Color(0xff000000),
                                    )),
                                const SizedBox(width: 3),
                                Text('(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                                    style: TextStyle(
                                      fontFamily: "Poppinsm",
                                      letterSpacing: 0.5,
                                      color: isDarkMode(context) ? Colors.white70 : const Color(0xff666666),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPopularsItem(VendorModel vendorModel) {
    if (!mounted) {
      return Container();
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => push(
          context,
          NewVendorProductsScreen(vendorModel: vendorModel),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
            color: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
            boxShadow: [
              isDarkMode(context)
                  ? const BoxShadow()
                  : BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 5,
                    ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                  child: CachedNetworkImage(
                imageUrl: getImageVAlidUrl(vendorModel.photo),
                memCacheWidth: (MediaQuery.of(context).size.width * 0.75).toInt(),
                memCacheHeight: 250,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => Center(
                    child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                )),
                errorWidget: (context, url, error) => ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    AppGlobal.placeHolderImage!,
                    width: MediaQuery.of(context).size.width * 0.75,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                fit: BoxFit.cover,
              )),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 5, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vendorModel.title,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: "Poppinsm",
                          letterSpacing: 0.5,
                          color: isDarkMode(context) ? Colors.white : const Color(0xff000000),
                        )).tr(),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImageIcon(
                          const AssetImage('assets/images/location3x.png'),
                          size: 15,
                          color: Color(COLOR_PRIMARY),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(vendorModel.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: "Poppinsm",
                                letterSpacing: 0.5,
                                color: isDarkMode(context) ? Colors.white70 : const Color(0xff555353),
                              )),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 20,
                                color: Color(COLOR_PRIMARY),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                  vendorModel.reviewsCount != 0
                                      ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}'
                                      : 0.toString(),
                                  style: TextStyle(
                                    fontFamily: "Poppinsm",
                                    letterSpacing: 0.5,
                                    color: isDarkMode(context) ? Colors.white70 : const Color(0xff000000),
                                  )),
                              const SizedBox(width: 3),
                              Text('(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                                  style: TextStyle(
                                    fontFamily: "Poppinsm",
                                    letterSpacing: 0.5,
                                    color: isDarkMode(context) ? Colors.white60 : const Color(0xff666666),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCouponsForYouItem(BuildContext context1, VendorModel? vendorModel, OfferModel offerModel) {
    return vendorModel == null
        ? Container()
        : Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: GestureDetector(
              onTap: () {
                if (vendorModel.id.toString() == offerModel.restaurantId.toString()) {
                  push(
                    context,
                    NewVendorProductsScreen(vendorModel: vendorModel),
                  );
                } else {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    isDismissible: true,
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    backgroundColor: Colors.transparent,
                    enableDrag: true,
                    builder: (context) => openCouponCode(context, offerModel),
                  );
                }
              },
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade100, width: 0.1),
                          boxShadow: [
                            isDarkMode(context)
                                ? const BoxShadow()
                                : BoxShadow(
                                    color: Colors.grey.shade400,
                                    blurRadius: 8.0,
                                    spreadRadius: 1.2,
                                    offset: const Offset(0.2, 0.2),
                                  ),
                          ],
                          color: isDarkMode(context) ? const Color(DARK_BG_COLOR) : Colors.white),
                      child: Column(
                        children: [
                          Expanded(
                              child: CachedNetworkImage(
                            imageUrl: getImageVAlidUrl(offerModel.imageOffer!),
                            memCacheWidth: (MediaQuery.of(context).size.width * 0.75).toInt(),
                            memCacheHeight: MediaQuery.of(context).size.width.toInt(),
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            placeholder: (context, url) => Center(
                                child: CircularProgressIndicator.adaptive(
                              valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                            )),
                            errorWidget: (context, url, error) => ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                AppGlobal.placeHolderImage!,
                                width: MediaQuery.of(context).size.width * 0.75,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                            fit: BoxFit.cover,
                          )),
                          const SizedBox(height: 8),
                          vendorModel.id.toString() == offerModel.restaurantId.toString()
                              ? Container(
                                  margin: const EdgeInsets.fromLTRB(15, 0, 5, 0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(vendorModel.title,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: "Poppinsm",
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            color: isDarkMode(context) ? Colors.white : const Color(0xff000000),
                                          )).tr(),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ImageIcon(
                                            const AssetImage('assets/images/location3x.png'),
                                            size: 15,
                                            color: Color(COLOR_PRIMARY),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: Text(vendorModel.location,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: "Poppinsm",
                                                  letterSpacing: 0.5,
                                                  color: isDarkMode(context) ? Colors.white70 : const Color(0xff555353),
                                                )),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0, bottom: 10),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  offerModel.offerCode!,
                                                  style: TextStyle(
                                                    fontFamily: "Poppinsm",
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(COLOR_PRIMARY),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      size: 20,
                                                      color: Color(COLOR_PRIMARY),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                        vendorModel.reviewsCount != 0
                                                            ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}'
                                                            : 0.toString(),
                                                        style: TextStyle(
                                                          fontFamily: "Poppinsm",
                                                          letterSpacing: 0.5,
                                                          color: isDarkMode(context)
                                                              ? Colors.white
                                                              : const Color(0xff000000),
                                                        )),
                                                    const SizedBox(width: 3),
                                                    Text('(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                                                        style: TextStyle(
                                                          fontFamily: "Poppinsm",
                                                          letterSpacing: 0.5,
                                                          color: isDarkMode(context)
                                                              ? Colors.white60
                                                              : const Color(0xff666666),
                                                        )),
                                                    const SizedBox(width: 5),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : Container(
                                  margin: const EdgeInsets.fromLTRB(15, 0, 5, 8),
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("GroMart's Offer".tr(),
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppinsm",
                                            letterSpacing: 0.5,
                                            color: Color(0xff000000),
                                          )),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text("Apply Offer".tr(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: "Poppinsm",
                                            letterSpacing: 0.5,
                                            color: Color(0xff555353),
                                          )),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          FlutterClipboard.copy(offerModel.offerCode!)
                                              .then((value) => print('copied'.tr()));
                                        },
                                        child: Text(
                                          offerModel.offerCode!,
                                          style: TextStyle(
                                            fontFamily: "Poppinsm",
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(COLOR_PRIMARY),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                        ],
                      ),
                    ),
                    /* vendorModel.id.toString()==offerModel.restaurantId.toString()?*/
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        margin: const EdgeInsets.only(top: 150),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: const Image(image: AssetImage("assets/images/offer_badge.png"))),
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    "${offerModel.discountType == "Fix Price" ? "${currencyModel!.symbol}" : ""}${offerModel.discount}${offerModel.discountType == "Percentage" ? "% off".tr() : "off".tr()} ",
                                    style: const TextStyle(
                                        color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.7),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ) /*:Container()*/
                  ],
                ),
              ),
            ),
          );
  }

  Widget buildVendorItem(VendorModel vendorModel) {
    return GestureDetector(
      onTap: () => push(
        context,
        NewVendorProductsScreen(vendorModel: vendorModel),
      ),
      child: Container(
        height: 120,
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
          color: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
          boxShadow: [
            isDarkMode(context)
                ? const BoxShadow()
                : BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 5,
                  ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
                child: CachedNetworkImage(
              imageUrl: getImageVAlidUrl(vendorModel.photo),
              memCacheWidth: (MediaQuery.of(context).size.width).toInt(),
              memCacheHeight: 120,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => Center(
                  child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
              )),
              errorWidget: (context, url, error) =>
                  ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(AppGlobal.placeHolderImage!)),
              fit: BoxFit.cover,
            )),
            const SizedBox(height: 8),
            ListTile(
              title: Text(vendorModel.title,
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: "Poppinsm",
                    letterSpacing: 0.5,
                    color: Color(0xff000000),
                  )).tr(),
              subtitle: Row(
                children: [
                  ImageIcon(
                    AssetImage('assets/images/location3x.png'),
                    size: 15,
                    color: Color(COLOR_PRIMARY),
                  ),
                  SizedBox(
                    width: 200,
                    child: Text(vendorModel.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: "Poppinsm",
                          letterSpacing: 0.5,
                          color: Color(0xff555353),
                        )),
                  ),
                ],
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 20,
                          color: Color(COLOR_PRIMARY),
                        ),
                        const SizedBox(width: 3),
                        Text(
                            vendorModel.reviewsCount != 0
                                ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}'
                                : 0.toString(),
                            style: const TextStyle(
                              fontFamily: "Poppinsm",
                              letterSpacing: 0.5,
                              color: Color(0xff000000),
                            )),
                        const SizedBox(width: 3),
                        Text('(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                            style: const TextStyle(
                              fontFamily: "Poppinsm",
                              letterSpacing: 0.5,
                              color: Color(0xff666666),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> saveFoodTypeValue() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    sp.setString('foodType', selctedOrderTypeValue!);
  }

  getFoodType() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        selctedOrderTypeValue =
            sp.getString("foodType") == "" || sp.getString("foodType") == null ? "Delivery" : sp.getString("foodType");
      });
    }
    if (selctedOrderTypeValue == "Takeaway") {
      productsFuture = fireStoreUtils.getAllTakeAWayProducts();
    } else {
      productsFuture = fireStoreUtils.getAllDelevryProducts();
    }
  }

  bool isLoading = true;

  getLocationData() async {
    try {
      await getData();
    } catch (e) {
      getPermission();
    }
  }

  getPermission() async {
    setState(() {
      isLoading = false;
    });
    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        await getData();
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getData() async {
    getFoodType();
    lstNearByFood.clear();
    fireStoreUtils.getRestaurantNearBy().whenComplete(() async {
      lstAllRestaurant = fireStoreUtils.getAllRestaurants().asBroadcastStream();

      if (MyAppState.currentUser != null) {
        lstFavourites = fireStoreUtils.getFavouriteRestaurant(MyAppState.currentUser!.userID);
        lstFavourites.then((event) {
          lstFav.clear();
          for (int a = 0; a < event.length; a++) {
            lstFav.add(event[a].restaurantId!);
          }
        });
        name = toBeginningOfSentenceCase(widget.user!.firstName);
      }

      lstAllRestaurant!.listen((event) {
        vendors.clear();
        vendors.addAll(event);
        allstoreList.clear();
        allstoreList.addAll(event);
        productsFuture.then((value) {
          for (int a = 0; a < event.length; a++) {
            for (int d = 0; d < (value.length > 20 ? 20 : value.length); d++) {
              if (event[a].id == value[d].vendorID && !lstNearByFood.contains(value[d])) {
                lstNearByFood.add(value[d]);
              }
            }
          }
        });

        popularRestaurantLst.addAll(event);
        List<VendorModel> temp5 = popularRestaurantLst
            .where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) == 5)
            .toList();
        List<VendorModel> temp5_ = popularRestaurantLst
            .where((element) =>
                num.parse((element.reviewsSum / element.reviewsCount).toString()) > 4 &&
                num.parse((element.reviewsSum / element.reviewsCount).toString()) < 5)
            .toList();
        List<VendorModel> temp4 = popularRestaurantLst
            .where((element) =>
                num.parse((element.reviewsSum / element.reviewsCount).toString()) > 3 &&
                num.parse((element.reviewsSum / element.reviewsCount).toString()) < 4)
            .toList();
        List<VendorModel> temp3 = popularRestaurantLst
            .where((element) =>
                num.parse((element.reviewsSum / element.reviewsCount).toString()) > 2 &&
                num.parse((element.reviewsSum / element.reviewsCount).toString()) < 3)
            .toList();
        List<VendorModel> temp2 = popularRestaurantLst
            .where((element) =>
                num.parse((element.reviewsSum / element.reviewsCount).toString()) > 1 &&
                num.parse((element.reviewsSum / element.reviewsCount).toString()) < 2)
            .toList();
        List<VendorModel> temp1 = popularRestaurantLst
            .where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) == 1)
            .toList();
        List<VendorModel> temp0 = popularRestaurantLst
            .where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) == 0)
            .toList();
        List<VendorModel> temp0_ =
            popularRestaurantLst.where((element) => element.reviewsSum == 0 && element.reviewsCount == 0).toList();

        popularRestaurantLst.clear();
        popularRestaurantLst.addAll(temp5);
        popularRestaurantLst.addAll(temp5_);
        popularRestaurantLst.addAll(temp4);
        popularRestaurantLst.addAll(temp3);
        popularRestaurantLst.addAll(temp2);
        popularRestaurantLst.addAll(temp1);
        popularRestaurantLst.addAll(temp0);
        popularRestaurantLst.addAll(temp0_);

        FireStoreUtils().getPublicCoupons().then((value) {
          offersList.clear();
          offerVendorList.clear();
          value.forEach((element1) {
            event.forEach((element) {
              if (element1.restaurantId == element.id && element1.expireOfferDate!.toDate().isAfter(DateTime.now())) {
                offersList.add(element1);
                offerVendorList.add(element);
              }
            });
          });
          setState(() {});
        });

        FireStoreUtils().getStory().then((value) {
          storyList.clear();
          value.forEach((element1) {
            vendors.forEach((element) {
              if (element1.vendorID == element.id) {
                storyList.add(element1);
              }
            });
          });
          setState(() {});
        });
      });

      setState(() {});
    });
    setState(() {
      isLoading = false;
    });
  }

  List<StoryModel> storyList = [];
}

// ignore: camel_case_types
class buildTitleRow extends StatelessWidget {
  final String titleValue;
  final Function? onClick;
  final bool? isViewAll;

  const buildTitleRow({
    Key? key,
    required this.titleValue,
    this.onClick,
    this.isViewAll = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDarkMode(context) ? const Color(DARK_COLOR) : const Color(0xffFFFFFF),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titleValue.tr(),
                  style: TextStyle(
                      color: isDarkMode(context) ? Colors.white : const Color(0xFF000000),
                      fontFamily: "Poppinsm",
                      fontSize: 18)),
              isViewAll!
                  ? Container()
                  : GestureDetector(
                      onTap: () {
                        onClick!.call();
                      },
                      child:
                          Text('View All'.tr(), style: TextStyle(color: Color(COLOR_ACCENT), fontFamily: "Poppinsm")),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class MoreStories extends StatefulWidget {
  List<StoryModel> storyList = [];
  int index;

  MoreStories({Key? key, required this.index, required this.storyList}) : super(key: key);

  @override
  _MoreStoriesState createState() => _MoreStoriesState();
}

class _MoreStoriesState extends State<MoreStories> {
  final storyController = StoryController();

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        StoryView(
            storyItems: List.generate(
              widget.storyList[widget.index].videoUrl.length,
              (i) {
                return StoryItem.pageVideo(
                  widget.storyList[widget.index].videoUrl[i],
                  controller: storyController,
                );
              },
            ).toList(),
            // onStoryShow: (s) {
            //   debugPrint("Showing a story");
            // },
            onComplete: () {
              debugPrint("--------->");
              debugPrint(widget.storyList.length.toString());
              debugPrint(widget.index.toString());
              if (widget.storyList.length - 1 != widget.index) {
                // Navigator.pop(context);
                // Navigator.of(context).push(MaterialPageRoute(
                //     builder: (context) => MoreStories(
                //       storyList: widget.storyList,
                //       index: widget.index + 1,
                //     )));

                setState(() {
                  widget.index = widget.index + 1;
                });
              } else {
                Navigator.pop(context);
              }
            },
            progressPosition: ProgressPosition.top,
            repeat: true,
            controller: storyController,
            onVerticalSwipeComplete: (direction) {
              if (direction == Direction.down) {
                Navigator.pop(context);
              }
            }),
        FutureBuilder(
          future: FireStoreUtils().getVendorByVendorID(widget.storyList[widget.index].vendorID.toString()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Container());
            } else {
              if (snapshot.hasError) {
                return Center(child: Text("Error".tr() + ": ${snapshot.error}"));
              } else {
                VendorModel? vendorModel = snapshot.data;
                double distanceInMeters = Geolocator.distanceBetween(vendorModel!.latitude, vendorModel.longitude,
                    MyAppState.selectedPosotion.location!.latitude, MyAppState.selectedPosotion.location!.longitude);
                double kilometer = distanceInMeters / 1000;
                return Positioned(
                  top: 55,
                  child: InkWell(
                    onTap: () {
                      push(
                        context,
                        NewVendorProductsScreen(vendorModel: vendorModel),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: CachedNetworkImage(
                              imageUrl: vendorModel.photo,
                              height: 50,
                              width: 50,
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                              placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                              )),
                              errorWidget: (context, url, error) => ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.network(
                                    AppGlobal.placeHolderImage!,
                                    fit: BoxFit.cover,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                  )),
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(vendorModel.title.toString(),
                                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                              vendorModel.reviewsCount != 0
                                                  ? (vendorModel.reviewsSum / vendorModel.reviewsCount)
                                                      .toStringAsFixed(1)
                                                  : 0.toString(),
                                              style: const TextStyle(
                                                fontFamily: "Poppinsm",
                                                letterSpacing: 0.5,
                                                fontSize: 12,
                                                color: Colors.white,
                                              )),
                                          const SizedBox(width: 3),
                                          const Icon(
                                            Icons.star,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    Icons.location_pin,
                                    size: 16,
                                    color: Color(COLOR_PRIMARY),
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Text("${kilometer.toDouble().toStringAsFixed(currencyModel!.decimal)} KM",
                                      style: TextStyle(color: Colors.white, fontFamily: "Poppinsr")),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    height: 15,
                                    child: VerticalDivider(
                                      color: Colors.white,
                                      thickness: 2,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                      DateTime.now()
                                                  .difference(widget.storyList[widget.index].createdAt!.toDate())
                                                  .inDays ==
                                              0
                                          ? 'Today'.tr()
                                          : "${DateTime.now().difference(widget.storyList[widget.index].createdAt!.toDate()).inDays.toString()} d",
                                      style: TextStyle(color: Colors.white, fontFamily: "Poppinsr")),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
            }
          },
        )
      ],
    ));
  }
}
