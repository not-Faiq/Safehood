import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class AppColors {
  static const Color blue = Color(0xFF4179EA); // Fixed: Added FF for opacity
  static const Color green = Color(0xFF3ABB5D); // Fixed: Added FF for opacity
  static const Color darkBg = Color(0xFF000000); // Fixed: Added FF for opacity
  static const Color cardBg = Color(0xFF1D1F24); // Fixed: Added FF for opacity
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFFB0B0B0); // Light grey
}
void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home: SafetyHomeScreen(),
  theme: ThemeData.dark().copyWith(
    primaryColor: AppColors.blue,
    scaffoldBackgroundColor: AppColors.darkBg,
    // Use Google Fonts instead of local fonts
    textTheme: GoogleFonts.robotoTextTheme(
      ThemeData.dark().textTheme,
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.blue,
      secondary: AppColors.green,
      surface: AppColors.cardBg,
    ),
  ),
));

class SafetyHomeScreen extends StatefulWidget {
  @override
  _SafetyHomeScreenState createState() => _SafetyHomeScreenState();
}

class _SafetyHomeScreenState extends State<SafetyHomeScreen> {
  // Dark map style JSON
  final String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "elementType": "labels.icon",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "featureType": "administrative.country",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#9e9e9e"
        }
      ]
    },
    {
      "featureType": "administrative.land_parcel",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "administrative.locality",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#bdbdbd"
        }
      ]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#181818"
        }
      ]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#616161"
        }
      ]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#1b1b1b"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry.fill",
      "stylers": [
        {
          "color": "#2c2c2c"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#8a8a8a"
        }
      ]
    },
    {
      "featureType": "road.arterial",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#373737"
        }
      ]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#3c3c3c"
        }
      ]
    },
    {
      "featureType": "road.highway.controlled_access",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#4e4e4e"
        }
      ]
    },
    {
      "featureType": "road.local",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#616161"
        }
      ]
    },
    {
      "featureType": "transit",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#000000"
        }
      ]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#3d3d3d"
        }
      ]
    }
  ]
  ''';

  // Current location - initialize with a default but will be updated
  LatLng _currentPosition = LatLng(31.5204, 74.3587); // Default: Model Town, Lahore
  String _currentLocationName = "Getting location...";

  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  GoogleMapController? _mapController;

  // Flag to track if we're following user location
  bool _isFollowingUser = true;

  // Loading state
  bool _isLoadingLocation = true;

  // Location service status
  String _locationStatus = "Getting location...";

  // Stream subscription for location updates
  Stream<Position>? _positionStream;

  // Add this to track selected tab in bottom navigation
  int _selectedIndex = 0;

  // List of labels for navigation

  @override
  void initState() {
    super.initState();
    _checkLocationPermissionAndGetLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Method to handle navigation tap
  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Here you can add logic to change the content based on selected tab
    switch (index) {
      case 0: // Home
      // Show home content
        break;
      case 1: // Community
      // Show community content
        break;
      case 2: // AI
      // Show AI content
        break;
      case 3: // Profile
      // Show profile content
        break;
    }
  }

  // Updated _buildNavIcon with AppColors
  Widget _buildNavIcon(String assetName, String filledAssetName, String label, int index) {
    bool isSelected = _selectedIndex == index;

    // Use filled icon when selected, outline icon when not selected
    String iconToShow = isSelected ? filledAssetName : assetName;
    Color iconColor = isSelected ? AppColors.blue : AppColors.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavItemTapped(index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/$iconToShow',
                width: 22,
                height: 22,
                color: iconColor,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 22,
                    height: 22,
                    color: Colors.red.withOpacity(0.2),
                    child: Icon(Icons.broken_image, size: 14, color: Colors.red),
                  );
                },
              ),
              SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkLocationPermissionAndGetLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationStatus = "Checking permissions...";
    });

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoadingLocation = false;
        _locationStatus = "Location services are disabled";
      });
      return;
    }

    // Check and request permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoadingLocation = false;
          _locationStatus = "Location permissions are denied";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoadingLocation = false;
        _locationStatus = "Location permissions are permanently denied";
      });
      return;
    }

    // Permissions granted, get location
    await _getCurrentLocation();

    // Start listening to location updates
    _startLocationUpdates();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationStatus = "Getting your location...";
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
        _locationStatus = "Location updated";
      });

      await _getAddressFromLatLng();
      _addCustomLocationMarker();

      if (_mapController != null) {
        _centerOnUserLocation();
      } else {
        _isFollowingUser = true;
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _locationStatus = "Error getting location";
      });
      print("Error getting location: $e");
      _addCustomLocationMarker();
    }
  }

  void _startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    _positionStream!.listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });

        _addCustomLocationMarker();
        _getAddressFromLatLng();

        if (_isFollowingUser && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(_currentPosition),
          );
        }
      }
    });
  }

  Future<void> _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition.latitude,
        _currentPosition.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String locationName = "";

        if (place.name != null && place.name!.isNotEmpty) {
          locationName = place.name!;
        } else if (place.street != null && place.street!.isNotEmpty) {
          locationName = place.street!;
        } else if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          locationName = place.subLocality!;
        } else if (place.locality != null && place.locality!.isNotEmpty) {
          locationName = place.locality!;
        } else {
          locationName = "Unknown location";
        }

        String area = place.locality ?? place.administrativeArea ?? "";
        if (area.isNotEmpty && !locationName.contains(area)) {
          locationName = "$locationName, $area";
        }

        setState(() {
          _currentLocationName = locationName;
        });
      }
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  // Updated with AppColors
  void _addCustomLocationMarker() {
    _markers.clear();
    _circles.clear();

    // Outer circle - 300m radius
    _circles.add(
      Circle(
        circleId: CircleId('current_location_outer_circle'),
        center: _currentPosition,
        radius: 300,
        strokeWidth: 2,
        strokeColor: AppColors.blue.withOpacity(0.5),
        fillColor: AppColors.blue.withOpacity(0.15),
      ),
    );

    // Middle circle - 200m radius
    _circles.add(
      Circle(
        circleId: CircleId('current_location_middle_circle'),
        center: _currentPosition,
        radius: 150,
        strokeWidth: 2,
        strokeColor: AppColors.blue.withOpacity(0.7),
        fillColor: AppColors.blue.withOpacity(0.25),
      ),
    );

    // Inner circle - 100m radius
    _circles.add(
      Circle(
        circleId: CircleId('current_location_inner_circle'),
        center: _currentPosition,
        radius: 70,
        strokeWidth: 2,
        strokeColor: AppColors.blue.withOpacity(0.9),
        fillColor: AppColors.blue.withOpacity(0.4),
      ),
    );

    // Center dot
    _circles.add(
      Circle(
        circleId: CircleId('current_location_center_dot'),
        center: _currentPosition,
        radius: 20,
        strokeWidth: 1,
        strokeColor: AppColors.textPrimary,
        fillColor: AppColors.blue,
      ),
    );

    // Pulse circle
    _circles.add(
      Circle(
        circleId: CircleId('current_location_pulse'),
        center: _currentPosition,
        radius: 30,
        strokeWidth: 1,
        strokeColor: AppColors.blue.withOpacity(0.3),
        fillColor: AppColors.blue.withOpacity(0.1),
      ),
    );
  }

  void _centerOnUserLocation() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: 15),
        ),
      );
      setState(() {
        _isFollowingUser = true;
      });
    }
  }

  void _retryLocation() {
    _checkLocationPermissionAndGetLocation();
  }

  @override
  Widget build(BuildContext context) {
    // Lock orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle FAB press
        },
        backgroundColor: AppColors.blue,
        shape: CircleBorder(),
        child: Image.asset(
          'assets/icons/add.png',
          width: 30,
          height: 30,
          color: AppColors.textPrimary,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.add, color: AppColors.textPrimary, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        color: AppColors.cardBg,
        shape: CircularNotchedRectangle(),
        notchMargin: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavIcon('home.png', 'home_fill.png', 'Home', 0),
              _buildNavIcon('community.png', 'community_fill.png', 'Community', 1),
              SizedBox(width: 40),
              _buildNavIcon('ai.png', 'ai_fill.png', 'Safebot', 2),
              _buildNavIcon('profile.png', 'profile_fill.png', 'Profile', 3),
            ],
          ),
        ),
      ),

      body: Stack(
        children: [
          // Map Layer
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                controller.setMapStyle(_darkMapStyle);

                if (_isFollowingUser) {
                  Future.delayed(Duration(milliseconds: 100), () {
                    _centerOnUserLocation();
                  });
                }
              },
              zoomControlsEnabled: false,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              markers: _markers,
              circles: _circles,
              onCameraMoveStarted: () {
                setState(() {
                  _isFollowingUser = false;
                });
              },
              padding: EdgeInsets.only(bottom: 1, right: 1),
            ),
          ),

          // Location Name Notch - with AppColors (icon removed)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _retryLocation,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.blue.withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLoadingLocation)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
                            ),
                          ),
                        ),
                      Flexible(
                        child: Text(
                          _locationStatus.contains("Error") || _locationStatus.contains("disabled") || _locationStatus.contains("denied")
                              ? _locationStatus
                              : _currentLocationName,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (_locationStatus.contains("Error") || _locationStatus.contains("disabled") || _locationStatus.contains("denied"))
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.refresh, color: AppColors.blue, size: 16),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Custom My Location Button - with AppColors
          Positioned(
            height: 45,
            width: 45,
            top: MediaQuery.of(context).size.height * 0.5 - 90,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBg.withOpacity(0.95),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.blue.withOpacity(0.5), width: 1.5),
              ),
              child: IconButton(
                icon: Icon(
                  CupertinoIcons.location_fill, // iOS location filled icon
                  color: _isFollowingUser ? AppColors.textPrimary : AppColors.textSecondary,
                ),
                onPressed: _centerOnUserLocation,
                tooltip: 'Center on your location',
              ),
            ),
          ),

          // Alert Status - with AppColors
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5 - 90,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardBg.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.green.withOpacity(0.5), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "215 people active",
                      style: TextStyle(
                          color: AppColors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom scrollable content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.54,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.darkBg.withOpacity(0.98),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: _buildBodyForSelectedIndex(),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build body content based on selected index
  Widget _buildBodyForSelectedIndex() {
    switch (_selectedIndex) {
      case 0: // Home
        return _buildHomeContent();
      case 1: // Community
        return _buildCommunityContent();
      case 2: // AI
        return _buildAIContent();
      case 3: // Profile
        return _buildProfileContent();
      default:
        return _buildHomeContent();
    }
  }

  // Home content with AppColors
  Widget _buildHomeContent() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: AppColors.blue,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.blue,
                  width: 4, // Increased thickness of the bottom border
                ),
              ),
            ),
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [Tab(text: "Alerts"), Tab(text: "Help")],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAlertList(),
                _buildHelpList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Community content with AppColors
  Widget _buildCommunityContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 50, color: AppColors.blue),
          SizedBox(height: 16),
          Text(
            "Community Screen",
            style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
          ),
          Text(
            "Connect with neighbors",
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // AI content with AppColors
  Widget _buildAIContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 50, color: AppColors.blue),
          SizedBox(height: 16),
          Text(
            "AI Assistant",
            style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
          ),
          Text(
            "Get safety recommendations",
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // Profile content with AppColors
  Widget _buildProfileContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.cardBg,
            child: Icon(Icons.person, size: 30, color: AppColors.blue),
          ),
          SizedBox(height: 16),
          Text(
            "Profile Screen",
            style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
          ),
          Text(
            "Manage your account",
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Spacer(),
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.cardBg,
          child: Icon(Icons.person, size: 16, color: AppColors.blue),
        ),
      ],
    ),
  );

  // Alert list with AppColors
  Widget _buildAlertStatus() => Column(
    children: [
      Text("215 people active", style: TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.bold)),
    ],
  );

  Widget _buildAlertList() => ListView.builder(
    padding: EdgeInsets.only(
      top: 10,
      bottom: 170, // This adds empty scrollable space - NO BOXES VISIBLE
    ),
    itemCount: 3,
    itemBuilder: (context, index) => Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Residents got robbed!", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("B block, Garden Town", style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          Text("10:52", style: TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    ),
  );

  Widget _buildHelpList() => ListView.builder(
    padding: EdgeInsets.only(
      top: 10,
      bottom: 170, // This adds empty scrollable space - NO BOXES VISIBLE
    ),
    itemCount: 5,
    itemBuilder: (context, index) => Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Help Request #${index + 1}", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Need assistance urgently", style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text("URGENT", style: TextStyle(color: Colors.redAccent, fontSize: 10)),
          ),
        ],
      ),
    ),
  );
}