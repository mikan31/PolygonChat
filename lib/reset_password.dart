import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPassword createState() => _ResetPassword();
}

class _ResetPassword extends State<ResetPassword> {
  String usermail = '';
  String mail = '';
  String userpassword = '';
  String text = "";
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "パスワード再設定",
          style: TextStyle(
              color: Color.fromRGBO(90, 200, 250, 1.0),
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
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
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text("登録しているメールアドレスに\n再設定用のリンクを送信いたします。"),
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
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: RaisedButton(
                      child: Text(
                        '送信',
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
                          final FirebaseAuth auth = FirebaseAuth.instance;
                          await auth.sendPasswordResetEmail(email: usermail);
                          Navigator.pop(context);
                        } catch (error) {
                          print(error.code);
                          if (error.code == 'invalid-email') {
                            text = "無効なメールアドレスです。";
                          } else if (error.code == 'user-not-found') {
                            text = "メールアドレスが登録されていません。";
                          } else {
                            text = "メール送信に失敗しました。";
                          }
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(text),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('戻る'),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
