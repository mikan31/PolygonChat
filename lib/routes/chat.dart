import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:sample/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sample/routes/bubble.dart';

// ignore: must_be_immutable
class Chat extends StatefulWidget {
  final String opponent;
  final String room;
  final String chatcompUrl;
  bool block;
  List blockuser;
  Chat(
      {Key key,
      this.opponent,
      this.room,
      this.chatcompUrl,
      this.block,
      this.blockuser})
      : super(key: key);

  @override
  ChatState createState() => ChatState();
}

class ChatState extends State<Chat> {
  String message = '';
  String image = '';
  // ignore: non_constant_identifier_names
  final Message_controller = TextEditingController();

  var username;
  var usermail;
  var userimage;

  String randletter() {
    // 小文字のアルファベットの文字列を作成
    int bigLetterStart = 65;
    int bigLetterCount = 26;

    var alphabetArray = [];
    // 10個のアルファベットがある文字列を作成して、最後にjoinで繋げています
    var rand = new math.Random();
    for (var i = 0; i < 100; i++) {
      // 0-25の乱数を発生させます
      int number = rand.nextInt(bigLetterCount);
      int randomNumber = number + bigLetterStart;
      alphabetArray.add(String.fromCharCode(randomNumber));
    }

    return alphabetArray.join('');
  }

  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('name') ?? '';
    usermail = prefs.getString('mail') ?? '';
  }

  Future addMessageToFirebase(String type) async {
    if (message.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('room')
          .doc(widget.room)
          .collection(widget.room)
          .add(
        {
          'type': type,
          'name': username,
          'content': message,
          'date': Timestamp.now(),
        },
      );
      FirebaseFirestore.instance.collection('room').doc(widget.room).update(
        {'createdAt': Timestamp.now(), 'lastMessage': message},
      );
    }
  }

  Future block(String room, bool modelblock) async {
    FirebaseFirestore.instance.collection('room').doc(room).update(
      {
        'block': widget.block ? false : true,
        'blockuser': FieldValue.arrayUnion([username])
      },
    );
  }

  Future unblock(String room, bool modelblock) async {
    FirebaseFirestore.instance.collection('room').doc(room).update(
      {
        'block': widget.block ? false : true,
        'blockuser': FieldValue.arrayRemove([username])
      },
    );
  }

  Future pushPost(String message) async {
    Map<String, String> headers = {'content-type': 'application/json'};
    String body =
        json.encode({"message": message, "opponent": widget.opponent});
    http.Response resp = await http.post(
        'https://us-central1-fluttetest-2b5b6.cloudfunctions.net/function-2',
        headers: headers,
        body: body);
    //サーバーエラーの場合はwaitして再送信する
    if (resp.statusCode == 500) {
      await new Future.delayed(new Duration(seconds: 2));
      http.Response reresp = await http.post(
          'https://us-central1-fluttetest-2b5b6.cloudfunctions.net/function-2',
          headers: headers,
          body: body);
      print(reresp);
    }
  }

  Future<dynamic> sendImageToStorage(File imageFile) async {
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child(widget.room)
        .child(username + DateTime.now().toString());
    StorageUploadTask uploadTask = ref.putFile(imageFile);
    return await (await uploadTask.onComplete).ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Model>(
      create: (_) => Model(),
      child: Consumer<Model>(
        builder: (context, model, child) {
          return Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.white,
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                  backgroundColor: Color.fromRGBO(68, 114, 196, 1.0),
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(
                    widget.opponent,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.block),
                      tooltip: 'ブロック',
                      onPressed: () {
                        showDialog<void>(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: widget.blockuser.contains(username)
                                    ? Text(widget.opponent + 'をブロック解除してもいいですか？')
                                    : Text(widget.opponent + 'をブロックしてもいいですか？'),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('いいえ',
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold)),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text(
                                      'はい',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (!widget.blockuser
                                          .contains(username)) {
                                        await block(widget.room, widget.block);
                                        setState(() {
                                          widget.block =
                                              widget.block ? false : true;
                                          widget.blockuser.add(username);
                                        });
                                      } else {
                                        await unblock(
                                            widget.room, widget.block);
                                        setState(() {
                                          widget.block =
                                              widget.block ? false : true;
                                          widget.blockuser.remove(username);
                                        });
                                      }
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                    )
                  ],
                ),
                body: widget.block
                    ? Center(child: Text(widget.opponent + 'をブロックしています'))
                    : FutureBuilder(
                        future: getData(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Container(
                                child: Padding(
                              padding: const EdgeInsets.only(bottom: 60.0),
                              child: Column(
                                children: <Widget>[
                                  new Expanded(
                                    child: GestureDetector(
                                      child: TestList(
                                        userName: username,
                                        room: widget.room,
                                        opponentImage: widget.chatcompUrl,
                                      ),
                                      onTap: () => FocusScope.of(context)
                                          .requestFocus(FocusNode()),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Consumer<Model>(
                                          builder: (context, model, child) {
                                        return Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          padding: const EdgeInsets.all(10.0),
                                          child: IconButton(
                                            icon: Icon(Icons.photo),
                                            onPressed: () async {
                                              // ignore: deprecated_member_use
                                              File imageFile =
                                                  await model.pickImage();
                                              (imageFile != null)
                                                  ? showDialog<void>(
                                                      context: context,
                                                      barrierDismissible:
                                                          false, // user must tap button!
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text('画像を送信'),
                                                          content: Image.file(
                                                              imageFile),
                                                          actions: <Widget>[
                                                            FlatButton(
                                                              child: Text('取消',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .grey)),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                            FlatButton(
                                                              child: Text(
                                                                '送信',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                model
                                                                    .startLoading();
                                                                message =
                                                                    await sendImageToStorage(
                                                                        imageFile);
                                                                addMessageToFirebase(
                                                                    'image');
                                                                model
                                                                    .endLoading();
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    )
                                                  : SizedBox();
                                            },
                                          ),
                                        );
                                      }),
                                      Flexible(
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              top: 7.0, bottom: 7.0),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0))),
                                          child: TextField(
                                            controller: Message_controller,
                                            autofocus: false,
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: null,
                                            style: new TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.black,
                                            ),
                                            decoration: new InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding:
                                                  const EdgeInsets.all(20.0),
                                              hintText: username,
                                            ),
                                            onChanged: (text) {
                                              message = text;
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        padding: const EdgeInsets.all(10.0),
                                        child: IconButton(
                                          icon: Icon(Icons.send),
                                          onPressed: () async {
                                            try {
                                              Message_controller.clear();
                                              await addMessageToFirebase(
                                                  'text');
                                              if (!widget.blockuser
                                                  .contains(widget.opponent))
                                                await pushPost(message);
                                              message = null;
                                            } catch (e) {
                                              //ここにエラーの処理をかく
                                            }
                                          },
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ));
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
              ),
              model.isLoading
                  ? Container(
                      color: Colors.grey.withOpacity(0.5),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : SizedBox()
            ],
          );
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class TestList extends StatelessWidget {
  final String room, userName, opponentImage;

  var isMe;
  var contentType;
  TestList({Key key, this.userName, this.room, this.opponentImage})
      : super(key: key);

  String message = '';
/*
  Future setPreferences(String sendMessage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lastmessage = prefs.getString(opponentName) ?? '';
    if (lastmessage == '') {
      prefs.setString(opponentName, sendMessage);
    }
    print(opponentName);
  }
*/
  counthalf(String inputString) {
    int sum = 0;
    List testlist = inputString.split('');
    for (String i in testlist) {
      if (RegExp(r'^[a-zA-Z0-9!-/:-@¥[-`{-~]').hasMatch(i)) sum += 1;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final Query users = FirebaseFirestore.instance
        .collection('room')
        .doc(room)
        .collection(room)
        .orderBy('date', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: users.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            new ListView(
              reverse: true,
              children: snapshot.data.docs.map((DocumentSnapshot document) {
                isMe = (document.data()['name'] == userName);
                contentType = document.data()['type'] ?? '';
                message = document.data()['content'];
                return (document.data()['content'] == '')
                    ? SizedBox() //要素が空だったら表示しない処理
                    : new Row(children: [
                        isMe
                            ? new Expanded(
                                flex: 9,
                                child: Container(),
                              )
                            : Container(
                                margin: EdgeInsets.only(left: 8.0),
                                child: Container(
                                  width: 50.0,
                                  height: 50.0,
                                  margin: EdgeInsets.all(15.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: (opponentImage != "")
                                          ? NetworkImage(opponentImage)
                                          : AssetImage('assets/preimage.JPG'),
                                    ),
                                  ),
                                ),
                              ),
                        (contentType == '' || contentType == 'text')
                            ? Flexible(
                                //fit: FlexFit.loose,
                                flex: ((message.length -
                                            counthalf(message) * 0.5) *
                                        0.95)
                                    .round(),
                                child: GestureDetector(
                                    child: Bubble(
                                      margin:
                                          BubbleEdges.symmetric(vertical: 15),
                                      nip: isMe
                                          ? BubbleNip.rightTop
                                          : BubbleNip.leftCenter,
                                      color: isMe
                                          ? Color.fromRGBO(136, 215, 250, 1.0)
                                          : Color.fromRGBO(220, 220, 220, 1.0),
                                      child: Align(
                                        child: Text(
                                          message,
                                          textAlign: message.length == 1
                                              ? TextAlign.center
                                              : TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 16.0,
                                            //fontWeight: FontWeight.w600,
                                          ),
                                          //overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ),
                                    onLongPress: !isMe
                                        ? () {}
                                        : () {
                                            showDialog<void>(
                                                context: context,
                                                barrierDismissible:
                                                    false, // user must tap button!
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text('メッセージを削除？'),
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        child: Text('取消',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey)),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      FlatButton(
                                                        child: Text('削除',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .red)),
                                                        onPressed: () async {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'room')
                                                              .doc(room)
                                                              .collection(room)
                                                              .doc(document.id)
                                                              .delete();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                });
                                          }),
                              )
                            : Flexible(
                                flex: 15,
                                child: GestureDetector(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        top: 8.0,
                                        bottom: 8.0,
                                      ),
                                      child: Image.network(message),
                                    ),
                                    onLongPress: !isMe
                                        ? () {}
                                        : () {
                                            showDialog<void>(
                                                context: context,
                                                barrierDismissible:
                                                    false, // user must tap button!
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text('メッセージを削除？'),
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        child: Text('取消',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey)),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      FlatButton(
                                                        child: Text('削除',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .red)),
                                                        onPressed: () async {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'room')
                                                              .doc(room)
                                                              .collection(room)
                                                              .doc(document.id)
                                                              .delete();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                });
                                          }),
                              ),
                        isMe
                            ? Container(
                                margin: EdgeInsets.only(right: 8.0),
                              )
                            : new Expanded(
                                flex: 6,
                                child: Container(),
                              )
                      ]);
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
