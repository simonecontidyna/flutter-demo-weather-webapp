# flutter-demo-weather-webapp

A responsive weather dashboard built with Flutter Web, featuring interactive charts, 5-day forecast, and OpenWeatherMap API integration.

## Features

- **Current weather** — temperature, feels-like, humidity, wind, pressure, visibility, sunrise/sunset
- **Interactive charts** — 24-hour temperature line chart and humidity/wind bar chart (fl_chart)
- **5-day forecast** — expandable rows with detailed daily stats
- **Favourite cities** — quick-switch chips with add/remove
- **Unit toggle** — switch between Celsius and Fahrenheit in real time
- **Dark / Light theme** — one-click toggle
- **Settings dialog** — configure your OpenWeatherMap API key from the UI (persisted in localStorage)
- **Demo mode** — works out of the box with mock data when no API key is set
- **OpenWeather attribution** — automatic footer when using live data (ODbL compliant)
- **Responsive layout** — two-column on desktop, single-column on mobile

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.41+ (stable channel)
- Chrome (or any Chromium-based browser) for web development
- *(Optional)* [Docker](https://docs.docker.com/get-docker/) for containerised deployment
- *(Optional)* A Kubernetes cluster with nginx Ingress Controller and cert-manager

## Quick Start (Flutter)

```bash
# Install dependencies
flutter pub get

# Run in Chrome (debug)
flutter run -d chrome

# Build for production
flutter build web
```

The production build output is in `build/web/` and can be served by any static file server.

## Run with Docker

The easiest way to run the app locally without installing Flutter:

```bash
# Build the image
docker build -t weather-dashboard .

# Run on port 8080
docker run -d -p 8080:80 --name weather-dashboard weather-dashboard
```

Then open [http://localhost:8080](http://localhost:8080) in your browser.

To stop and remove:

```bash
docker stop weather-dashboard && docker rm weather-dashboard
```

### Cross-platform build

If your machine architecture differs from your target (e.g. building on Apple Silicon for an x86 server), enable QEMU emulation and specify the platform:

```bash
# Enable QEMU (one-time setup)
docker run --privileged --rm tonistiigi/binfmt --install amd64

# Build for x86
docker buildx build --platform linux/amd64 -t your-registry/weather-dashboard:latest --push .
```

The image uses a multi-stage build (Flutter SDK -> nginx:alpine) resulting in a ~30 MB final image.

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
    ├── current_weather_card.dart     # Main weather card (tappable -> detail sheet)
    ├── daily_forecast_card.dart      # 5-day forecast (expandable rows)
    ├── favourite_cities_bar.dart     # Favourite cities chip bar
    ├── humidity_wind_chart.dart      # Bar chart (humidity + wind)
    ├── openweather_attribution.dart  # ODbL attribution footer
    ├── settings_dialog.dart          # API key configuration dialog
    ├── temperature_chart.dart        # 24h temperature line chart
    ├── weather_details_grid.dart     # Detail grid (tappable -> info dialog)
    └── weather_icon.dart             # Icon mapping for weather conditions
```

## Kubernetes Deployment

A single-file manifest is provided in `k8s/deploy.yaml` containing Namespace, Deployment, Service, Ingress (with TLS), and HPA.

### Prerequisites

- **nginx Ingress Controller** installed on the cluster
- **cert-manager** with a ClusterIssuer configured

> **Important:** Your ClusterIssuer solver must use `ingressClassName` (not the deprecated `class` field), otherwise the nginx admission webhook will reject ACME challenge paths with `pathType: Exact`. Example:
>
> ```yaml
> solvers:
>   - http01:
>       ingress:
>         ingressClassName: nginx   # not "class: nginx"
> ```

### Deploy

1. Edit `k8s/deploy.yaml` and replace the placeholders:
   - `<your-registry/weather-dashboard:tag>` — your container image
   - `<your-domain.com>` — your domain
   - `<your-cluster-issuer>` — your cert-manager ClusterIssuer name

2. Apply:

```bash
kubectl apply -f k8s/deploy.yaml
```

3. Verify:

```bash
kubectl -n weather-dashboard get pods
kubectl -n weather-dashboard get certificate
kubectl -n weather-dashboard get ingress
```

4. Point your DNS (A record) to the Ingress Controller's external IP:

```bash
kubectl get svc -n ingress-nginx -o wide
```

cert-manager will automatically issue a Let's Encrypt TLS certificate once the DNS is propagated.

### Troubleshooting TLS

If the certificate stays in a `False` READY state:

```bash
# Check certificate status
kubectl describe certificate weather-dashboard-tls -n weather-dashboard

# Check ACME challenge
kubectl get challenges -n weather-dashboard
kubectl describe challenge -n weather-dashboard

# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager --tail=50
```

Common issues:
- **webhook rejects challenge path** — update your ClusterIssuer to use `ingressClassName` instead of `class`
- **challenge returns HTML instead of token** — ensure the solver pod is running and the Ingress routes `.well-known/acme-challenge` to it
- **DNS not propagated** — Let's Encrypt must reach your domain on port 80; verify with `dig your-domain.com`

## Tech Stack

- **Flutter 3.41** — Dart, Material 3
- **fl_chart** — line and bar charts
- **google_fonts** — Inter font family
- **http** — REST API client
- **intl** — date/number formatting (Italian locale)
- **nginx** — production web server
- **Docker** — multi-stage containerisation
- **Kubernetes** — orchestration with nginx Ingress and cert-manager TLS

## License

This project is licensed under the [MIT License](LICENSE).

Weather data provided by [OpenWeather](https://openweathermap.org/) under the [ODbL license](https://opendatacommons.org/licenses/odbl/).
