import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_data.dart';

class WeatherDetailsGrid extends StatelessWidget {
  final WeatherData weather;

  const WeatherDetailsGrid({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final items = [
      _DetailItem(
        icon: Icons.water_drop_outlined,
        label: 'Umidità',
        value: '${weather.humidity}%',
        color: Colors.blue,
        description:
            'L\'umidità relativa indica la quantità di vapore acqueo nell\'aria. '
            'Valori sopra il 70% possono risultare afosi, sotto il 30% troppo secchi.',
        level: _humidityLevel(weather.humidity),
      ),
      _DetailItem(
        icon: Icons.air_rounded,
        label: 'Vento',
        value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
        color: Colors.teal,
        description:
            'Velocità del vento al suolo. Sotto 5 m/s è leggero, '
            'tra 5-10 m/s moderato, sopra 15 m/s forte.',
        level: _windLevel(weather.windSpeed),
      ),
      _DetailItem(
        icon: Icons.compress_rounded,
        label: 'Pressione',
        value: '${weather.pressure} hPa',
        color: Colors.deepPurple,
        description:
            'La pressione atmosferica. Valori alti (>1020 hPa) indicano bel tempo, '
            'valori bassi (<1010 hPa) possibilità di perturbazioni.',
        level: _pressureLevel(weather.pressure),
      ),
      _DetailItem(
        icon: Icons.visibility_outlined,
        label: 'Visibilità',
        value: '${(weather.visibility / 1000).toStringAsFixed(1)} km',
        color: Colors.amber.shade700,
        description:
            'La distanza massima a cui si riesce a distinguere un oggetto. '
            '10 km è ottima, sotto 1 km indica nebbia.',
        level: _visibilityLevel(weather.visibility),
      ),
      _DetailItem(
        icon: Icons.cloud_outlined,
        label: 'Nuvolosità',
        value: '${weather.clouds}%',
        color: Colors.blueGrey,
        description:
            'Percentuale del cielo coperto da nubi. '
            '0% = cielo sereno, 100% = cielo completamente coperto.',
        level: _cloudLevel(weather.clouds),
      ),
      _DetailItem(
        icon: Icons.wb_twilight_rounded,
        label: 'Alba / Tramonto',
        value:
            '${DateFormat.Hm().format(weather.sunrise)} / ${DateFormat.Hm().format(weather.sunset)}',
        color: Colors.orange,
        description:
            'Ore di luce oggi: ${_daylightHours(weather.sunrise, weather.sunset)}.',
        level: null,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children:
              items.map((item) => _buildDetailCard(context, item)).toList(),
        );
      },
    );
  }

  String _daylightHours(DateTime sunrise, DateTime sunset) {
    final diff = sunset.difference(sunrise);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return '${h}h ${m}m';
  }

  String _humidityLevel(int h) {
    if (h < 30) return 'Secco';
    if (h < 60) return 'Confortevole';
    if (h < 80) return 'Umido';
    return 'Molto umido';
  }

  String _windLevel(double w) {
    if (w < 2) return 'Calma';
    if (w < 5) return 'Leggero';
    if (w < 10) return 'Moderato';
    if (w < 15) return 'Forte';
    return 'Molto forte';
  }

  String _pressureLevel(int p) {
    if (p < 1000) return 'Molto bassa';
    if (p < 1013) return 'Bassa';
    if (p < 1020) return 'Normale';
    return 'Alta';
  }

  String _visibilityLevel(int v) {
    if (v < 1000) return 'Nebbia';
    if (v < 5000) return 'Scarsa';
    if (v < 8000) return 'Discreta';
    return 'Ottima';
  }

  String _cloudLevel(int c) {
    if (c < 10) return 'Sereno';
    if (c < 40) return 'Poco nuvoloso';
    if (c < 70) return 'Nuvoloso';
    return 'Coperto';
  }

  Widget _buildDetailCard(BuildContext context, _DetailItem item) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetailDialog(context, item),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(160),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.value,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: theme.colorScheme.onSurface.withAlpha(80),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, _DetailItem item) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 32),
          ),
          title: Text(item.label),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: item.color,
                ),
              ),
              if (item.level != null) ...[
                const SizedBox(height: 8),
                Chip(
                  label: Text(
                    item.level!,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: item.color,
                    ),
                  ),
                  backgroundColor: item.color.withAlpha(25),
                  side: BorderSide.none,
                ),
              ],
              const SizedBox(height: 16),
              Text(
                item.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(180),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Chiudi'),
            ),
          ],
        );
      },
    );
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String description;
  final String? level;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.description,
    this.level,
  });
}
