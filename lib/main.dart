import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sample/first_launch/first_view.dart';
import 'user_login.dart';
import 'root.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_admob/firebase_admob.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //デバッグを表示しない
      title: 'ポリゴン',
      theme: ThemeData(
        primaryColor: Colors.blueGrey[900],
        //fontFamily: "Noto_Serif",
      ),
      home: CheckData(),
    );
  }
}

class CheckData extends StatefulWidget {
  CheckData({Key key}) : super(key: key);

  @override
  _CheckData createState() => _CheckData();
}

class _CheckData extends State<CheckData> {
  String mail = '';
  bool isFirstLaunch = false;

  getPrefItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      mail = prefs.getString('mail') ?? null;
      isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    });
  }

  @override
  void initState() {
    super.initState();
    // 初期化時にShared Preferencesに保存している値を読み込む
    getPrefItems();

    // インスタンスを初期化
    FirebaseAdMob.instance.initialize(
        appId: Platform.isAndroid
            ? 'ca-app-pub-9481691093118456~8834941367'
            : 'ca-app-pub-9481691093118456~4819141907');
  }

  @override
  Widget build(BuildContext context) {
    return isFirstLaunch
        ? FirstView()
        : ((mail != null) ? RootWidget() : UserLogin());
    //mailが取得できたならRootWidgetへ。じゃないならUserLoginへ。
  }
}
