import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/services/auth.dart';
import 'package:blog_app/utilities/components.dart';
import 'package:blog_app/utilities/sdp.dart';
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

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
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
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Text(
                                  'Being able to inspire others is an important personality trait for any leader. Inspired leaders revive energy in the workplace. They encourage everyone around them to dream bigger, push harder, and lead a more fulfilling life. Inspiration can also make your organization a more fun place to be.',
                                  style: TextStyle(
                                    color: greyColor,
                                  ),
                                ),
                                Text(
                                  '!',
                                  style: TextStyle(
                                    fontSize: sdp(context, 300),
                                    // color: primaryAccentColor.withOpacity(0.4),
                                    color: isDarkMode
                                        ? blueGreyColorDark
                                        : primaryAccentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: Column(
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
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: EdgeInsets.only(
                          right: 20,
                          left: 20,
                          bottom: 10,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                            });
                            AuthMethods().signInWithgoogle(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDarkMode ? blueGreyColorDark : whiteColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          icon: Image.asset(
                            'lib/assets/image/googleLogo.png',
                            height: sdp(context, 15),
                          ),
                          label: Text(
                            'Continue with Google',
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
