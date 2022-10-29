import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/services/auth.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:blog_app/utilities/sdp.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginUi extends StatefulWidget {
  const LoginUi({Key? key}) : super(key: key);

  @override
  State<LoginUi> createState() => _LoginUiState();
}

class _LoginUiState extends State<LoginUi> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark ? true : false;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor:
            isDarkMode ? Colors.grey.shade900 : Colors.white,
      ),
    );

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      body: SafeArea(
        child: isLoading == true
            ? Loading()
            : Column(
                children: [
                  SizedBox(
                    height: sdp(context, 10),
                  ),
                  Text(
                    'Welcome to Inpsire',
                    style: TextStyle(
                      fontSize: sdp(context, 15),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '!',
                          style: TextStyle(
                            fontSize: sdp(context, 400),
                            color: primaryAccentColor.withOpacity(0.5),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Inspire A\nMillion',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: sdp(context, 30),
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Let\'s inspire millions ahead',
                                style: TextStyle(
                                  fontSize: sdp(context, 12),
                                  fontWeight: FontWeight.w500,
                                  height: sdp(context, 3),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
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
                        color: isDarkMode ? Colors.white : primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
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
                                  isDarkMode ? Colors.black : Colors.white,
                              child: Image.asset(
                                'lib/assets/image/googleLogo.png',
                                height: 15,
                              ),
                            ),
                            Spacer(),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                color: isDarkMode ? Colors.black : Colors.white,
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

  Center Loading() {
    return Center(
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
                  color: isDarkMode ? primaryAccentColor : primaryColor,
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
    );
  }
}
