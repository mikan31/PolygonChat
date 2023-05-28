import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sample/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class ImageChoice extends StatelessWidget {
  ImageChoice(this.username, this.userimage);
  String username;
  String userimage;

  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userimage = prefs.getString('image') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(builder: (context, model, child) {
      return InkWell(
          onTap: () async {
            //username + 'image'
            userimage = await model.setImage(username + 'image');
            if (userimage == null) getData();

            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            prefs.setString('image', userimage);
          },
          child: FutureBuilder(
              future: getData(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return Container(
                    child: Icon(Icons.collections),
                    width: 130.0,
                    height: 130.0,
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 7),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: userimage.isNotEmpty
                                ? NetworkImage(userimage)
                                : AssetImage('assets/preimage.JPG'),
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.6),
                                BlendMode.dstATop))));
              }));
    });
  }
}
