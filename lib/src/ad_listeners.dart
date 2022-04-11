import 'ad_containers.dart';

/// The callback type to handle an event occurring for an [Ad].
typedef AdEventCallback = void Function(Ad ad);

/// Generic callback type for an event occurring on an Ad.
typedef GenericAdEventCallback<Ad> = void Function(Ad ad);

/// A callback type for when dismissed a splash ad.
typedef SplashAdDismissedCallback<Ad> = void Function(Ad ad, DismissType type);

/// A callback type for when dismissed a rewarded ad.
typedef RewardedAdDismissedCallback<Ad> = void Function(Ad ad, RewardInfo rewardInfo);

/// A callback type for when an error occurs loading a full screen ad.
typedef FullScreenAdLoadErrorCallback = void Function(String error);

/// Callback events for for splash ads.
class SplashContentCallback<Ad> {
  /// Construct a new [SplashContentCallback].
  ///
  /// [Ad.dispose] should be called from [onAdFailedToShowFullScreenContent]
  /// and [onAdDismissedFullScreenContent], in order to free up resources.
  const SplashContentCallback({
    this.onAdShowedFullScreenContent,
    this.onAdFailedToShowFullScreenContent,
    this.onAdDismissedFullScreenContent,
    this.onAdClicked,
  });

  /// Called when an ad shows full screen content.
  final GenericAdEventCallback<Ad>? onAdShowedFullScreenContent;

  /// Called when an ad dismisses full screen content.
  final SplashAdDismissedCallback<Ad>? onAdDismissedFullScreenContent;

  /// Called when an ad is clicked.
  final GenericAdEventCallback<Ad>? onAdClicked;

  /// Called when ad fails to show full screen content.
  final void Function(Ad ad, String error)? onAdFailedToShowFullScreenContent;
}

/// Callback events for for full screen ads, such as Rewarded and Interstitial.
class FullScreenContentCallback<Ad> {
  /// Construct a new [FullScreenContentCallback].
  ///
  /// [Ad.dispose] should be called from [onAdFailedToShowFullScreenContent]
  /// and [onAdDismissedFullScreenContent], in order to free up resources.
  const FullScreenContentCallback({
    this.onAdShowedFullScreenContent,
    this.onAdFailedToShowFullScreenContent,
    this.onAdDismissedFullScreenContent,
    this.onAdClicked,
    this.onAdCompleted,
    this.onAdEndCardShowed,
  });

  /// Called when an ad shows full screen content.
  final GenericAdEventCallback<Ad>? onAdShowedFullScreenContent;

  /// Called when an ad dismisses full screen content.
  final RewardedAdDismissedCallback<Ad>? onAdDismissedFullScreenContent;

  /// Called when an ad is clicked.
  final GenericAdEventCallback<Ad>? onAdClicked;

  /// Called when an ad is completed.
  final GenericAdEventCallback<Ad>? onAdCompleted;

  /// Called when an ad shows end card.
  final GenericAdEventCallback<Ad>? onAdEndCardShowed;

  /// Called when ad fails to show full screen content.
  final void Function(Ad ad, String error)? onAdFailedToShowFullScreenContent;
}

/// Generic parent class for ad load callbacks.
abstract class FullScreenAdLoadCallback<T> {
  /// Default constructor for [FullScreenAdLoadCallback[, used by subclasses.
  const FullScreenAdLoadCallback({
    required this.onAdLoaded,
    required this.onAdFailedToLoad,
  });

  /// Called when the ad successfully loads.
  final GenericAdEventCallback<T> onAdLoaded;

  /// Called when an error occurs loading the ad.
  final FullScreenAdLoadErrorCallback onAdFailedToLoad;
}

/// This class holds callbacks for loading a [RewardVideoAd].
class RewardedAdLoadCallback extends FullScreenAdLoadCallback<RewardVideoAd> {
  /// Construct a [RewardedAdLoadCallback].
  const RewardedAdLoadCallback({
    required GenericAdEventCallback<RewardVideoAd> onAdLoaded,
    required FullScreenAdLoadErrorCallback onAdFailedToLoad,
  }) : super(onAdLoaded: onAdLoaded, onAdFailedToLoad: onAdFailedToLoad);
}

/// This class holds callbacks for loading an [SplashAd].
class SplashAdLoadCallback extends FullScreenAdLoadCallback<SplashAd> {
  /// Construct an [SplashAdLoadCallback].
  const SplashAdLoadCallback({
    required GenericAdEventCallback<SplashAd> onAdLoaded,
    required FullScreenAdLoadErrorCallback onAdFailedToLoad,
  }) : super(onAdLoaded: onAdLoaded, onAdFailedToLoad: onAdFailedToLoad);
}