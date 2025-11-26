import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:door/services/models/pharmacy_models.dart';
import 'package:door/services/api_client.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:door/features/components/custom_textfeild.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();

  // Controllers
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postalCodeController = TextEditingController();

  // Location & Map
  static const latlng.LatLng _defaultCenter = latlng.LatLng(28.6139, 77.2090);
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _hasLocationPermission = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userData = await _apiClient.getUserData();
    if (userData != null) {
      setState(() {
        fullNameController.text = userData['userName'] ?? '';
        phoneController.text = userData['phoneNumber'] ?? '';
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.status;
    setState(() {
      _hasLocationPermission = status.isGranted;
    });
    if (_hasLocationPermission) {
      _getCurrentLocation();
    }
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      setState(() {
        _hasLocationPermission = true;
        _locationError = null;
      });
      _getCurrentLocation();
    } else if (status.isDenied) {
      setState(() {
        _locationError = 'Location permission denied. Please enable it in settings.';
      });
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _locationError = 'Location permission permanently denied. Please enable it in app settings.';
      });
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Please enable location permission in app settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Location services are disabled. Please enable them.';
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      // Reverse geocode to get address
      await _reverseGeocode(position.latitude, position.longitude);

      // Update map center
      if (mounted) {
        _mapController.move(
          latlng.LatLng(position.latitude, position.longitude),
          15,
        );
      }
    } catch (e) {
      setState(() {
        _locationError = 'Failed to get location: ${e.toString()}';
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _reverseGeocode(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) return;
      final place = placemarks.first;
      setState(() {
        final street = place.street ?? place.thoroughfare ?? '';
        final subThoroughfare = place.subThoroughfare ?? '';
        final composedStreet = '$street ${subThoroughfare.trim()}'.trim();

        addressLine1Controller.text = composedStreet.isNotEmpty
            ? composedStreet
            : (place.name ?? addressLine1Controller.text);

        addressLine2Controller.text =
            place.subLocality ?? place.locality ?? addressLine2Controller.text;
        cityController.text =
            place.locality ?? place.subAdministrativeArea ?? cityController.text;
        stateController.text =
            place.administrativeArea ?? stateController.text;
        postalCodeController.text =
            place.postalCode ?? postalCodeController.text;
      });
    } catch (e) {
      // Silently fail - user can still enter address manually
      debugPrint('Reverse geocoding error: $e');
    }
  }

  void _submitAddress() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(
        context,
        ShippingAddress(
          fullName: fullNameController.text,
          phone: phoneController.text,
          addressLine1: addressLine1Controller.text,
          addressLine2: addressLine2Controller.text.isEmpty
              ? null
              : addressLine2Controller.text,
          city: cityController.text,
          state: stateController.text,
          postalCode: postalCodeController.text,
          country: 'India',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Shipping Address',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Permission Section
              if (!_hasLocationPermission)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.softPurple,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: AppColors.primary, size: 24),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Use Current Location',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Allow location access to automatically fill your address',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _requestLocationPermission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Enable Location',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  height: 220,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.greySecondry),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _currentPosition != null
                                ? latlng.LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude,
                                  )
                                : _defaultCenter,
                            initialZoom: 15,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.door.pharmacy',
                            ),
                            if (_currentPosition != null)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    width: 40,
                                    height: 40,
                                    point: latlng.LatLng(
                                      _currentPosition!.latitude,
                                      _currentPosition!.longitude,
                                    ),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: AppColors.primary,
                                      size: 36,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        if (_isLoadingLocation)
                          Container(
                            color: Colors.white.withOpacity(0.85),
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: FloatingActionButton.small(
                            heroTag: 'locate_btn',
                            onPressed: _getCurrentLocation,
                            backgroundColor: AppColors.primary,
                            child: const Icon(Icons.my_location, color: Colors.white),
                          ),
                        ),
                        if (_currentPosition != null)
                          Positioned(
                            left: 10,
                            bottom: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Text(
                                'Lat: ${_currentPosition!.latitude.toStringAsFixed(5)}\n'
                                'Lng: ${_currentPosition!.longitude.toStringAsFixed(5)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              if (_locationError != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _locationError!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Address Form Fields
              const Text(
                'Address Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Full Name',
                controller: fullNameController,
                prefixIcon: const Icon(Icons.person_outline),
                validator: (v) => v?.isEmpty ?? true ? 'Full name is required' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Phone Number',
                controller: phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Phone number is required';
                  if (v!.length < 10) return 'Enter a valid phone number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Address Line 1',
                controller: addressLine1Controller,
                prefixIcon: const Icon(Icons.home_outlined),
                validator: (v) => v?.isEmpty ?? true ? 'Address is required' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Address Line 2 (Optional)',
                controller: addressLine2Controller,
                prefixIcon: const Icon(Icons.business_outlined),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'City',
                      controller: cityController,
                      prefixIcon: const Icon(Icons.location_city_outlined),
                      validator: (v) => v?.isEmpty ?? true ? 'City is required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'State',
                      controller: stateController,
                      prefixIcon: const Icon(Icons.map_outlined),
                      validator: (v) => v?.isEmpty ?? true ? 'State is required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Postal Code',
                controller: postalCodeController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.pin_outlined),
                validator: (v) => v?.isEmpty ?? true ? 'Postal code is required' : null,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

