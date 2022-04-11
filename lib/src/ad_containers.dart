import 'package:flutter/foundation.dart';

import 'ad_instance_manager.dart';
import 'ad_listeners.dart';

enum DismissType {invalid, skipped, completed, leaveApp}

/// Contains information about the loaded ad.
///
/// For debugging and logging purposes.
class MBridgeIds {
  /// Constructs a [MBridgeIds] with the [placementId], [unitId] and [bidToken].
  @protected
  const MBridgeIds({
    required this.placementId, required this.unitId, required this.bidToken});

  final String placementId;

  final String unitId;

  final String bidToken;

  @override
  String toString() {
    return '$runtimeType(placementId: $placementId, unitId: $unitId, '
        'bidToken: $bidToken)';
  }
}

/// The base class for all ads.
///
/// A valid [placementId] and [unitId] is required.
abstract class Ad {
  /// Default constructor, used by subclasses.
  Ad({required this.placementId, required this.unitId});

  final String placementId;

  final String unitId;

  /// Frees the plugin resources associated with this ad.
  Future<void> dispose() {
    return instanceManager.disposeAd(this);
  }

  MBridgeIds? mBridgeIds;
}

/// An [Ad] that is overlaid on top of the UI.
abstract class AdWithoutView extends Ad {
  /// Default constructor used by subclasses.
  AdWithoutView({required String placementId, required String unitId})
      : super(placementId: placementId, unitId: unitId);
}

/// A full-screen app open ad for the Mintegral Plugin.
class SplashAd extends AdWithoutView {

  SplashAd._({
    required String placementId,
    required String unitId,
    required this.adLoadCallback,
  })  : super(placementId: placementId, unitId: unitId);

  /// Listener for ad load events.
  final SplashAdLoadCallback adLoadCallback;

  /// Callbacks to be invoked when ads show and dismiss full screen content.
  SplashContentCallback<SplashAd>? splashContentCallback;

  static Future<void> load({
    required String placementId,
    required String unitId,
    required SplashAdLoadCallback adLoadCallback,
  }) async {
    SplashAd splashAd = SplashAd._(
      placementId: placementId,
      unitId: unitId,
      adLoadCallback: adLoadCallback,
    );

    await instanceManager.loadSplashAd(splashAd);
  }

  /// Display this on top of the application.
  ///
  /// Set [splashContentCallback] before calling this method to be
  /// notified of events that occur when showing the ad.
  Future<void> show() {
    return instanceManager.showAdWithoutView(this);
  }
}

/// An [Ad] where a user has the option of interacting with in exchange for in-app rewards.
///
/// Because the video assets are so large, it's a good idea to start loading an
/// ad well in advance of when it's likely to be needed.
class RewardVideoAd extends AdWithoutView {

  RewardVideoAd._({
    required String placementId,
    required String unitId,
    required this.rewardedAdLoadCallback,
    this.isRewardPlus,
  })  : super(placementId: placementId, unitId: unitId);

  /// Callbacks for events that occur when attempting to load an ad.
  final RewardedAdLoadCallback rewardedAdLoadCallback;

  /// Callbacks to be invoked when ads show and dismiss full screen content.
  FullScreenContentCallback<RewardVideoAd>? fullScreenContentCallback;

  /// Accepting the advertisement of Reward plus
  final bool? isRewardPlus;

  /// Loads a [RewardVideoAd] using an [AdRequest].
  static Future<void> load({
    required String placementId,
    required String unitId,
    required RewardedAdLoadCallback rewardedAdLoadCallback,
    bool? isRewardPlus,
  }) async {
    RewardVideoAd rewardVideoAd = RewardVideoAd._(
      placementId: placementId,
      unitId: unitId,
      rewardedAdLoadCallback: rewardedAdLoadCallback,
      isRewardPlus: isRewardPlus,
    );

    await instanceManager.loadRewardVideoAd(rewardVideoAd);
  }

  /// Display this on top of the application.
  ///
  /// Set [fullScreenContentCallback] before calling this method to be
  /// notified of events that occur when showing the ad.
  Future<void> show() {
    return instanceManager.showAdWithoutView(this);
  }
}

/// Credit information about a reward received from a [RewardVideoAd] or
/// [InterstitialAd].
class RewardInfo {
  /// Default constructor for [RewardInfo].
  ///
  /// This is mostly used to return [RewardInfo]s for a [RewardVideoAd] or
  /// [InterstitialAd] and shouldn't be needed to be used directly.
  RewardInfo(
      this.isCompleteView,
      this.rewardName,
      this.rewardAmount,
      this.rewardAlertStatus);

  final bool isCompleteView;

  final String rewardName;

  final String rewardAmount;

  final int rewardAlertStatus;

  @override
  String toString() {
    return '$runtimeType(isCompleteView: $isCompleteView, '
        'rewardName: $rewardName, '
        'rewardAmount: $rewardAmount, '
        'rewardAlertStatus: $rewardAlertStatus)';
  }
}
