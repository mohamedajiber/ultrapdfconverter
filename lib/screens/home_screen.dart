import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Ads package
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeToggle;
  final Future<String> Function(String)? copyAssetPdfToFile;

  const HomeScreen({
    Key? key,
    required this.isDarkMode,
    required this.onDarkModeToggle,
    this.copyAssetPdfToFile,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  bool _isPremiumUnlocked = false;

  @override
  void initState() {
    super.initState();

    // Load banner ad
    _bannerAd = BannerAd(
      adUnitId:
          '<ca-app-pub-9650219334012651/8678676578>', // Replace with your real Banner Ad Unit ID
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('BannerAd failed to load: $error');
        },
      ),
    );

    _bannerAd.load();

    // Load rewarded ad
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId:
          '<ca-app-pub-9650219334012651/3878835526>', // Replace with your real Rewarded Ad Unit ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;

          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              _isRewardedAdReady = false;
              _loadRewardedAd(); // preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              _isRewardedAdReady = false;
              _loadRewardedAd(); // preload next
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          setState(() {
            _isPremiumUnlocked = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Reward earned: ${reward.amount} ${reward.type}. Premium Unlocked!'),
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Rewarded Ad is not ready yet, please try again later.')),
      );
    }
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(appName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDarkMode
                ? [Colors.black87, Colors.grey[900]!]
                : const [Color(0xFF3A3A98), Color(0xFF6D83F2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 80),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Ultra PDF Converter',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 50),
                      _buildHomeButton(
                        icon: Icons.image,
                        label: 'Images to PDF',
                        onPressed: () =>
                            Navigator.pushNamed(context, '/imageToPdf'),
                      ),
                      const SizedBox(height: 20),
                      _buildHomeButton(
                        icon: Icons.file_copy,
                        label: 'Word to PDF',
                        onPressed: () =>
                            Navigator.pushNamed(context, '/wordToPdf'),
                      ),
                      const SizedBox(height: 20),
                      _buildHomeButton(
                        icon: Icons.picture_as_pdf,
                        label: 'View PDFs',
                        onPressed: () async {
                          if (widget.copyAssetPdfToFile != null) {
                            try {
                              final pdfFilePath = await widget
                                  .copyAssetPdfToFile!('assets/sample.pdf');
                              Navigator.pushNamed(context, '/pdfViewer',
                                  arguments: pdfFilePath);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Failed to load PDF: $e')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('PDF viewer not available')),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 30),

                      // Rewarded Ad unlock button
                      _buildHomeButton(
                        icon: _isPremiumUnlocked ? Icons.lock_open : Icons.lock,
                        label: _isPremiumUnlocked
                            ? 'Premium Unlocked!'
                            : 'Watch Ad to Unlock Premium',
                        onPressed: _isPremiumUnlocked ? null : _showRewardedAd,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isBannerAdReady)
              Container(
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                alignment: Alignment.center,
                child: AdWidget(ad: _bannerAd),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 26),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null ? Colors.grey : Colors.white,
          foregroundColor: onPressed == null ? Colors.black38 : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
