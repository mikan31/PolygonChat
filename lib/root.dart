import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sample/admob_widget.dart';
import 'package:sample/routes/account/account.dart';
import 'package:sample/routes/chatroom.dart';
import 'package:sample/routes/home/home.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: must_be_immutable
class RootWidget extends StatefulWidget {
  String usermail = "";
  @override
  RootWidget({Key key, this.usermail}) : super(key: key);
  RootWidgetState createState() => RootWidgetState();
}

class RootWidgetState extends State<RootWidget> {
  int selectedIndex = 0;
  final bottomNavigationBarItems = <BottomNavigationBarItem>[];
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  // アイコン情報
  static const footerIcons = [
    Icons.home,
    Icons.textsms,
    Icons.account_circle,
  ];

  // アイコン文字列
  static const footerItemNames = [
    'ホーム',
    'トーク',
    'アカウント',
  ];

  var routes = [];

  Future pushToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
    final String username = prefs.getString('name') ?? "";
    await FirebaseFirestore.instance.collection('token').doc(username).update({
      'fcmtoken': FieldValue.arrayUnion([token])
    });
  }

  @override
  void initState() {
    super.initState();
    bottomNavigationBarItems.add(activeState(0));
    for (var i = 1; i < footerItemNames.length; i++) {
      bottomNavigationBarItems.add(deactiveState(i));
    }
    if (widget.usermail != null) {
      //PUSH通知送るための処理
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
        },
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
        },
      );
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));
      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
      _firebaseMessaging.getToken().then((String token) {
        assert(token != null);
        print("Push Messaging token: $token");
        pushToken(token);
      });
      /*
      RegExp exp = new RegExp(r'^(.+)@(.+)$');
      _firebaseMessaging
          .subscribeToTopic(exp.firstMatch(widget.usermail).group(1));
      */
    }
  }

  /// インデックスのアイテムをアクティベートする
  BottomNavigationBarItem activeState(int index) {
    return BottomNavigationBarItem(
        icon: Icon(
          footerIcons[index],
          color: Colors.black87,
        ),
        title: Text(
          footerItemNames[index],
          style: TextStyle(
            color: Colors.black87,
          ),
        ));
  }

  /// インデックスのアイテムをディアクティベートする
  BottomNavigationBarItem deactiveState(int index) {
    return BottomNavigationBarItem(
        icon: Icon(
          footerIcons[index],
          color: Colors.black26,
        ),
        title: Text(
          footerItemNames[index],
          style: TextStyle(
            color: Colors.black26,
          ),
        ));
  }

  void setRoute() {
    routes = [Home(), Chatroom(), Account()];
  }

  void onItemTapped(int index) {
    setState(() {
      bottomNavigationBarItems[selectedIndex] = deactiveState(selectedIndex);
      bottomNavigationBarItems[index] = activeState(index);
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    setRoute();
    return Column(
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Scaffold(
                body: routes.elementAt(selectedIndex),
                bottomNavigationBar: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  items: bottomNavigationBarItems,
                  currentIndex: selectedIndex,
                  onTap: onItemTapped,
                )),
          ),
        ),
        AdmobBannerWidget(),
      ],
    );
  }
}
