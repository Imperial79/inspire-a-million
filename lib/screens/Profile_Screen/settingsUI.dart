import 'package:blog_app/services/auth.dart';
import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/utilities/sdp.dart';
import 'package:blog_app/utilities/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utilities/components.dart';
import '../../utilities/constants.dart';
import '../../utilities/custom_sliver_app_bar.dart';

class SettingsUI extends StatefulWidget {
  SettingsUI({Key? key}) : super(key: key);

  @override
  State<SettingsUI> createState() => _SettingsUIState();
}

class _SettingsUIState extends State<SettingsUI> {
  String selectedTheme = 'system';
  final name = TextEditingController(text: Userdetails.userDisplayName);
  bool isNameSame = true;

  @override
  void initState() {
    super.initState();
  }

  updateName() async {
    Userdetails.userDisplayName = name.text;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(Userdetails.uid)
        .update({'name': name.text});
    setState(() {});

    ShowSnackBar(context, 'Name updated successfully !!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? scaffoldDarkColor : scaffoldLightColor,
      body: CustomScrollView(
        slivers: <Widget>[
          CustomSliverAppBar(
            isMainView: false,
            onBackButtonPressed: () {
              Navigator.pop(context);
            },
            title: Text(
              'Settings',
              style: TextStyle(color: isDarkMode ? whiteColor : blackColor),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              <Widget>[
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SubLabel(context, text: 'Appearance'),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isDarkMode ? darkGreyColor : greyColorAccent,
                        ),
                        child: TextField(
                          controller: name,
                          style: TextStyle(
                            fontSize: sdp(context, 15),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Display Name',
                            floatingLabelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: sdp(context, 13),
                            ),
                            labelStyle: TextStyle(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            enabledBorder: InputBorder.none,
                            focusedBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(10),
                              ),
                              borderSide: BorderSide(
                                width: 4,
                                color: isDarkMode
                                    ? primaryAccentColor
                                    : primaryColor,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (Userdetails.userDisplayName == name.text) {
                              setState(() {
                                isNameSame = true;
                              });
                            } else {
                              setState(() {
                                isNameSame = false;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (!isNameSame) {
                            updateName();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? Userdetails.userDisplayName != name.text
                                  ? primaryAccentColor
                                  : darkGreyColor
                              : primaryColor,
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: isDarkMode ? blackColor : whiteColor,
                          ),
                        ),
                      ),
                      SubLabel(context, text: 'System'),
                      ElevatedButton.icon(
                        onPressed: () {
                          AuthMethods().signOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDarkMode ? Colors.redAccent : Colors.red,
                        ),
                        icon: Icon(
                          Icons.exit_to_app,
                          color: whiteColor,
                        ),
                        label: Text(
                          'Sign Out',
                          style: TextStyle(
                            color: whiteColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget SelectModeBtn({
    required String value,
    required Object groupValue,
    required String title,
    required String subtitle,
  }) {
    return RadioListTile(
      value: value,
      groupValue: groupValue,
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
      onChanged: (value) {
        print(value);
        setState(() {
          selectedTheme = value.toString();
        });
      },
    );
  }
}
