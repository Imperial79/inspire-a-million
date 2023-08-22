import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/services/auth.dart';
import 'package:blog_app/utilities/components.dart';
import 'package:blog_app/utilities/sdp.dart';
import 'package:blog_app/utilities/utility.dart';
import 'package:flutter/material.dart';

import 'utilities/constants.dart';

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
    SystemColors();
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: isLoading == true
              ? Loading()
              : Column(
                  children: [
                    Text(
                      'Welcome to !npsire',
                      style: TextStyle(
                        fontSize: sdp(context, 15),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    height10,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Being able to inspire others is an important personality trait for any leader.',
                        style: TextStyle(
                          color: isDarkMode
                              ? greyColor.withOpacity(0.7)
                              : greyColor,
                          fontSize: sdp(context, 13),
                          fontFamily: 'Monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: sdp(context, 300),
                                width: sdp(context, 300),
                                child: FittedBox(
                                  child: Text(
                                    '!',
                                    style: TextStyle(
                                      // fontSize: sdp(context, 300),
                                      color: isDarkMode
                                          ? blueGreyColorDark
                                          : primaryAccentColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Inspire A\nMillion',
                                  style: TextStyle(
                                      fontSize: sdp(context, 30),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Monospace'),
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              width: 100,
                              color: isDarkMode
                                  ? greyColor.withOpacity(0.5)
                                  : greyColor,
                            ),
                          ),
                          width10,
                          Text(
                            'continue with',
                            style: TextStyle(
                              color: isDarkMode
                                  ? greyColor.withOpacity(0.7)
                                  : greyColor,
                            ),
                          ),
                          width10,
                          Expanded(
                            child: Container(
                              height: 1,
                              width: 100,
                              color: isDarkMode
                                  ? greyColor.withOpacity(0.5)
                                  : greyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    height20,
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: EdgeInsets.only(
                          right: 20,
                          left: 20,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                                color: isDarkMode
                                    ? primaryColor
                                    : primaryAccentColor,
                                blurRadius: 80,
                                spreadRadius: 5,
                                offset: Offset(0, 40))
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                            });
                            AuthMethods().signInWithgoogle(context);
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor:
                                isDarkMode ? blueGreyColorDark : whiteColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                          icon: Image.asset(
                            'lib/assets/image/googleLogo.png',
                            height: sdp(context, 15),
                          ),
                          label: Text(
                            'Google',
                            style: TextStyle(
                              color: isDarkMode ? whiteColor : blackColor,
                              fontSize: sdp(context, 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
            isRepeatingAnimation: true,
            repeatForever: true,
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
            displayFullTextOnTap: true,
            stopPauseOnTap: true,
          ),
          SizedBox(height: 20),
          CustomLoading(),
        ],
      ),
    );
  }
}
