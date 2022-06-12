import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:blog_app/colors.dart';
import 'package:blog_app/services/auth.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(
                        backgroundColor: isDarkMode!
                            ? primaryAccentColor.withOpacity(0.3)
                            : primaryAccentColor,
                        color: isDarkMode! ? primaryAccentColor : primaryColor,
                        strokeWidth: 3,
                      ),
                    )
                  ],
                ),
              )
            : Stack(
                children: [
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '!nspire',
                          style: GoogleFonts.josefinSans(
                            color:
                                isDarkMode! ? primaryAccentColor : primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 40,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'A MILLION',
                          style: GoogleFonts.josefinSans(
                            color: Colors.grey,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 9,
                          ),
                        ),
                        SizedBox(
                          height: 50,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text(
                              "continue with",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          MaterialButton(
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                              });
                              AuthMethods().signInWithgoogle(context);
                            },
                            color:
                                isDarkMode! ? primaryAccentColor : primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 13,
                            ),
                            child: Text(
                              'Google',
                              style: TextStyle(
                                color:
                                    isDarkMode! ? primaryColor : Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
