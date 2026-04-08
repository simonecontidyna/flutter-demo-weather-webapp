import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_data.dart';
import 'weather_icon.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherData weather;
  final double Function(double) convertTemp;
  final String unitLabel;
  final VoidCallback onRefresh;

  const CurrentWeatherCard({
    super.key,
    required this.weather,
    required this.convertTemp,
    required this.unitLabel,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withAlpha(80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _showDetailSheet(context),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.cityName}, ${weather.country}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE d MMMM, HH:mm', 'it').format(
                          DateTime.now(),
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                  WeatherIcon(iconCode: weather.icon, size: 64),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${convertTemp(weather.temperature).round()}',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w300,
                      fontSize: 80,
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      unitLabel,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w300,
                        color: theme.colorScheme.onSurface.withAlpha(180),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather.description[0].toUpperCase() +
                              weather.description.substring(1),
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Percepita: ${convertTemp(weather.feelsLike).round()}$unitLabel',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withAlpha(160),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Min ${convertTemp(weather.tempMin).round()}° / Max ${convertTemp(weather.tempMax).round()}°',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withAlpha(160),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tocca per dettagli',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.primary.withAlpha(160),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  WeatherIcon(iconCode: weather.icon, size: 48),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.cityName}, ${weather.country}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        weather.description[0].toUpperCase() +
                            weather.description.substring(1),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _detailRow(
                context,
                Icons.thermostat_rounded,
                'Temperatura',
                '${convertTemp(weather.temperature).toStringAsFixed(1)}$unitLabel',
              ),
              _detailRow(
                context,
                Icons.device_thermostat_rounded,
                'Percepita',
                '${convertTemp(weather.feelsLike).toStringAsFixed(1)}$unitLabel',
              ),
              _detailRow(
                context,
                Icons.arrow_downward_rounded,
                'Minima',
                '${convertTemp(weather.tempMin).toStringAsFixed(1)}$unitLabel',
              ),
              _detailRow(
                context,
                Icons.arrow_upward_rounded,
                'Massima',
                '${convertTemp(weather.tempMax).toStringAsFixed(1)}$unitLabel',
              ),
              _detailRow(
                context,
                Icons.water_drop_outlined,
                'Umidità',
                '${weather.humidity}%',
              ),
              _detailRow(
                context,
                Icons.air_rounded,
                'Vento',
                '${weather.windSpeed.toStringAsFixed(1)} m/s',
              ),
              _detailRow(
                context,
                Icons.compress_rounded,
                'Pressione',
                '${weather.pressure} hPa',
              ),
              _detailRow(
                context,
                Icons.wb_sunny_outlined,
                'Alba',
                DateFormat.Hm().format(weather.sunrise),
              ),
              _detailRow(
                context,
                Icons.wb_twilight_rounded,
                'Tramonto',
                DateFormat.Hm().format(weather.sunset),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onRefresh();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Aggiorna'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(label, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
