// import 'package:blog_app/colors.dart';
// import 'package:blog_app/services/globalVariable.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';

// String selectedDarkWall = '1';
// String selectedLightWall = '1';
// String selectedColor = 'green';

// class SettingsUI extends StatefulWidget {
//   const SettingsUI({Key? key}) : super(key: key);

//   @override
//   State<SettingsUI> createState() => _SettingsUIState();
// }

// class _SettingsUIState extends State<SettingsUI> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         automaticallyImplyLeading: false,
//         title: Text('Settings'),
//         centerTitle: true,
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarIconBrightness:
//               isDarkMode! ? Brightness.light : Brightness.dark,
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.all(15),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Wallpaper',
//                   style: GoogleFonts.manrope(
//                     color: isDarkMode! ? Colors.white : Colors.black,
//                     fontSize: 30,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Text(
//                   'Dark Theme',
//                   style: GoogleFonts.manrope(
//                     color: isDarkMode! ? Colors.white : Colors.black,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Row(
//                   children: [
//                     DarkWallSetector(
//                       label: '1',
//                       imgPath: 'lib/assets/image/darkBack.jpg',
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     DarkWallSetector(
//                       label: '2',
//                       imgPath: 'lib/assets/image/darkBack2.jpg',
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Text(
//                   'Light Theme',
//                   style: GoogleFonts.manrope(
//                     color: isDarkMode! ? Colors.white : Colors.black,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Row(
//                   children: [
//                     LightWallSetector(
//                         label: '1', imgPath: 'lib/assets/image/lightBack1.jpg'),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     LightWallSetector(
//                         label: '2', imgPath: 'lib/assets/image/lightBack2.jpg'),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Text(
//                   'Accent Color',
//                   style: GoogleFonts.manrope(
//                     color: isDarkMode! ? Colors.white : Colors.black,
//                     fontSize: 30,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Row(
//                   children: [
//                     ColorSwatch(
//                       label: 'green',
//                       solid: Colors.green.shade700,
//                       accent: Colors.green.shade100,
//                     ),
//                     ColorSwatch(
//                       label: 'blue',
//                       solid: Color(0xFF1976D2),
//                       accent: Colors.blue.shade100,
//                     ),
//                     ColorSwatch(
//                       label: 'red',
//                       solid: Colors.red,
//                       accent: Colors.red.shade100,
//                     ),
//                     ColorSwatch(
//                       label: 'amber',
//                       solid: Colors.amber,
//                       accent: Colors.amber.shade100,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget ColorSwatch({label, solid, accent}) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             primaryColor = solid;
//             primaryAccentColor = accent;
//             selectedColor = label;
//           });
//         },
//         child: Container(
//           // width: 50,
//           height: 50,
//           padding: EdgeInsets.all(5),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(7),
//             border: Border.all(
//               color: selectedColor == label
//                   ? isDarkMode!
//                       ? accent
//                       : solid
//                   : Colors.transparent,
//               width: 2,
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Expanded(
//                 child: CircleAvatar(
//                   radius: 14,
//                   backgroundColor: solid,
//                 ),
//               ),
//               SizedBox(
//                 width: 8,
//               ),
//               Expanded(
//                 child: CircleAvatar(
//                   backgroundColor: accent,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget DarkWallSetector({final label, imgPath}) {
//     return Expanded(
//       child: Padding(
//         padding: EdgeInsets.zero,
//         child: GestureDetector(
//           onTap: () {
//             setState(() {
//               selectedDarkWall = label;
//             });
//           },
//           child: Container(
//             height: 200,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               image: DecorationImage(
//                 image: AssetImage(imgPath),
//                 fit: BoxFit.cover,
//               ),
//               border: Border.all(
//                 color: selectedDarkWall == label
//                     ? primaryAccentColor
//                     : Colors.transparent,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget LightWallSetector({final label, imgPath}) {
//     return Expanded(
//       child: Padding(
//         padding: EdgeInsets.zero,
//         child: GestureDetector(
//           onTap: () {
//             setState(() {
//               selectedLightWall = label;
//             });
//           },
//           child: Container(
//             height: 200,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               image: DecorationImage(
//                 image: AssetImage(imgPath),
//                 fit: BoxFit.cover,
//               ),
//               border: Border.all(
//                 color: selectedLightWall == label
//                     ? primaryAccentColor
//                     : Colors.transparent,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
