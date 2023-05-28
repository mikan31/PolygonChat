import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:sample/create_profile.dart';
import 'package:sample/reset_password.dart';
import 'package:sample/root.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/gestures.dart';

class UserLogin extends StatefulWidget {
  @override
  _UserLogin createState() => _UserLogin();
}

class _UserLogin extends State<UserLogin> {
  String usermail = '';
  String mail = '';
  String userpassword = '';
  String infoText = "";
  bool isLoading = false;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future saveData(String mail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mail', mail);
    await FirebaseFirestore.instance
        .collection('user')
        .where('mail', isEqualTo: mail)
        .get()
        .then((value) {
      value.docs.forEach((result) {
        prefs.setString('name', result.data()['title']);
        prefs.setString('image', result.data()['imageURL']);
        prefs.setString('header', result.data()['headerURL']);
        prefs.setString('comment', result.data()['comment']);
        prefs.setString('hobby', result.data()['hobby'].join(','));
      });
    });
    await prefs.setBool('showpaira', true); //パイラを表示するか
    await prefs.setBool('isFirstChoice', false);
    await prefs.setBool('isExplain', false);
  }

  /*getPrefItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      mail = prefs.getString('mail') ?? null;
      isFirstLaunch = prefs.getString('mail') ?? true;
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Stack(children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: SizedBox(
                      height: 150,
                      width: 150,
                      child: Image.asset('assets/logo.png')),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                  child: Text(
                    'ポリゴンチャット',
                    style: TextStyle(fontFamily: 'pupupu', fontSize: 30),
                  ),
                ),
                TextFormField(
                  // テキスト入力のラベルを設定
                  decoration: InputDecoration(labelText: "メールアドレス"),
                  onChanged: (String value) {
                    setState(() {
                      usermail = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "パスワード"),
                  // パスワードが見えないようにする
                  obscureText: true,
                  onChanged: (String value) {
                    setState(() {
                      userpassword = value;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: RaisedButton(
                    child: Text(
                      'ログイン',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    color: Color.fromRGBO(100, 205, 250, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    onPressed: () async {
                      try {
                        // メール/パスワードでログイン
                        // ログインに成功した場合
                        setState(() {
                          isLoading = true;
                        });

                        final loginResult =
                            await auth.signInWithEmailAndPassword(
                          email: usermail,
                          password: userpassword,
                        );

                        if (loginResult.user.emailVerified) {
                          await saveData(loginResult.user.email);

                          setState(() {
                            isLoading = false;
                          });

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) =>
                                  RootWidget(usermail: usermail),
                            ),
                          );
                        } else {
                          setState(() {
                            isLoading = false;
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('リンクからメールアドレスを認証してください。'),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('再送信'),
                                      onPressed: () async {
                                        await loginResult.user
                                            .sendEmailVerification();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('OK'),
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          });
                        }
                      } catch (e) {
                        // ログインに失敗した場合
                        setState(() {
                          isLoading = false;
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('ログイン失敗'),
                                content: Text(e.message),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('OK'),
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        });
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'アカウントをお持ちでない方は ',
                        ),
                        TextSpan(
                          text: '新規登録',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setBool('isFirstChoice', true);

                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => CreateProfile()));
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'パスワードが分からない方は ',
                        ),
                        TextSpan(
                          text: '再設定',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ResetPassword()));
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                //Text(infoText)
              ],
            ),
          ),
        ),
        isLoading
            ? Container(
                color: Colors.grey.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : SizedBox(),
      ]),
    );
  }
}
