import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'constants.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, 
          color: darkGray), 
          onPressed: () => Navigator.of(context).pop()),
        title: Text(
          'Settings',
          style: titleTextStyle,
        )
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text(
              'Profile',
              style: settingsTitleStyle,
            ),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.account_circle),
                title: Text('Profile Picture'),
                
              ),
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: true,
                leading: Icon(Icons.format_paint),
                title: Text('Enable custom theme'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}