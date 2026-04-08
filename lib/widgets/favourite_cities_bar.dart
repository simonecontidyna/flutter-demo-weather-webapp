import 'package:flutter/material.dart';

class FavouriteCitiesBar extends StatelessWidget {
  final List<String> cities;
  final String selectedCity;
  final ValueChanged<String> onCitySelected;
  final ValueChanged<String> onCityRemoved;

  const FavouriteCitiesBar({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.onCitySelected,
    required this.onCityRemoved,
  });

  @override
  Widget build(BuildContext context) {
    if (cities.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: cities.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final city = cities[index];
          final isSelected = city == selectedCity;
          return FilterChip(
            label: Text(city),
            selected: isSelected,
            onSelected: (_) => onCitySelected(city),
            onDeleted: () => onCityRemoved(city),
            deleteIcon: Icon(
              Icons.close,
              size: 16,
              color: isSelected
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onSurface.withAlpha(160),
            ),
            avatar: Icon(
              Icons.location_on_outlined,
              size: 16,
              color: isSelected
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onSurface.withAlpha(160),
            ),
            showCheckmark: false,
            selectedColor: theme.colorScheme.secondaryContainer,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}
