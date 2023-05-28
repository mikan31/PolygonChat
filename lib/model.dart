import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';

class Model extends ChangeNotifier {
  String userName = '';
  String userMail = '';
  String userImage = '';
  String userHeader = '';
  String userPassword = '';
  String infoText = '';
  bool isLoading = false;

  startLoading() {
    isLoading = true;
    notifyListeners();
  }

  endLoading() {
    isLoading = false;
    notifyListeners();
  }

  pickImage() async {
    // ignore: deprecated_member_use
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
    var quality;
    if (decodedImage.width >= 4320 && decodedImage.height >= 7680) {
      quality = 2;
    } else if (decodedImage.width >= 2160 && decodedImage.height >= 3840) {
      quality = 10;
    } else if (decodedImage.width >= 1080 && decodedImage.height >= 1920) {
      quality = 25;
    } else {
      quality = 100;
    }

    return await FlutterNativeImage.compressImage(imageFile.path,
        quality: quality);
  }

  setImage(String filename) async {
    String imageURL;

    startLoading();
    // ignore: deprecated_member_use
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile == null) {
      endLoading();
      return null;
    }

    var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
    var quality;
    if (decodedImage.width >= 4320 && decodedImage.height >= 7680) {
      quality = 2;
    } else if (decodedImage.width >= 2160 && decodedImage.height >= 3840) {
      quality = 10;
    } else if (decodedImage.width >= 1080 && decodedImage.height >= 1920) {
      quality = 25;
    } else {
      quality = 100;
    }

    File compressedFile = await FlutterNativeImage.compressImage(imageFile.path,
        quality: quality);

    StorageReference ref =
        FirebaseStorage.instance.ref().child('user').child(filename);
    StorageUploadTask uploadTask = ref.putFile(compressedFile);
    imageURL = await (await uploadTask.onComplete).ref.getDownloadURL();

    endLoading();
    return imageURL;
  }

  Future<dynamic> dialog(BuildContext context, title) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
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
  }

  checkform(BuildContext context) {
    if (userName.isEmpty) {
      endLoading();
      dialog(context, 'ユーザー名を入力してください');
    } else if (userMail.isEmpty) {
      endLoading();
      dialog(context, 'メールアドレスを入力してください');
    } else if (userPassword.isEmpty) {
      endLoading();
      dialog(context, 'パスワードを入力してください');
    }
    /*else if (UserPassword.length < 6 ||
        RegExp(r"/^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-()@]")
            .hasMatch(UserPassword)) {
      endLoading();
      dialog(context, 'パスワードは半角英数字記号6文字以上で設定してください');
    } else if (!RegExp(
            r"/^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/)")
        .hasMatch(UserMail)) {
      endLoading();
      dialog(context, '有効なメールアドレスを入力してください');
    }*/
  }

  Widget textForm(BuildContext context, String title, String hinttext) {
    Size size = MediaQuery.of(context).size;

    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 5.0),
          child: Text(title, style: TextStyle(fontSize: 15)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Container(
            width: size.width * 0.6,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: TextField(
              maxLength: (title == 'ユーザー名') ? 8 : null,
              obscureText: (title == 'パスワード') ? true : false,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(
                      top: 5.0, bottom: 5.0, left: 10.0, right: 5.0),
                  hintText: hinttext),
              onChanged: (text) {
                switch (title) {
                  case 'ユーザー名':
                    userName = text;
                    break;
                  case 'Eメール':
                    userMail = text;
                    break;
                  case 'パスワード':
                    userPassword = text;
                    break;
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
