import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/services/auth.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class LoginUi extends StatefulWidget {
  const LoginUi({Key? key}) : super(key: key);

  @override
  State<LoginUi> createState() => _LoginUiState();
}

class _LoginUiState extends State<LoginUi> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    isDarkMode = brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarIconBrightness:
            isDarkMode! ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDarkMode! ? Colors.grey.shade900 : Colors.white,
      body: SafeArea(
        child: isLoading == true
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Loading Your Inspirations',
                          cursor: ' |',
                          textStyle: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color:
                                isDarkMode! ? primaryAccentColor : primaryColor,
                          ),
                        ),
                      ],
                      totalRepeatCount: 100,
                      displayFullTextOnTap: true,
                      stopPauseOnTap: true,
                    ),
                    CustomLoading(),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedAlign(
                            duration: Duration(seconds: 1),
                            alignment: isLoading
                                ? Alignment.center
                                : Alignment.topCenter,
                            child: Column(
                              children: [
                                Text(
                                  '!nspire',
                                  style: TextStyle(
                                    color: isDarkMode!
                                        ? primaryAccentColor
                                        : primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 40,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'A MILLION',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    letterSpacing: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.1,
                          ),
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 400.0,
                              autoPlay: true,
                              enlargeCenterPage: true,
                            ),
                            items: [1, 2, 3, 4, 5].map((i) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 5.0),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isDarkMode!
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade100
                                              .withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: SvgPicture.asset(
                                      'lib/assets/image/$i.svg',
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.only(
                        right: 20,
                        left: 20,
                        bottom: 10,
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          AuthMethods().signInWithgoogle(context);
                        },
                        color: isDarkMode! ? Colors.white : primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor:
                                  isDarkMode! ? Colors.black : Colors.white,
                              child: Image.asset(
                                'lib/assets/image/googleLogo.png',
                                height: 15,
                              ),
                            ),
                            Spacer(),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                color:
                                    isDarkMode! ? Colors.black : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
