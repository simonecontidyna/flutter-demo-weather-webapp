import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String iconCode;
  final double size;

  const WeatherIcon({super.key, required this.iconCode, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Icon(_getIconData(iconCode), size: size, color: _getIconColor(iconCode));
  }

  static IconData _getIconData(String code) {
    switch (code) {
      case '01d':
        return Icons.wb_sunny_rounded;
      case '01n':
        return Icons.nightlight_round;
      case '02d':
        return Icons.wb_cloudy_rounded;
      case '02n':
        return Icons.nights_stay_rounded;
      case '03d':
      case '03n':
        return Icons.cloud_rounded;
      case '04d':
      case '04n':
        return Icons.cloud_queue_rounded;
      case '09d':
      case '09n':
        return Icons.grain_rounded;
      case '10d':
      case '10n':
        return Icons.water_drop_rounded;
      case '11d':
      case '11n':
        return Icons.flash_on_rounded;
      case '13d':
      case '13n':
        return Icons.ac_unit_rounded;
      case '50d':
      case '50n':
        return Icons.foggy;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  static Color _getIconColor(String code) {
    switch (code) {
      case '01d':
        return const Color(0xFFFFA726);
      case '01n':
        return const Color(0xFF7E57C2);
      case '02d':
      case '02n':
        return const Color(0xFF90CAF9);
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return const Color(0xFF78909C);
      case '09d':
      case '09n':
      case '10d':
      case '10n':
        return const Color(0xFF42A5F5);
      case '11d':
      case '11n':
        return const Color(0xFFFFCA28);
      case '13d':
      case '13n':
        return const Color(0xFFE0E0E0);
      case '50d':
      case '50n':
        return const Color(0xFFB0BEC5);
      default:
        return const Color(0xFFFFA726);
    }
  }
}
