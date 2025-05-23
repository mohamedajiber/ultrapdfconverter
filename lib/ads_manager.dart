// lib/ads_manager.dart

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsManager {
  AdsManager._internal();

  static final AdsManager _instance = AdsManager._internal();

  factory AdsManager() => _instance;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isInterstitialAdReady = false;
  bool _isRewardedAdReady = false;

  static Future initialize() async {
    await MobileAds.instance.initialize();
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: '<ca-app-pub-9650219334012651/5582815340>',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdReady = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  /// Shows interstitial ad, and calls [onAdClosed] callback when ad is closed.
  void showInterstitialAd({required VoidCallback onAdClosed}) {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          onAdClosed();
          ad.dispose();
          _isInterstitialAdReady = false;
          loadInterstitialAd(); // preload next
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          onAdClosed();
          ad.dispose();
          _isInterstitialAdReady = false;
        },
      );
    } else {
      // If ad not ready, just call onAdClosed immediately
      onAdClosed();
    }
  }

  // Rewarded ads similar to previous example (optional)...
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: '<ca-app-pub-9650219334012651/4269733678>',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;

          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isRewardedAdReady = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  void showRewardedAd(VoidCallback onUserEarnedReward) {
    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        onUserEarnedReward();
      });
    }
  }
}
