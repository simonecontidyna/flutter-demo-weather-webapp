import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../services/settings_service.dart';
import '../services/weather_service.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/daily_forecast_card.dart';
import '../widgets/favourite_cities_bar.dart';
import '../widgets/humidity_wind_chart.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/openweather_attribution.dart';
import '../widgets/temperature_chart.dart';
import '../widgets/weather_details_grid.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const DashboardScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final WeatherService _weatherService;
  final _searchController = TextEditingController(text: 'Roma');

  WeatherData? _currentWeather;
  List<ForecastData> _forecast = [];
  List<DailyForecast> _dailyForecast = [];
  bool _isLoading = false;
  String? _error;
  bool _useCelsius = true;
  String _currentCity = 'Roma';
  List<String> _favouriteCities = ['Roma', 'Milano', 'Napoli'];

  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    final savedKey = SettingsService.loadApiKey();
    _weatherService = WeatherService(apiKey: savedKey);
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadWeather('Roma');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _toggleUnit() {
    setState(() {
      _useCelsius = !_useCelsius;
    });
  }

  double _convertTemp(double celsius) {
    return _useCelsius ? celsius : celsius * 9 / 5 + 32;
  }

  String get _unitLabel => _useCelsius ? '°C' : '°F';

  void _addFavourite(String city) {
    final normalized =
        city.trim()[0].toUpperCase() + city.trim().substring(1).toLowerCase();
    if (!_favouriteCities.contains(normalized)) {
      setState(() {
        _favouriteCities.add(normalized);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$normalized aggiunta ai preferiti'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Annulla',
            onPressed: () {
              setState(() {
                _favouriteCities.remove(normalized);
              });
            },
          ),
        ),
      );
    }
  }

  void _removeFavourite(String city) {
    setState(() {
      _favouriteCities.remove(city);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$city rimossa dai preferiti'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Annulla',
          onPressed: () {
            setState(() {
              _favouriteCities.add(city);
            });
          },
        ),
      ),
    );
  }

  void _selectCity(String city) {
    _searchController.text = city;
    _loadWeather(city);
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(
        weatherService: _weatherService,
        onApiKeyChanged: () {
          setState(() {});
          _loadWeather(_currentCity);
        },
      ),
    );
  }

  Future<void> _loadWeather(String city) async {
    if (city.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _currentCity = city.trim();
    });

    _refreshController.repeat();

    try {
      final results = await Future.wait([
        _weatherService.getCurrentWeather(city),
        _weatherService.getForecast(city),
        _weatherService.getDailyForecast(city),
      ]);

      setState(() {
        _currentWeather = results[0] as WeatherData;
        _forecast = results[1] as List<ForecastData>;
        _dailyForecast = results[2] as List<DailyForecast>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    } finally {
      _refreshController.stop();
      _refreshController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFavourite = _favouriteCities.contains(_currentCity);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, isFavourite),
            FavouriteCitiesBar(
              cities: _favouriteCities,
              selectedCity: _currentCity,
              onCitySelected: _selectCity,
              onCityRemoved: _removeFavourite,
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildError()
                      : _buildDashboard(),
            ),
            if (_weatherService.hasApiKey)
              const OpenWeatherAttribution(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isFavourite) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Icon(
            Icons.cloud_rounded,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 10),
          Text(
            'Weather Dashboard',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (!_weatherService.hasApiKey)
            Tooltip(
              message: 'Modalità demo - configura API key nelle impostazioni',
              child: ActionChip(
                label: Text(
                  'DEMO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
                avatar: Icon(
                  Icons.key_off_rounded,
                  size: 14,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                backgroundColor: theme.colorScheme.tertiaryContainer,
                side: BorderSide.none,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                onPressed: _openSettings,
              ),
            ),
          const SizedBox(width: 8),
          // Unit toggle
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('°C')),
              ButtonSegment(value: false, label: Text('°F')),
            ],
            selected: {_useCelsius},
            onSelectionChanged: (_) => _toggleUnit(),
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 240,
            height: 42,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cerca città...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  onPressed: () => _loadWeather(_searchController.text),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(
                  120,
                ),
              ),
              onSubmitted: _loadWeather,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 4),
          // Add/remove favourite
          IconButton(
            icon: Icon(
              isFavourite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isFavourite ? Colors.amber : null,
            ),
            onPressed: () {
              if (isFavourite) {
                _removeFavourite(_currentCity);
              } else {
                _addFavourite(_currentCity);
              }
            },
            tooltip: isFavourite
                ? 'Rimuovi dai preferiti'
                : 'Aggiungi ai preferiti',
          ),
          // Refresh
          RotationTransition(
            turns: _refreshController,
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => _loadWeather(_currentCity),
              tooltip: 'Aggiorna',
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.settings_rounded,
              color: _weatherService.hasApiKey
                  ? theme.colorScheme.primary
                  : null,
            ),
            onPressed: _openSettings,
            tooltip: 'Impostazioni API',
          ),
          IconButton(
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: widget.onToggleTheme,
            tooltip: widget.isDarkMode ? 'Tema chiaro' : 'Tema scuro',
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Errore nel caricamento',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? '',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () => _loadWeather(_searchController.text),
            child: const Text('Riprova'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    if (_currentWeather == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;

        if (isWide) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      CurrentWeatherCard(
                        weather: _currentWeather!,
                        convertTemp: _convertTemp,
                        unitLabel: _unitLabel,
                        onRefresh: () => _loadWeather(_currentCity),
                      ),
                      const SizedBox(height: 16),
                      WeatherDetailsGrid(weather: _currentWeather!),
                      const SizedBox(height: 16),
                      HumidityWindChart(forecast: _forecast),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      TemperatureChart(
                        forecast: _forecast,
                        convertTemp: _convertTemp,
                        unitLabel: _unitLabel,
                      ),
                      const SizedBox(height: 16),
                      DailyForecastCard(
                        days: _dailyForecast,
                        convertTemp: _convertTemp,
                        unitLabel: _unitLabel,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              CurrentWeatherCard(
                weather: _currentWeather!,
                convertTemp: _convertTemp,
                unitLabel: _unitLabel,
                onRefresh: () => _loadWeather(_currentCity),
              ),
              const SizedBox(height: 16),
              WeatherDetailsGrid(weather: _currentWeather!),
              const SizedBox(height: 16),
              TemperatureChart(
                forecast: _forecast,
                convertTemp: _convertTemp,
                unitLabel: _unitLabel,
              ),
              const SizedBox(height: 16),
              HumidityWindChart(forecast: _forecast),
              const SizedBox(height: 16),
              DailyForecastCard(
                days: _dailyForecast,
                convertTemp: _convertTemp,
                unitLabel: _unitLabel,
              ),
            ],
          ),
        );
      },
    );
  }
}
