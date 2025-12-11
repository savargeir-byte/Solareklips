import 'package:flutter/material.dart';

import '../main.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final List<ObservationLocation> _favorites = [
    ObservationLocation(
      name: 'Reykjavík',
      latitude: 64.1466,
      longitude: -21.9426,
      country: 'Iceland',
    ),
    ObservationLocation(
      name: 'Akureyri',
      latitude: 65.6835,
      longitude: -18.1214,
      country: 'Iceland',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kDarkGray,
        title: const Text(
          'Favorite Locations',
          style: TextStyle(
              color: kGold, fontSize: 20, fontWeight: FontWeight.w400),
        ),
        iconTheme: const IconThemeData(color: kGold),
      ),
      body: _favorites.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final location = _favorites[index];
                return _buildLocationCard(location, index);
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kGold,
        foregroundColor: kBlack,
        onPressed: _showAddLocationDialog,
        child: const Icon(Icons.add_location),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: kGoldDim.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No saved locations',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: kGoldDim,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your observation points',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(ObservationLocation location, int index) {
    return Card(
      color: kDarkGray,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: kGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.location_on, color: kGold),
        ),
        title: Text(
          location.name,
          style: const TextStyle(
            color: kGold,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              location.country,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Lat: ${location.latitude.toStringAsFixed(4)}°, '
              'Lon: ${location.longitude.toStringAsFixed(4)}°',
              style: const TextStyle(color: kGoldDim, fontSize: 12),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: kGoldDim),
          onPressed: () => _removeLocation(index),
        ),
        onTap: () => _showLocationDetails(location),
      ),
    );
  }

  void _showAddLocationDialog() {
    final nameController = TextEditingController();
    final latController = TextEditingController();
    final lonController = TextEditingController();
    final countryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kDarkGray,
        title: const Text('Add Location', style: TextStyle(color: kGold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Location Name',
                  labelStyle: TextStyle(color: kGoldDim),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kGoldDim),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kGold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: countryController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Country',
                  labelStyle: TextStyle(color: kGoldDim),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kGoldDim),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kGold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: latController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Latitude',
                  hintText: '64.1466',
                  hintStyle: TextStyle(color: kGoldDim.withOpacity(0.3)),
                  labelStyle: const TextStyle(color: kGoldDim),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: kGoldDim),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: kGold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lonController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Longitude',
                  hintText: '-21.9426',
                  hintStyle: TextStyle(color: kGoldDim.withOpacity(0.3)),
                  labelStyle: const TextStyle(color: kGoldDim),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: kGoldDim),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: kGold),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: kGoldDim)),
          ),
          ElevatedButton(
            onPressed: () {
              final lat = double.tryParse(latController.text);
              final lon = double.tryParse(lonController.text);

              if (nameController.text.isNotEmpty &&
                  lat != null &&
                  lon != null &&
                  countryController.text.isNotEmpty) {
                setState(() {
                  _favorites.add(ObservationLocation(
                    name: nameController.text,
                    latitude: lat,
                    longitude: lon,
                    country: countryController.text,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeLocation(int index) {
    setState(() {
      _favorites.removeAt(index);
    });
  }

  void _showLocationDetails(ObservationLocation location) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kDarkGray,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: kGold, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: const TextStyle(
                          color: kGold,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        location.country,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow(
                'Latitude', '${location.latitude.toStringAsFixed(6)}°'),
            const SizedBox(height: 12),
            _buildInfoRow(
                'Longitude', '${location.longitude.toStringAsFixed(6)}°'),
            const SizedBox(height: 24),
            const Text(
              'Next Eclipse Visibility',
              style: TextStyle(
                color: kGoldDim,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kBlack.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kGold.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.wb_sunny, color: kGold, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Iceland 2026 Total',
                          style: TextStyle(
                            color: kGold,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'April 12, 2026 • 15:00 UTC',
                          style: TextStyle(
                            color: kGoldDim,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: kGold,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ObservationLocation {
  final String name;
  final double latitude;
  final double longitude;
  final String country;

  ObservationLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
  });
}
