import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sample/model.dart';
import 'package:sample/routes/account/hobby_menu.dart';

// ignore: must_be_immutable
class CreateProfile extends StatelessWidget {
  FirebaseAuth auth = FirebaseAuth.instance;
  String userimage = '';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Model>(
      create: (_) => Model(),
      child: Stack(
        children: <Widget>[
          Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(
                "新規登録",
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
            body: Consumer<Model>(builder: (context, model, child) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: <Widget>[
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: InkWell(
                        onTap: () async {
                          userimage =
                              await model.setImage(model.userName + 'image');
                        },
                        child: userimage.isEmpty
                            ? Container(
                                child: Icon(Icons.collections),
                                width: 130.0,
                                height: 130.0,
                                margin: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white, width: 7),
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image:
                                            AssetImage('assets/preimage.JPG'),
                                        colorFilter: ColorFilter.mode(
                                            Colors.black.withOpacity(0.6),
                                            BlendMode.dstATop))))
                            : Container(
                                child: Icon(Icons.collections),
                                width: 130.0,
                                height: 130.0,
                                margin: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white, width: 7),
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: NetworkImage(userimage),
                                        colorFilter: ColorFilter.mode(
                                            Colors.black.withOpacity(0.6),
                                            BlendMode.dstATop)))),
                      ),
                    ),
                    Text('ユーザーアイコン'),
                    Divider(
                      height: 20.0,
                      thickness: 2.0,
                    ),
                    model.textForm(context, 'ユーザー名', '例: 松雪パイラ'),
                    model.textForm(context, 'Eメール', '例: paira@polygon.com'),
                    model.textForm(context, 'パスワード', '半角英数字記号 (6文字以上)'),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: RaisedButton(
                        child: Text(
                          'プロフィール登録',
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
                          model.startLoading();
                          model.checkform(context);

                          try {
                            DocumentSnapshot docSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('user')
                                    .doc(model.userName)
                                    .get();
                            if (!docSnapshot.exists) {
                              //Authenationにユーザー登録
                              final result =
                                  await auth.createUserWithEmailAndPassword(
                                email: model.userMail,
                                password: model.userPassword,
                              );

                              if (result.user.email != null) {
                                await result.user.sendEmailVerification();
                                // データベースの'user'コレクションに追加
                                await FirebaseFirestore.instance
                                    .collection('user')
                                    .doc(model.userName)
                                    .set(
                                  {
                                    'title': model.userName,
                                    'imageURL': userimage,
                                    'headerURL': '',
                                    'comment': '',
                                    'hobby': '',
                                    'mail': model.userMail,
                                    'createdAt': Timestamp.now(),
                                  },
                                );

                                //fcmtoken生成用
                                await FirebaseFirestore.instance
                                    .collection('token')
                                    .doc(model.userName)
                                    .set({'fcmtoken': []});
                              }

                              model.endLoading();

                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('送信されたリンクからメールアドレスを確認してください。'),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('次へ'),
                                        onPressed: () async {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) => HobbyMenu(
                                                  username: model.userName),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              model.endLoading();
                              model.dialog(context, "そのユーザー名は既に登録されています。");
                            }
                          } catch (e) {
                            print(e);
                            model.endLoading();
                            if (e.message ==
                                "The email address is badly formatted.") {
                              model.dialog(context, "正しくメールアドレスを入力してください。");
                            } else if (e.message ==
                                "Password should be at least 6 characters") {
                              model.dialog(context, "パスワードは最低6文字入力してください。");
                            } else {
                              model.dialog(context, "正しくメールアドレスを入力してください。");
                            }
                          }
                        },
                      ),
                    ),
                    //Text(model.infoText),
                  ]),
                ),
              );
            }),
          ),
          Consumer<Model>(builder: (context, model, child) {
            return model.isLoading
                ? Container(
                    color: Colors.grey.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : SizedBox();
          }),
        ],
      ),
    );
  }
}
