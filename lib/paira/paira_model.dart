import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'package:location/location.dart';
import 'package:weather/weather.dart';

class PairaModel extends ChangeNotifier {
  String pairaText = '';
  String explainText = 'はじめまして。\nポリゴンチャットへ\nようこそ。\n\n(タップして次へ) 1/5';
  bool smallPaira = true;
  bool isExplain = true;
  bool isFirstChoice = true;
  var random = new math.Random();
  var counter = 0;

  String key = '823566e1327d4455d14e4e29353b104c';
  WeatherFactory ws;
  LocationData currentLocation;
  double lat, lon;
  Location _locationService = new Location();
  String error;

  bool isLoading = false;

  setLocation() async {
    LocationData myLocation;
    try {
      myLocation = await _locationService.getLocation();
      error = "";
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENITED')
        error = 'Permission denited';
      else if (e.code == 'PERMISSION_DENITED_NEVER_ASK')
        error =
            'Permission denited - please ask the user to enable it from the app settings';
      myLocation = null;
    }
    currentLocation = myLocation;

    _locationService.onLocationChanged.listen((LocationData result) async {
      currentLocation = result;
      lat = currentLocation.latitude;
      lon = currentLocation.longitude;
    });
  }

  pairaExplain() async {
    switch (counter) {
      case 0:
        explainText = '私はパイラ。\nここのガイドを\nしています。\n\n(タップして次へ) 2/5';
        counter++;
        break;
      case 1:
        explainText = 'ポリゴンチャットでは、\nシュミが同じ人どうしで\nツナガルことができます。\n\n(タップして次へ) 3/5';
        counter++;
        break;
      case 2:
        explainText = 'あなたの好きなことを\n登録してみましょう。\n\n(タップして次へ) 4/5';
        counter++;
        break;
      case 3:
        explainText = 'シュミは最大で\n５つまで選択できます。\n\n 5/5';
        counter++;
        break;
      case 4:
        counter = 0;
        break;
    }
    notifyListeners();
  }

  pairaTalk() async {
    ws = new WeatherFactory(key, language: Language.JAPANESE);

    if (pairaText.isEmpty) {
      switch (counter) {
        case 0:
          switch (random.nextInt(3)) {
            case 0:
              pairaText = 'おつかれですか？';
              break;
            case 1:
              pairaText = '今日もいい一日になると\nいいですね。';
              break;
            case 2:
              pairaText = 'いつも頑張ってますね。';
              break;
          }
          counter++;
          break;
        case 1:
          Weather weather = await ws.currentWeatherByLocation(lat, lon);
          pairaText = 'ここ' +
              weather.areaName +
              'の\n現在の天気は' +
              weather.weatherDescription +
              '、\n気温' +
              (weather.temperature).toString().replaceFirst(' Celsius', '℃') +
              '、\n湿度' +
              (weather.humidity).toString() +
              '\%です。';
          counter++;
          break;
        case 2:
          List<Weather> forecasts =
              await ws.fiveDayForecastByLocation(lat, lon);
          var nowtime = DateTime.now().hour;

          pairaText =
              /*'ここ' +
              forecasts[0].areaName +
              'の\n*/
              '3時間ごとの天気予報は\n' +
                  (nowtime + 3 > 24 ? nowtime + 3 - 24 : nowtime + 3)
                      .toString() +
                  '時: ' +
                  (forecasts[0].weatherDescription).toString() +
                  '\n' +
                  (nowtime + 6 > 24 ? nowtime + 6 - 24 : nowtime + 6)
                      .toString() +
                  '時: ' +
                  (forecasts[1].weatherDescription).toString() +
                  '\n' +
                  (nowtime + 9 > 24 ? nowtime + 9 - 24 : nowtime + 9)
                      .toString() +
                  '時: ' +
                  (forecasts[2].weatherDescription).toString() +
                  '\n' +
                  'でしょう。';
          counter = 0;
          break;
      }
      notifyListeners();

      /*await Future.delayed(Duration(seconds: 5));
      pairaText = '';
      notifyListeners();*/
    } else {
      pairaText = '';
      notifyListeners();
    }
  }

  pairaChange() {
    smallPaira ? smallPaira = false : smallPaira = true;
    notifyListeners();
  }

  startLoading() {
    isLoading = true;
    notifyListeners();
  }

  endLoading() {
    isLoading = false;
    notifyListeners();
  }

  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(
        DiagnosticsProperty<LocationData>('currentLocation', currentLocation));
  }
}
