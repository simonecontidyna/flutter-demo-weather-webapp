import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_data.dart';
import 'weather_icon.dart';

class DailyForecastCard extends StatefulWidget {
  final List<DailyForecast> days;
  final double Function(double) convertTemp;
  final String unitLabel;

  const DailyForecastCard({
    super.key,
    required this.days,
    required this.convertTemp,
    required this.unitLabel,
  });

  @override
  State<DailyForecastCard> createState() => _DailyForecastCardState();
}

class _DailyForecastCardState extends State<DailyForecastCard> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Previsioni 5 giorni',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_expandedIndex != null)
                  TextButton(
                    onPressed: () => setState(() => _expandedIndex = null),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text('Chiudi tutto', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(widget.days.length, (index) {
              return _buildDayRow(context, widget.days[index], index);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, DailyForecast day, int index) {
    final theme = Theme.of(context);
    final isExpanded = _expandedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isExpanded
            ? theme.colorScheme.primaryContainer.withAlpha(60)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                children: [
                  Text(
                    DateFormat('EEE d', 'it').format(day.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  WeatherIcon(iconCode: day.icon, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      day.description[0].toUpperCase() +
                          day.description.substring(1),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(160),
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (day.pop > 10)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.water_drop,
                            size: 12,
                            color: Colors.blue.shade400,
                          ),
                          Text(
                            '${day.pop}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.blue.shade400,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    '${widget.convertTemp(day.tempMin).round()}°',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(140),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildTempBar(context, day),
                  ),
                  Text(
                    '${widget.convertTemp(day.tempMax).round()}°',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurface.withAlpha(120),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded details
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedDetails(context, day),
            crossFadeState:
                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedDetails(BuildContext context, DailyForecast day) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _miniStat(
            context,
            Icons.thermostat_rounded,
            'Min',
            '${widget.convertTemp(day.tempMin).toStringAsFixed(1)}${widget.unitLabel}',
            Colors.blue,
          ),
          _miniStat(
            context,
            Icons.thermostat_rounded,
            'Max',
            '${widget.convertTemp(day.tempMax).toStringAsFixed(1)}${widget.unitLabel}',
            Colors.red,
          ),
          _miniStat(
            context,
            Icons.water_drop_outlined,
            'Umidità',
            '${day.humidity}%',
            Colors.blue.shade400,
          ),
          _miniStat(
            context,
            Icons.air_rounded,
            'Vento',
            '${day.windSpeed.toStringAsFixed(1)} m/s',
            Colors.teal,
          ),
          _miniStat(
            context,
            Icons.umbrella_rounded,
            'Pioggia',
            '${day.pop}%',
            theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _miniStat(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: theme.colorScheme.onSurface.withAlpha(140),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempBar(BuildContext context, DailyForecast day) {
    final theme = Theme.of(context);
    final globalMin =
        widget.days.map((d) => d.tempMin).reduce((a, b) => a < b ? a : b);
    final globalMax =
        widget.days.map((d) => d.tempMax).reduce((a, b) => a > b ? a : b);
    final range = globalMax - globalMin;
    if (range == 0) return const SizedBox(width: 40);

    final startFraction = (day.tempMin - globalMin) / range;
    final endFraction = (day.tempMax - globalMin) / range;

    return SizedBox(
      width: 40,
      height: 4,
      child: CustomPaint(
        painter: _TempBarPainter(
          startFraction: startFraction,
          endFraction: endFraction,
          color: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.outlineVariant.withAlpha(60),
        ),
      ),
    );
  }
}

class _TempBarPainter extends CustomPainter {
  final double startFraction;
  final double endFraction;
  final Color color;
  final Color backgroundColor;

  _TempBarPainter({
    required this.startFraction,
    required this.endFraction,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    final barPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(2),
      ),
      bgPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * startFraction,
          0,
          size.width * (endFraction - startFraction),
          size.height,
        ),
        const Radius.circular(2),
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TempBarPainter oldDelegate) {
    return oldDelegate.startFraction != startFraction ||
        oldDelegate.endFraction != endFraction;
  }
}
