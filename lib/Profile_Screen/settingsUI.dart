import 'package:blog_app/services/globalVariable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsUI extends StatefulWidget {
  SettingsUI({Key? key}) : super(key: key);

  @override
  State<SettingsUI> createState() => _SettingsUIState();
}

class _SettingsUIState extends State<SettingsUI> {
  String selectedTheme = 'system';

  // setSelectTheme(final value) {
  //   if (value == 'on') {
  //     isDarkMode = true;
  //   } else if (value == 'off') {
  //     isDarkMode = false;
  //   } else {
  //     if (Theme.of(context).brightness == Brightness.dark) {
  //       isDarkMode = true;
  //     } else {
  //       isDarkMode = false;
  //     }
  //   }

  //   setState(() {});
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'SETTINGS',
          style: TextStyle(
            letterSpacing: 10,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        children: [
          Text(
            'Dark Mode',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          SelectModeBtn(
            value: 'on',
            groupValue: selectedTheme,
            title: 'On',
            subtitle: 'When set to ON the app theme will be set to DARK MODE.',
          ),
          SelectModeBtn(
            value: 'off',
            groupValue: selectedTheme,
            title: 'Off',
            subtitle:
                'When set to OFF the app theme will be set to LIGHT MODE.',
          ),
          SelectModeBtn(
            value: 'system',
            groupValue: selectedTheme,
            title: 'System Default',
            subtitle:
                'When set to "System Default" the app theme will be depended on System Theme.',
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
