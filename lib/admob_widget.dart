import 'dart:async';
import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';

// BannerAdを2回以上disposeしないためのクラス。
// Singletonにすることで、間接的にBannerAd自体のインスタンスも一度に一つしか存在しないことを保証する。
// BannerAdをdisposeしたら、必ず、次をセットするかnullにする。
class _SingleBanner {
  factory _SingleBanner() {
    _instance ??= _SingleBanner._internal();
    return _instance;
  }
  _SingleBanner._internal();
  static _SingleBanner _instance;

  BannerAd _bannerAd;
  int _ownerHashCode; // 現在の所有者インスタンスは誰かを表す

  void show({
    @required int callerHashCode,
    @required String adUnitId,
    @required AdSize size,
    @required double anchorOffset,
    @required bool isMounted,
  }) {
    _bannerAd?.dispose(); // disposeしたら、必ず、次をセットするかnullにする。
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: size,
      listener: (MobileAdEvent event) {
        // loadが完了してからしかshowが呼ばれないようにリスナー登録
        // こうしないと、showを呼んでからロードが実際に完了するまでの間に画面が変化すると広告が消せなくなる
        if (event == MobileAdEvent.loaded) {
          if (isMounted) {
            _bannerAd.show(anchorOffset: anchorOffset);
          } else {
            _bannerAd = null;
          }
        }
      },
    );
    _ownerHashCode = callerHashCode;
    _bannerAd.load();
  }

  void dispose({@required int callerHashCode}) {
    // 最後に広告を生成したインスタンスが所有権を持ち、そこからしかdisposeできない。
    // 別のインスタンスが新たに広告生成を行った場合、所有権を失う。
    if (callerHashCode == _ownerHashCode) {
      _bannerAd?.dispose(); // disposeしたら、必ず、次をセットするかnullにする。
      _bannerAd = null;
    }
  }
}

class AdmobBannerWidget extends StatefulWidget {
  // Stateを外から挿入できるようにしておきます。挿入されなければ、普通にここで新しく作る。
  // Route使うバージョンの方で、外からこのStateにアクセスできるようにするため。
  const AdmobBannerWidget({_AdmobBannerWidgetState admobBannerWidgetState})
      : _admobBannerWidgetState = admobBannerWidgetState;
  final _AdmobBannerWidgetState _admobBannerWidgetState;

  @override
  _AdmobBannerWidgetState createState() =>
      _admobBannerWidgetState ?? _AdmobBannerWidgetState();
}

class _AdmobBannerWidgetState extends State<AdmobBannerWidget> {
  Timer _timer;
  double _bannerHeight;
  AdSize _adSize;
  // Navigatorスタックの最上位にいるのかどうかを示すフラグ
  bool isTop = true;

  void _loadAndShowBanner() {
    assert(_bannerHeight != null);
    assert(_adSize != null);
    _timer?.cancel();
    // Widgetのレンダリングが完了してなければ位置がわからないので、広告を表示しません。
    // レンダリングが完了するまでタイマーで繰り返します。
    _timer = Timer.periodic(Duration(seconds: 1), (Timer _thisTimer) async {
      final RenderBox _renderBox = context.findRenderObject();
      final bool _isRendered = _renderBox.hasSize;
      if (_isRendered) {
        _SingleBanner().show(
          isMounted: mounted,
          anchorOffset: _anchorOffset(),
          adUnitId: Platform.isAndroid
              ? 'ca-app-pub-9481691093118456/8949958600'
              : 'ca-app-pub-9481691093118456/2192978562',
          callerHashCode: hashCode,
          size: _adSize,
        );
        _thisTimer.cancel();
      }
    });
  }

  // ノッチとかを除いた範囲(SafeArea)の縦幅の1/8以内で最大の広告を表示します。
  // 広告の縦幅を明確にしたいのでSmartBannerは使いません。
  void _determineBannerSize() {
    final double _viewPaddingTop =
        WidgetsBinding.instance.window.viewPadding.top /
            MediaQuery.of(context).devicePixelRatio;
    final double _viewPaddingBottom =
        WidgetsBinding.instance.window.viewPadding.bottom /
            MediaQuery.of(context).devicePixelRatio;
    final double _screenWidth = MediaQuery.of(context).size.width;
    final double _availableScreenHeight = MediaQuery.of(context).size.height -
        _viewPaddingTop -
        _viewPaddingBottom;

    if (_screenWidth >= 728 && _availableScreenHeight >= 720) {
      _adSize = AdSize.leaderboard;
      _bannerHeight = 70; //90
    } else if (_screenWidth >= 468 && _availableScreenHeight >= 480) {
      _adSize = AdSize.fullBanner;
      _bannerHeight = 50; //60
    } else if (_screenWidth >= 320 && _availableScreenHeight >= 800) {
      _adSize = AdSize.largeBanner;
      _bannerHeight = 80; //100
    } else {
      _adSize = AdSize.banner;
      _bannerHeight = 30; //50
    }
  }

  // ノッチとかを除いた範囲(SafeArea)の下端を基準に、
  // このWidgetが論理ピクセルいくつ分だけ上に表示されているか計算します
  double _anchorOffset() {
    final RenderBox _renderBox = context.findRenderObject();
    assert(_renderBox.hasSize);
    final double _y = _renderBox.localToGlobal(Offset.zero).dy;
    final double _h = _renderBox.size.height;
    // viewPaddingだけ何故かMediaQueryで取得すると0だったので、windowから直接取得
    // 物理ピクセルが返るのでdevicePicelRatioで割って論理ピクセルに直す
    final double _vpb = WidgetsBinding.instance.window.viewPadding.bottom /
        MediaQuery.of(context).devicePixelRatio;
    final double _screenHeight = MediaQuery.of(context).size.height;
    return _screenHeight - _y - _h - _vpb;
  }

  @override
  Widget build(BuildContext context) {
    // 広告のスペースを確保するためのContainer。
    return Container(height: _bannerHeight, color: Colors.black);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQueryの変化を受けて呼ばれる。pushやpop、本体の回転でも呼ばれる。
    // 変更を検知したらまず即座に広告を消す。
    disposeBanner();
    if (isTop) {
      _determineBannerSize();
      _loadAndShowBanner();
    }
  }

  @override
  void dispose() {
    disposeBanner();
    super.dispose();
  }

  void disposeBanner() {
    _SingleBanner().dispose(callerHashCode: hashCode);
    _timer?.cancel();
  }
}
