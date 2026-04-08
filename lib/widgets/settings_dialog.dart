import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/weather_service.dart';

class SettingsDialog extends StatefulWidget {
  final WeatherService weatherService;
  final VoidCallback onApiKeyChanged;

  const SettingsDialog({
    super.key,
    required this.weatherService,
    required this.onApiKeyChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _apiKeyController;
  bool _obscureKey = true;
  bool _isValidating = false;
  _ValidationResult? _validationResult;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(
      text: widget.weatherService.apiKey,
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _validateAndSave() async {
    final key = _apiKeyController.text.trim();

    if (key.isEmpty) {
      // Clear API key -> switch to demo mode
      SettingsService.clearApiKey();
      widget.weatherService.apiKey = '';
      setState(() {
        _validationResult = _ValidationResult(
          success: true,
          message: 'API key rimossa. Modalità demo attiva.',
        );
      });
      widget.onApiKeyChanged();
      return;
    }

    setState(() {
      _isValidating = true;
      _validationResult = null;
    });

    final isValid = await widget.weatherService.validateApiKey(key);

    if (!mounted) return;

    if (isValid) {
      SettingsService.saveApiKey(key);
      widget.weatherService.apiKey = key;
      setState(() {
        _isValidating = false;
        _validationResult = _ValidationResult(
          success: true,
          message: 'API key valida e salvata!',
        );
      });
      widget.onApiKeyChanged();
    } else {
      setState(() {
        _isValidating = false;
        _validationResult = _ValidationResult(
          success: false,
          message:
              'API key non valida. Verifica di aver copiato correttamente la chiave da OpenWeatherMap.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasKey = widget.weatherService.hasApiKey;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.settings_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Impostazioni',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Configura OpenWeatherMap API',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(160),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: hasKey
                      ? Colors.green.withAlpha(20)
                      : theme.colorScheme.tertiaryContainer.withAlpha(80),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasKey
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      size: 18,
                      color: hasKey
                          ? Colors.green
                          : theme.colorScheme.onTertiaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasKey
                            ? 'API key attiva: ${SettingsService.maskApiKey(widget.weatherService.apiKey)}'
                            : 'Modalità demo — inserisci una API key per dati meteo reali',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: hasKey
                              ? Colors.green.shade700
                              : theme.colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // API Key field
              Text(
                'OpenWeatherMap API Key',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _apiKeyController,
                obscureText: _obscureKey,
                decoration: InputDecoration(
                  hintText: 'Incolla la tua API key qui...',
                  prefixIcon: const Icon(Icons.key_rounded, size: 20),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _obscureKey
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _obscureKey = !_obscureKey);
                        },
                        tooltip: _obscureKey
                            ? 'Mostra API key'
                            : 'Nascondi API key',
                      ),
                      if (_apiKeyController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            _apiKeyController.clear();
                            setState(() => _validationResult = null);
                          },
                          tooltip: 'Cancella',
                        ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (_) => setState(() => _validationResult = null),
                onSubmitted: (_) => _validateAndSave(),
              ),
              const SizedBox(height: 12),

              // Validation result
              if (_validationResult != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _validationResult!.success
                        ? Colors.green.withAlpha(20)
                        : Colors.red.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _validationResult!.success
                            ? Icons.check_circle_rounded
                            : Icons.error_outline_rounded,
                        size: 18,
                        color: _validationResult!.success
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _validationResult!.message,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _validationResult!.success
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Help text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Come ottenere una API key',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _helpStep(theme, '1', 'Registrati su openweathermap.org'),
                    _helpStep(theme, '2', 'Vai su "API keys" nel tuo profilo'),
                    _helpStep(theme, '3', 'Copia la key e incollala qui sopra'),
                    const SizedBox(height: 6),
                    Text(
                      'Il piano gratuito include fino a 1.000 chiamate/giorno.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(140),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (hasKey)
                    TextButton(
                      onPressed: () {
                        _apiKeyController.clear();
                        _validateAndSave();
                      },
                      child: Text(
                        'Usa modalità demo',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annulla'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _isValidating ? null : _validateAndSave,
                    icon: _isValidating
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: Text(_isValidating ? 'Verifica...' : 'Salva'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _helpStep(ThemeData theme, String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ValidationResult {
  final bool success;
  final String message;

  _ValidationResult({required this.success, required this.message});
}
