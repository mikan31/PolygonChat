import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sample/drawer/contract.dart';
import 'package:sample/drawer/privacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SettingPage(),
    );
  }
}

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool showpaira;
  bool notification;
  String notificationText;

  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showpaira = prefs.getBool('showpaira') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(68, 114, 196, 1.0),
              title: Text(
                "設定",
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: ListView(children: <Widget>[
              Container(
                child: CheckboxListTile(
                  value: showpaira,
                  title: Text(
                    'パイラの表示',
                  ),
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: (bool value) async {
                    setState(() {
                      showpaira = value;
                    });

                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool('showpaira', value);
                  },
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              GestureDetector(
                child: Container(
                  child: ListTile(
                    title: Text('利用規約'),
                    trailing: Icon(Icons.navigate_next),
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContractPage(),
                    ),
                  );
                },
              ),
              GestureDetector(
                child: Container(
                  child: ListTile(
                    title: Text('プライバシーポリシー'),
                    trailing: Icon(Icons.navigate_next),
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrivacyPage(),
                    ),
                  );
                },
              ),
            ]),
          );
        });
  }
}
