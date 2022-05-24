import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mintegral/flutter_mintegral.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String appId = '144002';
  final String appKey = '7c22942b749fe6a6e361b675e96b3ee9';

  bool sdkInit = false;
  SplashAd? _splashAd;
  RewardVideoAd? _rewardVideoAd;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
  }

  Future<void> initSdk() async {
    Mintegral.instance.initialize(
      appId: appId,
      appKey: appKey,
      onInitSuccess: () {
        debugPrint('[Mintegral] Initialization Complete.');
        setState(() {
          sdkInit = true;
        });
      },
      onInitFail: (error) {
        debugPrint('[Mintegral] Initialization Failed: $error');
      },
    );
  }

  void loadSplashAd() {
    SplashAd.load(
      placementId: '328916',
      unitId: '1542060',
      adLoadCallback: SplashAdLoadCallback(
        onAdLoaded: (SplashAd ad) {
          debugPrint('[Mintegral] SplashAd loaded.');
          setState(() {
            _splashAd = ad;
          });
        },
        onAdFailedToLoad: (String error) {
          debugPrint('[Mintegral] SplashAd load failed. $error');
        },
      ),
    );
  }

  void showSplashAd() {
    _splashAd?.splashContentCallback = SplashContentCallback(
      onAdShowedFullScreenContent: (SplashAd ad) {
        debugPrint('[Mintegral] SplashAd onAdShowedFullScreenContent.');
      },
      onAdDismissedFullScreenContent: (SplashAd ad, DismissType type) {
        debugPrint('[Mintegral] SplashAd onAdDismissedFullScreenContent. type: $type');
        ad.dispose();
        setState(() {
          _splashAd = null;
        });
      },
      onAdFailedToShowFullScreenContent: (SplashAd ad, String error) {
        debugPrint('[Mintegral] SplashAd onAdFailedToShowFullScreenContent. $error');
        ad.dispose();
        setState(() {
          _splashAd = null;
        });
      },
      onAdClicked: (SplashAd ad) {
        debugPrint('[Mintegral] SplashAd onAdClicked.');
      },
    );
    _splashAd?.show();
  }

  void loadRewardVideoAd() {
    RewardVideoAd.load(
      placementId: '290651',
      unitId: '462372',
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardVideoAd ad) {
          debugPrint('[Mintegral] RewardVideoAd loaded.');
          setState(() {
            _rewardVideoAd = ad;
          });
        },
        onAdFailedToLoad: (String error) {
          debugPrint('[Mintegral] RewardVideoAd load failed. $error');
        },
      ),
    );
  }

  void showRewardVideoAd() {
    _rewardVideoAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardVideoAd ad) {
        debugPrint('[Mintegral] RewardVideoAd onAdShowedFullScreenContent.');
      },
      onAdDismissedFullScreenContent: (RewardVideoAd ad, RewardInfo rewardInfo) {
        debugPrint('[Mintegral] RewardVideoAd onAdDismissedFullScreenContent. rewardInfo: ${rewardInfo.toString()}');
        ad.dispose();
        setState(() {
          _rewardVideoAd = null;
        });
      },
      onAdFailedToShowFullScreenContent: (RewardVideoAd ad, String error) {
        debugPrint('[Mintegral] RewardVideoAd onAdFailedToShowFullScreenContent. $error');
        ad.dispose();
        setState(() {
          _rewardVideoAd = null;
        });
      },
      onAdClicked: (RewardVideoAd ad) {
        debugPrint('[Mintegral] RewardVideoAd onAdClicked.');
      },
      onAdCompleted: (RewardVideoAd ad) {
        debugPrint('[Mintegral] RewardVideoAd onAdCompleted.');
      },
      onAdEndCardShowed: (RewardVideoAd ad) {
        debugPrint('[Mintegral] RewardVideoAd onAdEndCardShowed.');
      },
    );
    _rewardVideoAd?.show();
  }

  void loadBannerAd() {
    BannerAd(
      size: AdSize.standard,
      placementId: '290655',
      unitId: '462376',
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('[Mintegral] BannerAd onAdLoaded.');
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[Mintegral] BannerAd onAdFailedToLoad. error: $error');
          ad.dispose();
          setState(() {
            _bannerAd = null;
          });
        },
        onAdImpression: (ad) {
          debugPrint('[Mintegral] BannerAd onAdImpression.');
        },
        onAdClicked: (ad) {
          debugPrint('[Mintegral] BannerAd onAdClicked.');
        },
        onAdClosed: (ad) {
          debugPrint('[Mintegral] BannerAd onAdClosed.');
          ad.dispose();
          setState(() {
            _bannerAd = null;
          });
        },
        onAdLeftApplication: (ad) {
          debugPrint('[Mintegral] BannerAd onAdLeftApplication.');
        },
      ),
    ).load();
  }

  Widget showBannerAd(BannerAd bannerAd) {
    return AdWidget(ad: bannerAd);
  }

  void disposeBannerAd() {
    if (_bannerAd != null) {
      _bannerAd?.dispose();
      _bannerAd = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    BannerAd? bannerAd = _bannerAd;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text(sdkInit
                  ? 'Mintegral SDK initialized - $appId'
                  : 'Init Mintegral SDK - $appId'),
              onPressed: sdkInit ? null : initSdk,
            ),
            ElevatedButton(
              child: Text(_splashAd == null
                  ? 'Load Splash Ad'
                  : 'Show Splash Ad'),
              onPressed: !sdkInit ? null
                  : _splashAd == null ? loadSplashAd : showSplashAd,
            ),
            ElevatedButton(
              child: Text(_rewardVideoAd == null
                  ? 'Load Reward Video Ad'
                  : 'Show Reward Video Ad'),
              onPressed: !sdkInit ? null
                  : _rewardVideoAd == null ? loadRewardVideoAd : showRewardVideoAd,
            ),
            ElevatedButton(
              child: Text(bannerAd == null
                  ? 'Load Banner Ad'
                  : 'Dispose Banner Ad'),
              onPressed: !sdkInit ? null
                  : bannerAd == null ? loadBannerAd : disposeBannerAd,
            ),
            Center(child: Text('Initialization status: $sdkInit\n')),
            if (bannerAd != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: showBannerAd(bannerAd),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
