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
  RewardVideoAd? _rewardVideoAd;

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
        setState(() {
          _rewardVideoAd = null;
        });
      },
      onAdFailedToShowFullScreenContent: (RewardVideoAd ad, String error) {
        debugPrint('[Mintegral] RewardVideoAd onAdFailedToShowFullScreenContent. $error');
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

  @override
  Widget build(BuildContext context) {
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
              child: Text(_rewardVideoAd == null
                  ? 'Load Reward Video Ad'
                  : 'Show Reward Video Ad'),
              onPressed: _rewardVideoAd == null ? loadRewardVideoAd : showRewardVideoAd,
            ),
            Center(child: Text('Initialization status: $sdkInit\n')),
          ],
        ),
      ),
    );
  }
}
