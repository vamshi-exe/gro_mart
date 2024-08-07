import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gromart_customer/AppGlobal.dart';
import 'package:gromart_customer/constants.dart';
import 'package:gromart_customer/model/VendorCategoryModel.dart';
import 'package:gromart_customer/model/VendorModel.dart';
import 'package:gromart_customer/services/FirebaseHelper.dart';
import 'package:gromart_customer/services/helper.dart';
import 'package:gromart_customer/ui/dineInScreen/dine_in_restaurant_details_screen.dart';
import 'package:gromart_customer/ui/vendorProductsScreen/newVendorProductsScreen.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final VendorCategoryModel category;
  final bool isDineIn;

  const CategoryDetailsScreen(
      {Key? key, required this.category, required this.isDineIn})
      : super(key: key);

  @override
  _CategoryDetailsScreenState createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  Stream<List<VendorModel>>? categoriesFuture;
  final FireStoreUtils fireStoreUtils = FireStoreUtils();

  @override
  void initState() {
    super.initState();
    categoriesFuture = fireStoreUtils.getVendorsByCuisineID(
        widget.category.id.toString(),
        isDinein: widget.isDineIn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppGlobal.buildSimpleAppBar(
            context, widget.category.title.toString()),
        body: StreamBuilder<List<VendorModel>>(
          stream: categoriesFuture,
          initialData: [],
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Container(
                child: Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                  ),
                ),
              );
            if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
              return Center(
                child: showEmptyState('No Store found'.tr(), context),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) =>
                    buildVendorItem(snapshot.data![index]),
              );
            }
          },
        ),
      ),
    );
  }

  buildVendorItem(VendorModel vendorModel) {
    return GestureDetector(
      onTap: () {
        if (widget.isDineIn) {
          push(
            context,
            DineInRestaurantDetailsScreen(vendorModel: vendorModel),
          );
        } else {
          push(
            context,
            NewVendorProductsScreen(vendorModel: vendorModel),
          );
        }
      },
      child: Card(
        elevation: 0.5,
        color: isDarkMode(context) ? Colors.grey.shade900 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 200,

          // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            // mainAxisSize: MainAxisSize.max,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: getImageVAlidUrl(vendorModel.photo),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover)),
                  ),
                  placeholder: (context, url) => Center(
                      child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                  )),
                  errorWidget: (context, url, error) => ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        AppGlobal.placeHolderImage!,
                        fit: BoxFit.fitWidth,
                        width: MediaQuery.of(context).size.width,
                      )),
                  fit: BoxFit.cover,
                ),
              ),
              // SizedBox(height: 8),
              ListTile(
                title: Text(vendorModel.title,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode(context)
                          ? Colors.grey.shade400
                          : Colors.grey.shade800,
                      fontFamily: 'Poppinssb',
                    )),
                subtitle: Text(vendorModel.location,
                    maxLines: 1,

                    // filters.keys
                    //     .where(
                    //         (element) => vendorModel.filters[element] == 'Yes')
                    //     .take(2)
                    //     .join(', '),

                    style: TextStyle(
                      fontFamily: 'Poppinssm',
                    )),
                trailing: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.star,
                              size: 20,
                              color: Color(COLOR_PRIMARY),
                            ),
                            Text(
                              (vendorModel.reviewsCount != 0)
                                  ? (vendorModel.reviewsSum /
                                          vendorModel.reviewsCount)
                                      .toStringAsFixed(1)
                                  : "0",
                              style: TextStyle(
                                fontFamily: 'Poppinssb',
                              ),
                            ),
                            Visibility(
                                visible: vendorModel.reviewsCount != 0,
                                child: Text(
                                    "(${vendorModel.reviewsCount.toStringAsFixed(1)})")),
                          ]),
                    ],
                  ),
                ),
              ),
              // SizedBox(height: 4),

              // SizedBox(height: 4),
              // Visibility(
              //   visible: vendorModel.reviewsCount != 0,
              //   child: RichText(
              //     text: TextSpan(
              //       style: TextStyle(
              //           color: isDarkMode(context)
              //               ? Colors.grey.shade200
              //               : Colors.black),
              //       children: [
              //         TextSpan(
              //             text:
              //                 '${double.parse((vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(2))} '),
              //         WidgetSpan(
              //           child: Icon(
              //             Icons.star,
              //             size: 20,
              //             color: Color(COLOR_PRIMARY),
              //           ),
              //         ),
              //         TextSpan(text: ' (${vendorModel.reviewsCount})'),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class Categorydetailsscreen extends StatelessWidget {
//   const Categorydetailsscreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Vegetables & Fruits'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Row(
//         children: [
//           // Left side category list
//           Container(
//             width: 100,
//             color: Colors.grey[200],
//             child: ListView(
//               children: [
//                 CategoryTile('Fresh Vegetables', Icons.emoji_nature),
//                 CategoryTile('Fresh Fruits', Icons.emoji_food_beverage),
//                 CategoryTile('Seasonal', Icons.abc),
//                 CategoryTile('Exotics', Icons.eco),
//                 CategoryTile('Sprouts', Icons.grass),
//                 CategoryTile('Leafies & Herbs', Icons.local_florist),
//                 CategoryTile('Flowers & Leaves', Icons.local_florist),
//               ],
//             ),
//           ),
//           // Right side products grid
//           Expanded(
//             child: GridView.count(
//               crossAxisCount: 2,
//               padding: const EdgeInsets.all(8.0),
//               crossAxisSpacing: 8.0,
//               mainAxisSpacing: 8.0,
//               children: List.generate(products.length, (index) {
//                 return ProductCard(product: products[index]);
//               }),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CategoryTile extends StatelessWidget {
//   final String title;
//   final IconData icon;

//   CategoryTile(this.title, this.icon);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Icon(icon),
//         Text(title),
//       ],
//     );
//   }
// }

// class Product {
//   final String name;
//   final String weight;
//   final String price;
//   final String originalPrice;
//   // final String imagePath;

//   Product(
//     this.name,
//     this.weight,
//     this.price,
//     this.originalPrice,
//   );
// }

// List<Product> products = [
//   Product(
//     'Hybrid Tomato (Tamatar)',
//     '500 g',
//     '\$8',
//     '\$10',
//   ),
//   Product(
//     'Lady Finger (Bhindi)',
//     '250 g',
//     '\$7',
//     '\$10',
//   ),
//   Product(
//     'Green Chilli (Hari Mirch)',
//     '500 g',
//     '\$5',
//     '\$8',
//   ),
//   Product(
//     'Cluster Beans (Gawar Phali)',
//     '250 g',
//     '\$12',
//     '\$14',
//   ),
//   Product(
//     'Cabbage (Patta Gobhi)',
//     '500 g',
//     '\$8',
//     '\$10',
//   ),
//   Product(
//     'Capsicum (Shimla Mirch)',
//     '250 g',
//     '\$7',
//     '\$10',
//   ),
//   Product(
//     'Baby Potato (Chota Aloo)',
//     '500 g',
//     '\$10',
//     '\$14',
//   ),
//   Product(
//     'Green Peas (Matar)',
//     '250 g',
//     '\$5',
//     '\$10',
//   ),
// ];

// class ProductCard extends StatelessWidget {
//   final Product product;

//   ProductCard({required this.product});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 1,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: 120, // Adjust height as needed for the image container
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 color: Colors.grey[200],
//               ),
//               child: const Center(
//                 child: Icon(Icons.image, size: 60, color: Colors.grey),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               product.name,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//               maxLines: 2, // Allow up to 2 lines for the product name
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               product.weight,
//               style: TextStyle(color: Colors.grey[600], fontSize: 12),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '\$${product.price}',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       '\$${product.originalPrice}',
//                       style: const TextStyle(
//                         decoration: TextDecoration.lineThrough,
//                         color: Colors.grey,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//                 ElevatedButton(
//                   child: const Text(
//                     'Add',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
