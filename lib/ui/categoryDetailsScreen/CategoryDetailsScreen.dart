// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:gromart_customer/AppGlobal.dart';
// import 'package:gromart_customer/constants.dart';
// import 'package:gromart_customer/model/VendorCategoryModel.dart';
// import 'package:gromart_customer/model/VendorModel.dart';
// import 'package:gromart_customer/services/FirebaseHelper.dart';
// import 'package:gromart_customer/services/helper.dart';
// import 'package:gromart_customer/ui/dineInScreen/dine_in_restaurant_details_screen.dart';
// import 'package:gromart_customer/ui/vendorProductsScreen/newVendorProductsScreen.dart';

// class CategoryDetailsScreen extends StatefulWidget {
//   final VendorCategoryModel category;
//   final bool isDineIn;

//   const CategoryDetailsScreen(
//       {Key? key, required this.category, required this.isDineIn})
//       : super(key: key);

//   @override
//   _CategoryDetailsScreenState createState() => _CategoryDetailsScreenState();
// }

// class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
//   Stream<List<VendorModel>>? categoriesFuture;
//   final FireStoreUtils fireStoreUtils = FireStoreUtils();

//   @override
//   void initState() {
//     super.initState();
//     categoriesFuture = fireStoreUtils.getVendorsByCuisineID(
//         widget.category.id.toString(),
//         isDinein: widget.isDineIn);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppGlobal.buildSimpleAppBar(
//             context, widget.category.title.toString()),
//         body: StreamBuilder<List<VendorModel>>(
//           stream: categoriesFuture,
//           initialData: [],
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting)
//               return Container(
//                 child: Center(
//                   child: CircularProgressIndicator.adaptive(
//                     valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
//                   ),
//                 ),
//               );
//             if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
//               return Center(
//                 child: showEmptyState('No Store found'.tr(), context),
//               );
//             } else {
//               return ListView.builder(
//                 itemCount: snapshot.data!.length,
//                 itemBuilder: (context, index) =>
//                     buildVendorItem(snapshot.data![index]),
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }

//   buildVendorItem(VendorModel vendorModel) {
//     return GestureDetector(
//       onTap: () {
//         if (widget.isDineIn) {
//           push(
//             context,
//             DineInRestaurantDetailsScreen(vendorModel: vendorModel),
//           );
//         } else {
//           push(
//             context,
//             NewVendorProductsScreen(vendorModel: vendorModel),
//           );
//         }
//       },
//       child: Card(
//         elevation: 0.5,
//         color: isDarkMode(context) ? Colors.grey.shade900 : Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(
//             Radius.circular(20),
//           ),
//         ),
//         margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         child: Container(
//           height: 200,

//           // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           // margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//           child: Column(
//             // mainAxisSize: MainAxisSize.max,
//             // crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Expanded(
//                 child: CachedNetworkImage(
//                   imageUrl: getImageVAlidUrl(vendorModel.photo),
//                   imageBuilder: (context, imageProvider) => Container(
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         image: DecorationImage(
//                             image: imageProvider, fit: BoxFit.cover)),
//                   ),
//                   placeholder: (context, url) => Center(
//                       child: CircularProgressIndicator.adaptive(
//                     valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
//                   )),
//                   errorWidget: (context, url, error) => ClipRRect(
//                       borderRadius: BorderRadius.circular(20),
//                       child: Image.network(
//                         AppGlobal.placeHolderImage!,
//                         fit: BoxFit.fitWidth,
//                         width: MediaQuery.of(context).size.width,
//                       )),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               // SizedBox(height: 8),
//               ListTile(
//                 title: Text(vendorModel.title,
//                     maxLines: 1,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: isDarkMode(context)
//                           ? Colors.grey.shade400
//                           : Colors.grey.shade800,
//                       fontFamily: 'Poppinssb',
//                     )),
//                 subtitle: Text(vendorModel.location,
//                     maxLines: 1,

//                     // filters.keys
//                     //     .where(
//                     //         (element) => vendorModel.filters[element] == 'Yes')
//                     //     .take(2)
//                     //     .join(', '),

//                     style: TextStyle(
//                       fontFamily: 'Poppinssm',
//                     )),
//                 trailing: Padding(
//                   padding: const EdgeInsets.only(top: 8.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Wrap(
//                           spacing: 8,
//                           crossAxisAlignment: WrapCrossAlignment.center,
//                           children: <Widget>[
//                             Icon(
//                               Icons.star,
//                               size: 20,
//                               color: Color(COLOR_PRIMARY),
//                             ),
//                             Text(
//                               (vendorModel.reviewsCount != 0)
//                                   ? (vendorModel.reviewsSum /
//                                           vendorModel.reviewsCount)
//                                       .toStringAsFixed(1)
//                                   : "0",
//                               style: TextStyle(
//                                 fontFamily: 'Poppinssb',
//                               ),
//                             ),
//                             Visibility(
//                                 visible: vendorModel.reviewsCount != 0,
//                                 child: Text(
//                                     "(${vendorModel.reviewsCount.toStringAsFixed(1)})")),
//                           ]),
//                     ],
//                   ),
//                 ),
//               ),
//               // SizedBox(height: 4),

//               // SizedBox(height: 4),
//               // Visibility(
//               //   visible: vendorModel.reviewsCount != 0,
//               //   child: RichText(
//               //     text: TextSpan(
//               //       style: TextStyle(
//               //           color: isDarkMode(context)
//               //               ? Colors.grey.shade200
//               //               : Colors.black),
//               //       children: [
//               //         TextSpan(
//               //             text:
//               //                 '${double.parse((vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(2))} '),
//               //         WidgetSpan(
//               //           child: Icon(
//               //             Icons.star,
//               //             size: 20,
//               //             color: Color(COLOR_PRIMARY),
//               //           ),
//               //         ),
//               //         TextSpan(text: ' (${vendorModel.reviewsCount})'),
//               //       ],
//               //     ),
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';

// // class Categorydetailsscreen extends StatelessWidget {
// //   const Categorydetailsscreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Vegetables & Fruits'),
// //         actions: [
// //           IconButton(
// //             icon: Icon(Icons.search),
// //             onPressed: () {},
// //           ),
// //         ],
// //       ),
// //       body: Row(
// //         children: [
// //           // Left side category list
// //           Container(
// //             width: 100,
// //             color: Colors.grey[200],
// //             child: ListView(
// //               children: [
// //                 CategoryTile('Fresh Vegetables', Icons.emoji_nature),
// //                 CategoryTile('Fresh Fruits', Icons.emoji_food_beverage),
// //                 CategoryTile('Seasonal', Icons.abc),
// //                 CategoryTile('Exotics', Icons.eco),
// //                 CategoryTile('Sprouts', Icons.grass),
// //                 CategoryTile('Leafies & Herbs', Icons.local_florist),
// //                 CategoryTile('Flowers & Leaves', Icons.local_florist),
// //               ],
// //             ),
// //           ),
// //           // Right side products grid
// //           Expanded(
// //             child: GridView.count(
// //               crossAxisCount: 2,
// //               padding: const EdgeInsets.all(8.0),
// //               crossAxisSpacing: 8.0,
// //               mainAxisSpacing: 8.0,
// //               children: List.generate(products.length, (index) {
// //                 return ProductCard(product: products[index]);
// //               }),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class CategoryTile extends StatelessWidget {
// //   final String title;
// //   final IconData icon;

// //   CategoryTile(this.title, this.icon);

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.center,
// //       children: [
// //         Icon(icon),
// //         Text(title),
// //       ],
// //     );
// //   }
// // }

// // class Product {
// //   final String name;
// //   final String weight;
// //   final String price;
// //   final String originalPrice;
// //   // final String imagePath;

// //   Product(
// //     this.name,
// //     this.weight,
// //     this.price,
// //     this.originalPrice,
// //   );
// // }

// // List<Product> products = [
// //   Product(
// //     'Hybrid Tomato (Tamatar)',
// //     '500 g',
// //     '\$8',
// //     '\$10',
// //   ),
// //   Product(
// //     'Lady Finger (Bhindi)',
// //     '250 g',
// //     '\$7',
// //     '\$10',
// //   ),
// //   Product(
// //     'Green Chilli (Hari Mirch)',
// //     '500 g',
// //     '\$5',
// //     '\$8',
// //   ),
// //   Product(
// //     'Cluster Beans (Gawar Phali)',
// //     '250 g',
// //     '\$12',
// //     '\$14',
// //   ),
// //   Product(
// //     'Cabbage (Patta Gobhi)',
// //     '500 g',
// //     '\$8',
// //     '\$10',
// //   ),
// //   Product(
// //     'Capsicum (Shimla Mirch)',
// //     '250 g',
// //     '\$7',
// //     '\$10',
// //   ),
// //   Product(
// //     'Baby Potato (Chota Aloo)',
// //     '500 g',
// //     '\$10',
// //     '\$14',
// //   ),
// //   Product(
// //     'Green Peas (Matar)',
// //     '250 g',
// //     '\$5',
// //     '\$10',
// //   ),
// // ];

// // class ProductCard extends StatelessWidget {
// //   final Product product;

// //   ProductCard({required this.product});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Card(
// //       elevation: 1,
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(8),
// //       ),
// //       child: Padding(
// //         padding: const EdgeInsets.all(8.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Container(
// //               height: 120, // Adjust height as needed for the image container
// //               decoration: BoxDecoration(
// //                 borderRadius: BorderRadius.circular(8),
// //                 color: Colors.grey[200],
// //               ),
// //               child: const Center(
// //                 child: Icon(Icons.image, size: 60, color: Colors.grey),
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             Text(
// //               product.name,
// //               style: const TextStyle(fontWeight: FontWeight.bold),
// //               maxLines: 2, // Allow up to 2 lines for the product name
// //               overflow: TextOverflow.ellipsis,
// //             ),
// //             const SizedBox(height: 4),
// //             Text(
// //               product.weight,
// //               style: TextStyle(color: Colors.grey[600], fontSize: 12),
// //             ),
// //             const SizedBox(height: 8),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       '\$${product.price}',
// //                       style: const TextStyle(fontWeight: FontWeight.bold),
// //                     ),
// //                     Text(
// //                       '\$${product.originalPrice}',
// //                       style: const TextStyle(
// //                         decoration: TextDecoration.lineThrough,
// //                         color: Colors.grey,
// //                         fontSize: 12,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 ElevatedButton(
// //                   child: const Text(
// //                     'Add',
// //                     style: TextStyle(color: Colors.white),
// //                   ),
// //                   onPressed: () {},
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: Colors.green,
// //                     padding:
// //                         const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:gromart_customer/AppGlobal.dart';

// class CategoryDetailsScreen extends StatefulWidget {
//   final String title;

//   const CategoryDetailsScreen({super.key, required this.title});

//   @override
//   State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
// }

// class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppGlobal.buildSimpleAppBar(context, widget.title),
//       body: ,
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:gromart_customer/main.dart';
import 'package:gromart_customer/model/FavouriteItemModel.dart';
import 'package:gromart_customer/model/ProductModel.dart';
import 'package:gromart_customer/model/VendorCategoryModel.dart';
import 'package:gromart_customer/model/VendorModel.dart';
import 'package:gromart_customer/model/offer_model.dart';
import 'package:gromart_customer/services/FirebaseHelper.dart';
import 'package:gromart_customer/services/helper.dart';
import 'package:gromart_customer/ui/auth/AuthScreen.dart';
import 'package:gromart_customer/ui/productDetailsScreen/ProductDetailsScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../AppGlobal.dart';
import '../../constants.dart';
import '../vendorProductsScreen/NewVendorProductsScreen.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final int index;
  final String title;
  final List<VendorCategoryModel> list;
  final VendorModel vendorModel;
  const CategoryDetailsScreen(
      {Key? key, required this.title, required this.list, required this.vendorModel, required this.index})
      : super(key: key);

  @override
  _CategoryDetailsScreenState createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  late Stream<List<VendorModel>> vendorsFuture;
  final fireStoreUtils = FireStoreUtils();
  Stream<List<VendorModel>>? lstAllStore;
  late Future<List<ProductModel>> productsFuture;
  List<ProductModel> lstNearByFood = [];
  List<VendorModel> vendors = [];
  bool showLoader = true;
  String? selctedOrderTypeValue = "Delivery";
  VendorModel? popularNearFoodVendorModel;
  int totItem = 0;
  int? selectedIndex;
  String? selectedCategory;
  List<FavouriteItemModel> lstFav = [];

  @override
  void initState() {
    setState(() {
      selectedCategory = widget.title;
      selectedIndex = widget.index;
    });
    super.initState();
    getFoodType();
    getData();
  }

  getData() async {
    fireStoreUtils.getRestaurantNearBy().whenComplete(() {
      lstAllStore = fireStoreUtils.getAllRestaurants().asBroadcastStream();
      lstAllStore!.listen((event) {
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

  List<ProductModel> productModel = [];
  String? foodType;
  List a = [];
  List<VendorCategoryModel> vendorCateoryModel = [];
  List<OfferModel> offerList = [];

  void getFoodType() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      selctedOrderTypeValue = sp.getString("foodType") == "" || sp.getString("foodType") == null
          ? "Delivery".tr()
          : sp.getString("foodType");
    });

    foodType = sp.getString("foodType") ?? "Delivery".tr();

    if (foodType == "Takeaway") {
      await fireStoreUtils.getVendorProductsTakeAWay(widget.vendorModel.id).then((value) {
        productModel.clear();
        productModel.addAll(value);
        getVendorCategoryById();
        setState(() {});
      });
    } else {
      await fireStoreUtils.getVendorProductsDelivery(widget.vendorModel.id).then((value) {
        productModel.clear();
        productModel.addAll(value);
        getVendorCategoryById();
        setState(() {});
      });
    }
  }

  getVendorCategoryById() async {
    vendorCateoryModel.clear();

    for (int i = 0; i < productModel.length; i++) {
      if (a.isNotEmpty && a.contains(productModel[i].categoryID)) {
      } else if (!a.contains(productModel[i].categoryID)) {
        a.add(productModel[i].categoryID);

        await fireStoreUtils.getVendorCategoryById(productModel[i].categoryID).then((value) {
          if (value != null) {
            setState(() {
              vendorCateoryModel.add(value);
            });
          }
        });
      }
    }

    await FireStoreUtils().getOfferByVendorID(widget.vendorModel.id).then((value) {
      setState(() {
        offerList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 242, 242, 242),
      appBar: AppGlobal.buildAppBar(context, selectedCategory!),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          margin: const EdgeInsets.fromLTRB(10, 0, 0, 10),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: widget.list.length,
                  itemBuilder: (context, index) {
                    if (vendors.isNotEmpty) {
                      popularNearFoodVendorModel = null;
                      for (int a = 0; a < vendors.length; a++) {
                        // print(vendors[a].id.toString() + "===<><><><==" + lstNearByFood[index].vendorID);
                        if (vendors[a].id == lstNearByFood[index].vendorID) {
                          popularNearFoodVendorModel = vendors[a];
                        }
                      }
                    }
                    return categoryListItem(index);
                  },
                ),
              ),
              Expanded(
                flex: 3,
                child: showLoader
                    ? Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                        ),
                      )
                    : lstNearByFood.isEmpty
                        ? showEmptyState('No top selling found'.tr(), context)
                        : GridView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: lstNearByFood.length,
                            itemBuilder: (context, index) {
                              if (vendors.isNotEmpty) {
                                print("item name ${lstNearByFood[index].name}");
                                popularNearFoodVendorModel = null;
                                for (int a = 0; a < vendors.length; a++) {
                                  print(vendors[a].id.toString() + "===<><><><==" + lstNearByFood[index].vendorID);
                                  if (vendors[a].id == lstNearByFood[index].vendorID) {
                                    popularNearFoodVendorModel = vendors[a];
                                  }
                                }
                              }
                              return popularNearFoodVendorModel == null
                                  ? (totItem == 0 && index == (lstNearByFood.length - 1))
                                      ? showEmptyState('No top selling found'.tr(), context)
                                      : Container()
                                  : buildVendorItemData(
                                      context, index, popularNearFoodVendorModel!, lstNearByFood[index]);
                            },
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7),
                          ),
              ),
            ],
          )),
    );
  }

  categoryListItem(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
          selectedCategory = widget.list[index].title;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CachedNetworkImage(
                      imageUrl: getImageVAlidUrl(widget.list[index].photo!),
                      height: 100,
                      width: 70,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                      )),
                      errorWidget: (context, url, error) => ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            AppGlobal.placeHolderImage!,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                          )),
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                Container(
                  width: 3,
                  height: 100,
                  color: selectedIndex == index ? Color(COLOR_ACCENT) : Colors.transparent,
                )
              ],
            ),
            Center(
              child: Text(
                '${widget.list[index].title}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVendorItemData(
      BuildContext context, int index, VendorModel popularNearFoodVendorModel, ProductModel productModel) {
    totItem++;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: getImageVAlidUrl(lstNearByFood[index].photo),
                    height: 100,
                    width: 100,
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
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          AppGlobal.placeHolderImage!,
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                        )),
                    fit: BoxFit.cover,
                  ),
                  // const SizedBox(
                  //   width: 10,
                  // ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lstNearByFood[index].name,
                          style: const TextStyle(
                            fontFamily: "Poppinsm",
                            fontSize: 18,
                            color: Color(0xff000000),
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            lstNearByFood[index].disPrice == "" || lstNearByFood[index].disPrice == "0"
                                ? Text(
                                    amountShow(amount: lstNearByFood[index].price),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "Poppinsm",
                                        letterSpacing: 0.5,
                                        color: Color(COLOR_PRIMARY)),
                                  )
                                : Column(
                                    children: [
                                      Text(
                                        "${amountShow(amount: lstNearByFood[index].disPrice)}",
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
                                        '${amountShow(amount: lstNearByFood[index].price)}',
                                        style: const TextStyle(
                                            fontFamily: "Poppinsm",
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                            decoration: TextDecoration.lineThrough),
                                      ),
                                    ],
                                  ),
                            ElevatedButton(
                              onPressed: () async {
                                await Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailsScreen(
                                          productModel: productModel,
                                          vendorModel: widget.vendorModel,
                                        ),
                                      ),
                                    )
                                    .whenComplete(() => setState(() {}));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(COLOR_ACCENT),
                              ),
                              child: Text(
                                'ADD'.tr(),
                                style: TextStyle(fontFamily: "Poppinsm", color: AppColors.WHITE_COLOR),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    if (MyAppState.currentUser == null) {
                      push(context, AuthScreen());
                    } else {
                      setState(() {
                        var contain = lstFav.where((element) => element.productId == productModel.id);

                        if (contain.isNotEmpty) {
                          FavouriteItemModel favouriteModel = FavouriteItemModel(
                              productId: productModel.id,
                              storeId: widget.vendorModel.id,
                              userId: MyAppState.currentUser!.userID);
                          lstFav.removeWhere((item) => item.productId == productModel.id);
                          FireStoreUtils().removeFavouriteItem(favouriteModel);
                        } else {
                          FavouriteItemModel favouriteModel = FavouriteItemModel(
                              productId: productModel.id,
                              storeId: widget.vendorModel.id,
                              userId: MyAppState.currentUser!.userID);
                          FireStoreUtils().setFavouriteStoreItem(favouriteModel);
                          lstFav.add(favouriteModel);
                        }
                      });
                    }
                  },
                  child: lstFav.where((element) => element.productId == productModel.id).isNotEmpty
                      ? Icon(
                          Icons.favorite,
                          color: Color(COLOR_PRIMARY),
                        )
                      : Icon(
                          Icons.favorite_border,
                          color: isDarkMode(context) ? Colors.white38 : Colors.black38,
                        ),
                ),
              ),
              // Align(
              //   alignment: Alignment.topRight,
              //   child: Icon(
              //     Icons.favorite,
              //     color: Color(COLOR_PRIMARY),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
