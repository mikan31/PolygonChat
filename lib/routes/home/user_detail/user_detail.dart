import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sample/routes/home/user_detail/user_header.dart';
import 'package:sample/routes/home/user_detail/user_hobby.dart';
import 'package:sample/routes/home/user_detail/user_name.dart';
import 'package:sample/routes/home/user_detail/user_name_comment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sample/routes/chat.dart';

class UserDetail extends StatelessWidget {
  final String title;
  final imageURL;
  final headerURL;
  final String comment;
  final List<dynamic> userlist;
  UserDetail(
      this.title, this.imageURL, this.headerURL, this.comment, this.userlist);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: UserDetailPage(title, imageURL, headerURL, comment, userlist),
      ),
    );
  }
}

class UserDetailPage extends StatefulWidget {
  final String title;
  final imageURL;
  final headerURL;
  final String comment;
  final List<dynamic> userlist;
  UserDetailPage(
      this.title, this.imageURL, this.headerURL, this.comment, this.userlist);
  @override
  _UserDetailPageState createState() =>
      _UserDetailPageState(title, imageURL, headerURL, comment, userlist);
}

class _UserDetailPageState extends State<UserDetailPage> {
  final String title;
  final imageURL;
  final headerURL;
  final String comment;
  final List<dynamic> userlist;
  _UserDetailPageState(
      this.title, this.imageURL, this.headerURL, this.comment, this.userlist);

  String username = '';
  String usermail = '';
  String userimage = '';
  String roomname = '';
  bool block = false;
  List blockuser = [];

  bool chat = false;

  //ルーム名を一意に作成するための関数

  compstring(String a, String b) {
    if (a.compareTo(b) == 1) {
      return b + a;
    } else if (a.compareTo(b) == -1) {
      return a + b;
    } else {
      print("user name error");
    }
  }

  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('name') ?? '';
    usermail = prefs.getString('mail') ?? '';
    userimage = prefs.getString('image') ?? '';
    if (username != title) {
      setState(() {
        chat = true;
      });
    }
  }

  Future makeChat() async {
    //既に存在していないかチェック,存在していなかったらルーム作成
    roomname = compstring(username, title);
    DocumentSnapshot docSnapshot =
        await FirebaseFirestore.instance.collection('room').doc(roomname).get();
    if (!docSnapshot.exists) {
      await FirebaseFirestore.instance.collection('room').doc(roomname).set(
        {
          'member': [username, title],
          'block': false,
          'blockuser': [],
          //'createdAt': Timestamp.now()
        },
      );
      await FirebaseFirestore.instance
          .collection('room')
          .doc(roomname)
          .collection(roomname)
          .add(
        {
          'name': '',
          'content': '',
          'date': '',
        },
      );
    } else {
      block = docSnapshot.data()['block'];
      blockuser = docSnapshot.data()[('blockuser')];
    }
  }

  @override
  Widget build(BuildContext context) {
    getData();
    Size size = MediaQuery.of(context).size;

    return Hero(
      tag: 'list' + title,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.grey,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                width: size.width,
                height: size.height,
                child: Image.asset('assets/polygon.jpg'),
              ),
              Column(
                children: [
                  UserHeader(headerURL, imageURL),
                  comment.length != 0
                      ? UserNameComment(title, comment)
                      : UserName(title),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: UserHobby(userlist),
                  ),
                  chat ? talkbutton(context) : Container(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget talkbutton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: RaisedButton(
            elevation: 7.0,
            highlightColor: Colors.green, //押したときに変わる色
            shape: StadiumBorder(),
            child: Text(
              '二人だけで会話',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            color: Colors.green,
            onPressed: () async {
              await makeChat();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => Chat(
                    opponent: title,
                    room: compstring(username, title),
                    chatcompUrl: imageURL,
                    block: block,
                    blockuser: blockuser,
                  ),
                ),
              );
            }),
      ),
    );
  }
}
