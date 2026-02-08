import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/location_provider.dart';

class LocationDemoScreen extends StatefulWidget {
  const LocationDemoScreen({super.key});

  @override
  State<LocationDemoScreen> createState() => _LocationDemoScreenState();
}

class _LocationDemoScreenState extends State<LocationDemoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Demo'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status cards
                _buildStatusCard(
                  'Location Services',
                  locationProvider.isLocationEnabled ? 'Enabled' : 'Disabled',
                  locationProvider.isLocationEnabled
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(height: 12),

                _buildStatusCard(
                  'Permission Status',
                  locationProvider.isPermissionGranted
                      ? 'Granted'
                      : 'Not Granted',
                  locationProvider.isPermissionGranted
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(height: 20),

                // Current location display
                if (locationProvider.currentPosition != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Location',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Latitude: ${locationProvider.currentPosition!.latitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Longitude: ${locationProvider.currentPosition!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Accuracy: ${locationProvider.currentPosition!.accuracy.toStringAsFixed(2)} meters',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Timestamp: ${locationProvider.currentPosition!.timestamp}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Error message
                if (locationProvider.errorMessage != null)
                  Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Error',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            locationProvider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: locationProvider.clearError,
                            child: const Text('Clear Error'),
                          ),
                        ],
                      ),
                    ),
                  ),

                const Spacer(),

                // Action buttons
                if (locationProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: locationProvider.checkLocationService,
                          icon: const Icon(Icons.settings),
                          label: const Text('Check Location Services'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: locationProvider.checkAndRequestPermission,
                          icon: const Icon(Icons.security),
                          label: const Text('Check/Request Permission'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: locationProvider.getCurrentLocation,
                          icon: const Icon(Icons.my_location),
                          label: const Text('Get Current Location'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(String title, String status, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
