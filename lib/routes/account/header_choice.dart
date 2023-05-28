import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sample/model.dart';
import 'package:sample/routes/account/image_choice.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class HeaderChoice extends StatelessWidget {
  HeaderChoice(this.username, this.userheader, this.userimage);
  String username;
  String userheader;
  String userimage;

  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userheader = prefs.getString('header') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Consumer<Model>(builder: (context, model, child) {
      return InkWell(
          onTap: () async {
            userheader = await model.setImage(username + 'header');
            if (userheader == null) getData();

            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            prefs.setString('header', userheader);
          },
          child: FutureBuilder(
              future: getData(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return Stack(
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      height: size.height / 4,
                      width: size.width,
                    ),
                    Container(
                        child: Icon(Icons.collections),
                        height: size.height / 4,
                        width: size.width,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image: userheader.isNotEmpty
                                    ? NetworkImage(userheader)
                                    : AssetImage('assets/preheader.jpg'),
                                colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.6),
                                    BlendMode.dstATop)))),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 100.0),
                        child: ImageChoice(username, userimage),
                      ),
                    ),
                  ],
                );
              }));
    });
  }
}
