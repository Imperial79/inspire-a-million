import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:blog_app/Profile_Screen/settingsUI.dart';
import 'package:blog_app/utilities/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'inspiredUi.dart';
import 'motivatorUi.dart';

class MyProfileUi extends StatefulWidget {
  const MyProfileUi({Key? key}) : super(key: key);

  @override
  State<MyProfileUi> createState() => _MyProfileUiState();
}

class _MyProfileUiState extends State<MyProfileUi>
    with AutomaticKeepAliveClientMixin {
  final auth = FirebaseAuth.instance;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              StreamBuilder<dynamic>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('uid', isEqualTo: auth.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    DocumentSnapshot ds = snapshot.data.docs[0];
                    return Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: isDarkMode!
                                    ? primaryAccentColor
                                    : primaryColor,
                                child: CircleAvatar(
                                  radius: 43,
                                  backgroundColor: isDarkMode!
                                      ? Colors.black
                                      : Colors.grey.shade200,
                                  child: CircleAvatar(
                                    backgroundColor: isDarkMode!
                                        ? Colors.transparent
                                        : Colors.grey.shade100,
                                    radius: 39,
                                    child: CachedNetworkImage(
                                      imageUrl: ds['imgUrl'],
                                      imageBuilder: (context, image) =>
                                          CircleAvatar(
                                        radius: 39,
                                        backgroundImage: image,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  NavPush(context, SettingsUI());
                                },
                                icon: SvgPicture.asset(
                                  'lib/assets/icons/settings.svg',
                                  color:
                                      isDarkMode! ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            ds['name'],
                            style: TextStyle(
                              color: isDarkMode! ? Colors.white : Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: isDarkMode!
                                    ? primaryAccentColor
                                    : primaryColor,
                                child: Text(
                                  '@',
                                  style: TextStyle(
                                    color: !isDarkMode!
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                ds['username'],
                                style: TextStyle(
                                  color: isDarkMode!
                                      ? primaryAccentColor
                                      : primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: isDarkMode!
                                    ? primaryAccentColor
                                    : primaryColor,
                                radius: 14,
                                child: Icon(
                                  Icons.mail,
                                  color:
                                      isDarkMode! ? Colors.black : Colors.white,
                                  size: 15,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                ds['email'],
                                style: TextStyle(
                                  color: isDarkMode!
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade700,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              StreamBuilder<dynamic>(
                                stream: FirebaseFirestore.instance
                                    .collection('blogs')
                                    .where('uid', isEqualTo: Userdetails.uid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return StatsCard(
                                      count: '0',
                                      label: 'Inspirations',
                                      press: () {},
                                    );
                                  }

                                  return StatsCard(
                                    count: snapshot.data.docs.length.toString(),
                                    label: 'Inspirations',
                                    press: () {},
                                  );
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              StatsCard(
                                press: () {
                                  NavPush(
                                      context,
                                      InspiredUi(
                                        snap: ds,
                                        my: true,
                                      ));
                                },
                                count: ds['followers'].length.toString(),
                                label: 'Inspired',
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              StatsCard(
                                press: () {
                                  NavPush(
                                    context,
                                    MotivatorUi(
                                      snap: ds,
                                      from: 'me',
                                    ),
                                  );
                                },
                                count: ds['following'].length.toString(),
                                label: 'Motivators',
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      color: isDarkMode! ? primaryAccentColor : primaryColor,
                      strokeWidth: 1.6,
                    ),
                  );
                },
              ),
              BlogList(
                  isMe: true,
                  name: Userdetails.userDisplayName,
                  uid: Userdetails.uid),
            ],
          ),
        ),
      ),
    );
  }

  Widget CustomBtn(BuildContext context,
      {final label, textColor, btnColor, press, splashColor}) {
    return Expanded(
      child: InkWell(
        splashColor: splashColor,
        onTap: press,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 50,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: btnColor,
          ),
          child: FittedBox(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: textColor,
                fontSize: 20,
                fontFamily: 'default',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
