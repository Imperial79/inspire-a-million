import 'package:blog_app/services/globalVariable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utilities/custom_sliver_app_bar.dart';

class SettingsUI extends StatefulWidget {
  SettingsUI({Key? key}) : super(key: key);

  @override
  State<SettingsUI> createState() => _SettingsUIState();
}

class _SettingsUIState extends State<SettingsUI> {
  String selectedTheme = 'system';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          CustomSliverAppBar(
            isMainView: true,
            onBackButtonPressed: () {
              Navigator.pop(context);
            },
            title: Text(
              'Settings',
              style: TextStyle(color: Colors.black),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(
                          top: 16.0, bottom: 10.0, left: 20.0),
                      child: Text(
                        'Appearance',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [],
                    ),
                  ],
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
