import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sample/drawer/contact.dart';
import 'package:sample/drawer/setting.dart';
import 'package:sample/user_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: must_be_immutable
class PolygonDrawer extends StatelessWidget {
  String username, token;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width / 1.5,
      child: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Text(
                "ポリゴンチャット",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontFamily: 'pupupu',
                ),
              ),
              decoration: BoxDecoration(
                color: Color.fromRGBO(100, 205, 250, 1.0),
              ),
            ),
            ListTile(
              title: Text('設定'),
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Setting(),
                  ),
                );
              },
            ),
            /*
            ListTile(
              title: Text('広告の削除'),
              onTap: () async {
                Navigator.pop(context);
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        '¥120で広告を削除しますか？',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text(
                            'いいえ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                        ),
                        FlatButton(
                          child: Text(
                            'はい',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            //TODO: ここにアプリ内課金の処理を書く
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
             */
            ListTile(
              title: Text('ログアウト'),
              onTap: () async {
                Navigator.pop(context);
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        '本当にログアウトしますか？',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text(
                            'いいえ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                        ),
                        FlatButton(
                          child: Text(
                            'はい',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () async {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            username = prefs.getString('name') ?? '';
                            token = prefs.getString('token') ?? '';

                            await FirebaseFirestore.instance
                                .collection('token')
                                .doc(username)
                                .update({
                              'fcmtoken': FieldValue.arrayRemove([token])
                            });

                            prefs.clear();

                            prefs.setBool('isFirstLaunch', false);
                            prefs.setBool('isFirstChoice', false);
                            prefs.setBool('isExplain', false);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserLogin(),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              title: Text('コンタクト'),
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Contact(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
