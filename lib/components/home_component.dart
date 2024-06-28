// import 'package:flutter/material.dart';
// import 'package:flutter_app/config.dart';
// import 'package:flutter_app/pages/details_page.dart';
// import 'package:flutter_app/pages/popular_places.dart';
// import 'package:flutter_app/services/places_service.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_app/models/place_model.dart';

// class HomeComponent extends StatefulWidget {
//   const HomeComponent({super.key});
//   @override
//   State<HomeComponent> createState() => _HomeComponentState();
// }

// class _HomeComponentState extends State<HomeComponent>
//     with AutomaticKeepAliveClientMixin<HomeComponent> {
//   @override
//   bool get wantKeepAlive => false;
//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // Call super.build to ensure the mixin works properly
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: FutureBuilder<List<BestPlacesModel>>(
//         future: PlaceService.getBestPlaces(),
//         builder: (context, snapshot) {
//           return ListView(
//             key: const PageStorageKey<String>('homeListView'),
//             children: [
//               const Text(
//                 "Explore the ",
//                 style: TextStyle(
//                   fontSize: 46,
//                   fontWeight: FontWeight.w300,
//                 ),
//               ),
//               Row(
//                 children: [
//                   const Text(
//                     "Beautiful ",
//                     style: TextStyle(
//                       fontSize: 50,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Column(
//                     children: [
//                       const Text(
//                         "world!",
//                         style: TextStyle(
//                           fontSize: 50,
//                           color: Color(0xFFFF7029),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       Image.asset(
//                         'lib/images/text_under.png',
//                         width: 120,
//                         fit: BoxFit.contain,
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//               const SizedBox(
//                 height: 40,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "Best Destination",
//                     style: TextStyle(
//                       fontSize: 21,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const PopularPlacesPage(),
//                         ),
//                       );
//                     },
//                     child: const Text(
//                       "View all",
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.amber,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               if (snapshot.connectionState == ConnectionState.waiting)
//                 const Center(child: CircularProgressIndicator())
//               else if (snapshot.hasError)
//                 Center(child: Text('Error: ${snapshot.error}'))
//               else if (!snapshot.hasData || snapshot.data!.isEmpty)
//                 const Center(child: Text('No data available'))
//               else
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       height: 500, // Adjust height as needed
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: snapshot.data!.length,
//                         itemBuilder: (context, index) {
//                           final place = snapshot.data![index];
//                           return Padding(
//                             padding: const EdgeInsets.all(12.0),
//                             child: Container(
//                               width: 300,
//                               margin: const EdgeInsets.only(right: 25.0),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(20),
//                                 boxShadow: [
//                                   BoxShadow(
//                                       color: Colors.grey.withOpacity(0.1),
//                                       spreadRadius: 3,
//                                       blurRadius: 5,
//                                       offset: const Offset(4, 4))
//                                 ],
//                               ),
//                               child: GestureDetector(
//                                 onTap: () {
//                                   final placeId = place.placeId;
//                                   if (placeId != null) {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => DetailsPage(
//                                           placeId: placeId,
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                 },
//                                 child: Column(
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.all(15.0),
//                                       child: Stack(
//                                         children: [
//                                           Container(
//                                             width: double.infinity,
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(20),
//                                             ),
//                                             child: ClipRRect(
//                                               borderRadius:
//                                                   BorderRadius.circular(20),
//                                               child: Image.network(
//                                                 place.photos?.isNotEmpty == true
//                                                     ? "${Config.apiURL}public/images/places/${place.photos!.first}"
//                                                     : '${Config.apiURL}public/images/image1.png',
//                                                 width: double.infinity,
//                                                 height: 350,
//                                                 fit: BoxFit.cover,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       height: 10,
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 15.0),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Expanded(
//                                             child: Text(
//                                               place.name ?? 'Unknown',
//                                               style: const TextStyle(
//                                                 fontSize: 22,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                               overflow: TextOverflow.ellipsis,
//                                               maxLines: 1,
//                                             ),
//                                           ),
//                                           Row(
//                                             children: [
//                                               const Icon(
//                                                 Icons.star,
//                                                 size: 18,
//                                                 color: Colors.amber,
//                                               ),
//                                               Text(
//                                                 " ${place.averageRating ?? 0}",
//                                                 style: const TextStyle(
//                                                     fontSize: 16),
//                                               )
//                                             ],
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       height: 10,
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 15.0),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Expanded(
//                                             child: Row(
//                                               children: [
//                                                 SvgPicture.asset(
//                                                   "lib/images/Location.svg",
//                                                   width: 22,
//                                                   height: 22,
//                                                 ),
//                                                 Expanded(
//                                                   child: Text(
//                                                     " ${place.address?.street ?? ''}, ${place.address?.district ?? ''}",
//                                                     style: const TextStyle(
//                                                       color: Color(
//                                                         0xFF7D848D,
//                                                       ),
//                                                       fontSize: 17,
//                                                     ),
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     maxLines: 1,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     const Text(
//                       "Explore",
//                       style: TextStyle(
//                         fontSize: 21,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Container(
//                               padding: const EdgeInsets.only(
//                                   top: 20, bottom: 20, left: 10),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.grey.withOpacity(0.3),
//                                     blurRadius: 10,
//                                     spreadRadius: 2,
//                                   )
//                                 ],
//                               ),
//                               child: const Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Icon(Icons.restaurant, size: 20),
//                                   SizedBox(height: 10),
//                                   Text(
//                                     " Nhà hàng",
//                                     style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold),
//                                     overflow: TextOverflow.ellipsis,
//                                     maxLines: 1,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Container(
//                               padding: const EdgeInsets.only(
//                                   top: 20, bottom: 20, left: 10),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.grey.withOpacity(0.3),
//                                     blurRadius: 10,
//                                     spreadRadius: 2,
//                                   )
//                                 ],
//                               ),
//                               child: const Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Icon(Icons.local_activity, size: 20),
//                                   SizedBox(height: 10),
//                                   Flexible(
//                                       child: Text(
//                                     "Hoạt động giải trí ",
//                                     style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold),
//                                     overflow: TextOverflow.ellipsis,
//                                     maxLines: 2,
//                                   )),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Container(
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.3),
//                               blurRadius: 10,
//                               spreadRadius: 2,
//                             )
//                           ],
//                         ),
//                         child: const Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Icon(Icons.hotel, size: 20),
//                             SizedBox(height: 10),
//                             Text(
//                               " Khách sạn",
//                               style: TextStyle(
//                                   fontSize: 18, fontWeight: FontWeight.bold),
//                               overflow: TextOverflow.ellipsis,
//                               maxLines: 1,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     Container(
//                       padding: const EdgeInsets.all(40),
//                       decoration: BoxDecoration(
//                         color: Colors.amber,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           const Text(
//                             "Tripadvisor thiếu một địa điểm?",
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 30,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           ElevatedButton.icon(
//                             onPressed: () {
//                               // Button pressed action
//                             },
//                             icon: const Icon(Icons.add_location,
//                                 color: Colors.white),
//                             label: const Text(
//                               "Thêm địa điểm bị thiếu",
//                               style: TextStyle(color: Colors.white),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.amber,
//                               shape: RoundedRectangleBorder(
//                                 side: const BorderSide(
//                                   color: Colors.white, // Màu của border
//                                   width: 1, // Độ dày của border
//                                 ),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                   ],
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
