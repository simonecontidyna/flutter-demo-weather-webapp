# FLUTTER.DEMO.WEATHER.WEBAPP

A responsive weather dashboard built with Flutter Web, featuring interactive charts, 5-day forecast, and OpenWeatherMap API integration.

## Features

- **Current weather** — temperature, feels-like, humidity, wind, pressure, visibility, sunrise/sunset
- **Interactive charts** — 24-hour temperature line chart and humidity/wind bar chart (fl_chart)
- **5-day forecast** — expandable rows with detailed daily stats
- **Favourite cities** — quick-switch chips with add/remove
- **Unit toggle** — switch between °C and °F in real time
- **Dark / Light theme** — one-click toggle
- **Settings dialog** — configure your OpenWeatherMap API key from the UI (persisted in localStorage)
- **Demo mode** — works out of the box with mock data when no API key is set
- **OpenWeather attribution** — automatic footer when using live data (ODbL compliant)
- **Responsive layout** — two-column on desktop, single-column on mobile

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.41+ (stable channel)
- Chrome (or any Chromium-based browser) for web development
- *(Optional)* Docker for containerised deployment
- *(Optional)* A Kubernetes cluster for k8s deployment

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run in Chrome (debug)
flutter run -d chrome

# Build for production
flutter build web
```

The production build output is in `build/web/` and can be served by any static file server.

## OpenWeatherMap API Key

The app runs in **demo mode** by default with realistic mock data. To use live weather data:

1. Sign up at [openweathermap.org](https://openweathermap.org/)
2. Go to **API keys** in your profile
3. Copy your key
4. In the app, click the **gear icon** (or the **DEMO** chip) and paste your key
5. The app validates the key and persists it in the browser's localStorage

The free tier allows up to 1,000 API calls/day.

## Project Structure

```
lib/
├── main.dart                         # Entry point, theme setup
├── models/
│   └── weather_data.dart             # WeatherData, ForecastData, DailyForecast
├── screens/
│   └── dashboard_screen.dart         # Main dashboard layout and state
├── services/
│   ├── settings_service.dart         # localStorage read/write for API key
│   └── weather_service.dart          # API calls + mock data fallback
└── widgets/
    ├── current_weather_card.dart     # Main weather card (tappable → detail sheet)
    ├── daily_forecast_card.dart      # 5-day forecast (expandable rows)
    ├── favourite_cities_bar.dart     # Favourite cities chip bar
    ├── humidity_wind_chart.dart      # Bar chart (humidity + wind)
    ├── openweather_attribution.dart  # ODbL attribution footer
    ├── settings_dialog.dart          # API key configuration dialog
    ├── temperature_chart.dart        # 24h temperature line chart
    ├── weather_details_grid.dart     # Detail grid (tappable → info dialog)
    └── weather_icon.dart             # Icon mapping for weather conditions
```

## Docker

```bash
# Build
docker build -t weather-dashboard:1.0.0 .

# Run locally
docker run -p 8080:80 weather-dashboard:1.0.0
```

The image uses a multi-stage build (Flutter SDK → nginx:alpine) resulting in a ~30 MB final image.

## Kubernetes Deployment

Manifests are in the `k8s/` directory:

| File | Resource | Description |
|------|----------|-------------|
| `namespace.yaml` | Namespace | `weather-dashboard` |
| `deployment.yaml` | Deployment | 2 replicas, health probes, resource limits |
| `service.yaml` | Service | ClusterIP on port 80 |
| `ingress.yaml` | Ingress | nginx ingress class, TLS-ready |
| `hpa.yaml` | HPA | Autoscaling 2–6 pods at 70% CPU |

```bash
# Deploy
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/

# Verify
kubectl -n weather-dashboard get pods
```

Before deploying, update:
- `image:` in `deployment.yaml` with your container registry path
- `host:` in `ingress.yaml` with your domain
- Uncomment the `tls:` section if using cert-manager

## Tech Stack

- **Flutter 3.41** — Dart, Material 3
- **fl_chart** — line and bar charts
- **google_fonts** — Inter font family
- **http** — REST API client
- **intl** — date/number formatting (Italian locale)
- **nginx** — production web server
- **Docker** — multi-stage containerisation

## License

Weather data provided by [OpenWeather](https://openweathermap.org/) under the [ODbL license](https://opendatacommons.org/licenses/odbl/).
