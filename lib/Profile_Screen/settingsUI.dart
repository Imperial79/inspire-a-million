import 'package:blog_app/services/globalVariable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String selectedDarkWall = '1';
String selectedLightWall = '1';
String selectedColor = 'green';

class SettingsUI extends StatefulWidget {
  SettingsUI({Key? key}) : super(key: key);

  @override
  State<SettingsUI> createState() => _SettingsUIState();
}

class _SettingsUIState extends State<SettingsUI> {
  int selectedRadioTile = 1;

  setSelectedRadioTile(int val) {
    setState(() {
      selectedRadioTile = val;
    });
  }

  @override
  void initState() {
    super.initState();
    selectedRadioTile = 1;
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark ? true : false;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
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
          RadioListTile(
            value: 1,
            groupValue: selectedRadioTile,
            title: Text("On"),
            subtitle: Text("Radio 1 Subtitle"),
            onChanged: (val) {
              print("Radio Tile pressed $val");
              setSelectedRadioTile(int.parse(val.toString()));
            },
          ),
          RadioListTile(
            value: 2,
            groupValue: selectedRadioTile,
            title: Text("Off"),
            subtitle: Text("Radio 2 Subtitle"),
            onChanged: (val) {
              print("Radio Tile pressed $val");
              setSelectedRadioTile(int.parse(val.toString()));
            },
          ),
          RadioListTile(
            value: 3,
            groupValue: selectedRadioTile,
            title: Text("System Default"),
            subtitle: Text("Radio 2 Subtitle"),
            onChanged: (val) {
              print("Radio Tile pressed $val");
              setSelectedRadioTile(int.parse(val.toString()));
            },
          ),
        ],
      ),
    );
  }
}
