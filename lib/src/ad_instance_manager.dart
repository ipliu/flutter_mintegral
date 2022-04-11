import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ad_containers.dart';

/// Loads and disposes [BannerAds] and [InterstitialAds].
AdInstanceManager instanceManager = AdInstanceManager('flutter_mintegral');

/// Maintains access to loaded [Ad] instances and handles sending/receiving
/// messages to platform code.
class AdInstanceManager {
  AdInstanceManager(String channelName)
      : channel = MethodChannel(
          channelName,
          StandardMethodCodec(AdMessageCodec()),
  ) {
    channel.setMethodCallHandler((MethodCall call) async {
      assert(call.method == 'onAdEvent');

      final int adId = call.arguments['adId'];
      final String eventName = call.arguments['eventName'];

      final Ad? ad = adFor(adId);
      if (ad != null) {
        _onAdEvent(ad, eventName, call.arguments);
      } else {
        debugPrint('$Ad with id `$adId` is not available for $eventName.');
      }
    });
  }

  int _nextAdId = 0;
  final _BiMap<int, Ad> _loadedAds = _BiMap<int, Ad>();

  /// Invokes load and dispose calls.
  final MethodChannel channel;

  void _onAdEvent(Ad ad, String eventName, Map<dynamic, dynamic> arguments) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _onAdEventAndroid(ad, eventName, arguments);
    } else {
      _onAdEventIOS(ad, eventName, arguments);
    }
  }

  void _onAdEventAndroid(
      Ad ad, String eventName, Map<dynamic, dynamic> arguments) {
    switch (eventName) {
      case 'onAdLoaded':
        _invokeOnAdLoaded(ad, eventName, arguments);
        break;
      case 'onAdFailedToLoad':
        _invokeOnAdFailedToLoad(ad, eventName, arguments);
        break;
      // case 'onAdOpened':
      //   _invokeOnAdOpened(ad, eventName);
      //   break;
      // case 'onAdClosed':
      //   _invokeOnAdClosed(ad, eventName);
      //   break;
      // case 'onAppEvent':
      //   _invokeOnAppEvent(ad, eventName, arguments);
      //   break;
      // case 'onRewardedAdUserEarnedReward':
      // case 'onRewardedInterstitialAdUserEarnedReward':
      //   _invokeOnUserEarnedReward(ad, eventName, arguments);
      //   break;
      // case 'onAdImpression':
      //   _invokeOnAdImpression(ad, eventName);
      //   break;
      case 'onFailedToShowFullScreenContent':
        _invokeOnAdFailedToShowFullScreenContent(ad, eventName, arguments);
        break;
      case 'onAdShowedFullScreenContent':
        _invokeOnAdShowedFullScreenContent(ad, eventName);
        break;
      case 'onAdDismissedFullScreenContent':
        _invokeOnAdDismissedFullScreenContent(ad, eventName, arguments);
        break;
      case 'onAdClicked':
        _invokeOnAdClicked(ad, eventName);
        break;
      case 'onAdCompleted':
        _invokeOnAdCompleted(ad, eventName);
        break;
      case 'onAdEndCardShowed':
        _invokeOnAdEndCardShowed(ad, eventName);
        break;
      default:
        debugPrint('invalid ad event name: $eventName');
    }
  }

  void _onAdEventIOS(Ad ad, String eventName, Map<dynamic, dynamic> arguments) {
  }

  void _invokeOnAdLoaded(
      Ad ad, String eventName, Map<dynamic, dynamic> arguments) {
    if (ad is SplashAd) {
      ad.adLoadCallback.onAdLoaded.call(ad);
    } else if (ad is RewardVideoAd) {
      ad.rewardedAdLoadCallback.onAdLoaded.call(ad);
    } else {
      debugPrint('invalid ad: $ad, for event name: $eventName');
    }
  }

  void _invokeOnAdFailedToLoad(
      Ad ad, String eventName, Map<dynamic, dynamic> arguments) {
    if (ad is SplashAd) {
      ad.dispose();
      ad.adLoadCallback.onAdFailedToLoad.call(arguments['loadAdError']);
    } else if (ad is RewardVideoAd) {
      ad.dispose();
      ad.rewardedAdLoadCallback.onAdFailedToLoad.call(arguments['loadAdError']);
    } else {
      debugPrint('invalid ad: $ad, for event name: $eventName');
    }
  }

  void _invokeOnAdShowedFullScreenContent(Ad ad, String eventName) {
    if (ad is SplashAd) {
      ad.splashContentCallback?.onAdShowedFullScreenContent?.call(ad);
    } else if (ad is RewardVideoAd) {
      ad.fullScreenContentCallback?.onAdShowedFullScreenContent?.call(ad);
    } else {
      debugPrint('invalid ad: $ad, for event name: $eventName');
    }
  }

  void _invokeOnAdDismissedFullScreenContent(
      Ad ad, String eventName, Map<dynamic, dynamic> arguments) {
    if (ad is SplashAd) {
      DismissType type = DismissType.invalid;
      switch (arguments['type']) {
        case 1:
          type = DismissType.skipped;
          break;
        case 2:
          type = DismissType.completed;
          break;
        case 3:
          type = DismissType.leaveApp;
          break;
      }
      ad.splashContentCallback?.onAdDismissedFullScreenContent?.call(ad, type);
    } else if (ad is RewardVideoAd) {
      ad.fullScreenContentCallback?.onAdDismissedFullScreenContent?.call(
          ad, arguments['rewardInfo']);
    } else {
      debugPrint('invalid ad: $ad, for event name: $eventName');
    }
  }

  void _invokeOnAdFailedToShowFullScreenContent(
      Ad ad, String eventName, Map<dynamic, dynamic> arguments) {
    if (ad is SplashAd) {
      ad.splashContentCallback?.onAdFailedToShowFullScreenContent
          ?.call(ad, arguments['error']);
    } else if (ad is RewardVideoAd) {
      ad.fullScreenContentCallback?.onAdFailedToShowFullScreenContent
          ?.call(ad, arguments['error']);
    } else {
      debugPrint('invalid ad: $ad, for event name: $eventName');
    }
  }

  void _invokeOnAdClicked(Ad ad, String eventName) {
    if (ad is SplashAd) {
      ad.splashContentCallback?.onAdClicked?.call(ad);
    } else if (ad is RewardVideoAd) {
      ad.fullScreenContentCallback?.onAdClicked?.call(ad);
    } else {
      debugPrint('invalid ad: $ad, for event name: $eventName');
    }
  }

  void _invokeOnAdCompleted(Ad ad, String eventName) {
    if (ad is RewardVideoAd) {
      ad.fullScreenContentCallback?.onAdCompleted?.call(ad);
    } else {
      debugPrint('invalid ad: $ad, for event name: $eventName');
    }
  }

  void _invokeOnAdEndCardShowed(Ad ad, String eventName) {
    if (ad is RewardVideoAd) {
      ad.fullScreenContentCallback?.onAdEndCardShowed?.call(ad);
    } else {
      debugPrint('invalid ad: $ad, for event name: $eventName');
    }
  }

  Future<Map<dynamic, dynamic>> initialize({
    required String appId,
    required String appKey,
  }) async {
    return (await instanceManager.channel.invokeMethod<Map<dynamic, dynamic>>(
      'initialize', {'appId': appId, 'appKey': appKey}
    ))!;
  }

  /// Returns null if an invalid [adId] was passed in.
  Ad? adFor(int adId) => _loadedAds[adId];

  /// Returns null if an invalid [Ad] was passed in.
  int? adIdFor(Ad ad) => _loadedAds.inverse[ad];

  /// Load an splash ad.
  Future<void> loadSplashAd(SplashAd ad) {
    if (adIdFor(ad) != null) {
      return Future<void>.value();
    }

    final int adId = _nextAdId++;
    _loadedAds[adId] = ad;
    return channel.invokeMethod<void>(
      'loadSplashAd',
      <dynamic, dynamic>{
        'adId': adId,
        'placementId': ad.placementId,
        'unitId': ad.unitId,
      },
    );
  }

  /// Starts loading the ad if not previously loaded.
  ///
  /// Loading also terminates if ad is already in the process of loading.
  Future<void> loadRewardVideoAd(RewardVideoAd ad) {
    if (adIdFor(ad) != null) {
      return Future<void>.value();
    }

    final int adId = _nextAdId++;
    _loadedAds[adId] = ad;
    return channel.invokeMethod<void>(
      'loadRewardVideoAd',
      <dynamic, dynamic>{
        'adId': adId,
        'placementId': ad.placementId,
        'unitId': ad.unitId,
        'isRewardPlus': ad.isRewardPlus,
      },
    );
  }

  /// Free the plugin resources associated with this ad.
  ///
  /// Disposing a banner ad that's been shown removes it from the screen.
  /// Interstitial ads can't be programmatically removed from view.
  Future<void> disposeAd(Ad ad) {
    final int? adId = adIdFor(ad);
    final Ad? disposedAd = _loadedAds.remove(adId);
    if (disposedAd == null) {
      return Future<void>.value();
    }
    return channel.invokeMethod<void>(
      'disposeAd',
      <dynamic, dynamic>{
        'adId': adId,
      },
    );
  }

  /// Display an [AdWithoutView] that is overlaid on top of the application.
  Future<void> showAdWithoutView(AdWithoutView ad) {
    assert(
    adIdFor(ad) != null,
    '$Ad has not been loaded or has already been disposed.',
    );

    return channel.invokeMethod<void>(
      'showAdWithoutView',
      <dynamic, dynamic>{
        'adId': adIdFor(ad),
      },
    );
  }
}

class AdMessageCodec extends StandardMessageCodec {
  // The type values below must be consistent for each platform.
  static const int _valueMBridgeIds = 128;
  static const int _valueRewardInfo = 129;

  @override
  void writeValue(WriteBuffer buffer, dynamic value) {
    if (value is MBridgeIds) {
      buffer.putUint8(_valueMBridgeIds);
      writeValue(buffer, value.placementId);
      writeValue(buffer, value.unitId);
      writeValue(buffer, value.bidToken);
    } else if (value is RewardInfo) {
      buffer.putUint8(_valueRewardInfo);
      writeValue(buffer, value.isCompleteView);
      writeValue(buffer, value.rewardName);
      writeValue(buffer, value.rewardAmount);
      writeValue(buffer, value.rewardAlertStatus);
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  dynamic readValueOfType(dynamic type, ReadBuffer buffer) {
    switch (type) {
      case _valueMBridgeIds:
        return MBridgeIds(
            placementId: readValueOfType(buffer.getUint8(), buffer),
            unitId: readValueOfType(buffer.getUint8(), buffer),
            bidToken: readValueOfType(buffer.getUint8(), buffer));
      case _valueRewardInfo:
        return RewardInfo(
            readValueOfType(buffer.getUint8(), buffer),
            readValueOfType(buffer.getUint8(), buffer),
            readValueOfType(buffer.getUint8(), buffer),
            readValueOfType(buffer.getUint8(), buffer));
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class _BiMap<K extends Object, V extends Object> extends MapBase<K, V> {
  _BiMap() {
    _inverse = _BiMap<V, K>._inverse(this);
  }

  _BiMap._inverse(this._inverse);

  final Map<K, V> _map = <K, V>{};
  late _BiMap<V, K> _inverse;

  _BiMap<V, K> get inverse => _inverse;

  @override
  V? operator [](Object? key) => _map[key];

  @override
  void operator []=(K key, V value) {
    assert(!_map.containsKey(key));
    assert(!inverse.containsKey(value));
    _map[key] = value;
    inverse._map[value] = key;
  }

  @override
  void clear() {
    _map.clear();
    inverse._map.clear();
  }

  @override
  Iterable<K> get keys => _map.keys;

  @override
  V? remove(Object? key) {
    if (key == null) return null;
    final V? value = _map[key];
    inverse._map.remove(value);
    return _map.remove(key);
  }
}
