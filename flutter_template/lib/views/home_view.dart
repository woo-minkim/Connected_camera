import 'package:flutter/material.dart';
import 'package:fluttertemplate/controllers/face_detection_controller.dart';
import 'package:fluttertemplate/services/app_launcher_service.dart';
import 'package:fluttertemplate/services/display_service.dart';
import 'package:fluttertemplate/services/volume_service.dart';
import 'package:fluttertemplate/services/weather_service.dart';
import 'package:fluttertemplate/theme/app_theme.dart';
import 'package:fluttertemplate/widgets/soft_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Services
  static const AppLauncherService _launcher = AppLauncherService();
  final VolumeService _volumeService = VolumeService();
  final WeatherService _weatherService = WeatherService();
  final DisplayService _displayService = DisplayService();

  // State
  double? _manualBrightness;
  double _volumeLevel = 15;
  WeatherInfo? _weatherInfo;

  @override
  void initState() {
    super.initState();
    _loadAmbientData();
  }

  Future<void> _loadAmbientData() async {
    try {
      final weather = await _weatherService.fetchWeather();
      final volume = await _volumeService.getVolumeLevel();
      final brightness = await _displayService.getBrightnessLevel();
      if (!mounted) return;
      setState(() {
        _weatherInfo = weather;
        _volumeLevel = volume.toDouble();
        _manualBrightness = brightness.toDouble();
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final controller = FaceDetectionScope.of(context);
    _manualBrightness ??= controller.suggestedBrightness.toDouble();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(controller),
              const SizedBox(height: 32),
              
              // Bento Grid
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column (Main Featured + Weather)
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildFeaturedCard(),
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            flex: 1,
                            child: _buildWeatherCard(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    
                    // Right Column (Controls + List)
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildControlGrid(controller),
                          const SizedBox(height: 24),
                          Expanded(
                            child: _buildContentList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(FaceDetectionController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good Morning,",
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Text(
              "Dad",
              style: AppTextStyles.displayMedium,
            ),
          ],
        ),
        SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          borderRadius: 50,
          onTap: () => Navigator.pushNamed(context, '/camera'),
          child: Row(
            children: [
              Icon(Icons.face, color: AppColors.accentBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                "${controller.faceCount} Active",
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.accentBlue),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: AppColors.accentBlue.withOpacity(0.5), size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard() {
    return SoftCard(
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Image.network(
              'https://images.unsplash.com/photo-1516280440614-6697288d5d38?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.accentBlue.withOpacity(0.1)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Text(
                    "Featured",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Interior Design Trends 2024",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Discover the soft minimalist aesthetic for your home.",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    final info = _weatherInfo;
    return SoftCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${info?.temperature ?? '--'}°",
                  style: AppTextStyles.displayLarge,
                ),
                Text(
                  info?.condition ?? "Loading...",
                  style: AppTextStyles.bodyLarge,
                ),
              ],
            ),
          ),
          Icon(
            Icons.wb_sunny_rounded,
            size: 80,
            color: AppColors.accentOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildControlGrid(FaceDetectionController controller) {
    return Row(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: SoftCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.volume_up_rounded, size: 24, color: AppColors.textPrimary),
                      Text("${_volumeLevel.round()}%", style: AppTextStyles.labelLarge),
                    ],
                  ),
                  Expanded(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.textPrimary,
                          inactiveTrackColor: AppColors.border,
                          thumbColor: AppColors.textPrimary,
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: Slider(
                          value: _volumeLevel,
                          min: 0,
                          max: 100,
                          onChanged: (v) => setState(() => _volumeLevel = v),
                          onChangeEnd: (v) => _volumeService.setVolumeLevel(v.round()),
                        ),
                      ),
                    ),
                  ),
                  const Text("Vol", style: AppTextStyles.labelLarge),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: SoftCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.brightness_6_rounded, size: 24, color: AppColors.textPrimary),
                      Text("${_manualBrightness?.round() ?? 50}%", style: AppTextStyles.labelLarge),
                    ],
                  ),
                  Expanded(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.accentOrange,
                          inactiveTrackColor: AppColors.border,
                          thumbColor: AppColors.accentOrange,
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: Slider(
                          value: _manualBrightness ?? 50,
                          min: 0,
                          max: 100,
                          onChanged: (v) => setState(() => _manualBrightness = v),
                          onChangeEnd: (v) => controller.setManualBrightness(v.round()),
                        ),
                      ),
                    ),
                  ),
                  const Text("Bri", style: AppTextStyles.labelLarge),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentList() {
    return SoftCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Continue Watching", style: AppTextStyles.titleLarge),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildListItem("Netflix", "Stranger Things", Icons.movie, Colors.red),
                const SizedBox(height: 16),
                _buildListItem("YouTube", "Tech Review", Icons.play_circle, Colors.redAccent),
                const SizedBox(height: 16),
                _buildListItem("Disney+", "Mandalorian", Icons.star, Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String title, String subtitle, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.labelLarge),
            Text(subtitle, style: AppTextStyles.bodyLarge.copyWith(fontSize: 14)),
          ],
        ),
        const Spacer(),
        Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ],
    );
  }
}
