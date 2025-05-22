import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _ctrl = Completer();
  Marker? _pickedMarker;
  String? _pickedAddress;
  String? _currentAddress;
  CameraPosition? _initialCamera;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _setupLocation();
  }

  Future<void> _setupLocation() async {
    try {
      final pos = await getPermissions();
      _currentPosition = pos;
      _initialCamera = CameraPosition(
        target: LatLng(pos.latitude, pos.longitude),
        zoom: 14,
      );

      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      final p = placemarks.first;
      _currentAddress = '${p.name}, ${p.locality}, ${p.country}';

      setState(() {});
    } catch (e) {
      _initialCamera = const CameraPosition(target: LatLng(0, 0), zoom: 2);
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<Position> getPermissions() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location service belum aktif');
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }
    }

    if (perm == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen');
    }

    return Geolocator.getCurrentPosition();
  }

  Future<void> _onTap(LatLng latlng) async {
    final placemarks = await placemarkFromCoordinates(
      latlng.latitude,
      latlng.longitude,
    );
    final p = placemarks.first;

    setState(() {
      _pickedMarker = Marker(
        markerId: const MarkerId('picked'),
        position: latlng,
        infoWindow: InfoWindow(
          title: p.name ?? 'Lokasi Dipilih',
          snippet: '${p.street}, ${p.locality}',
        ),
      );

      _pickedAddress =
          '${p.name}, ${p.street}, ${p.locality}, ${p.country}, ${p.postalCode}';
    });

    final ctrl = await _ctrl.future;
    await ctrl.animateCamera(CameraUpdate.newLatLngZoom(latlng, 16));
  }

  void _confirmSelection() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Konfirmasi Alamat'),
            content: Text(_pickedAddress ?? ''),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, _pickedAddress);
                },
                child: const Text('Pilih'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initialCamera == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Alamat')),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _initialCamera!,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController ctrl) => _ctrl.complete(ctrl),
              markers: _pickedMarker != null ? {_pickedMarker!} : {},
              onTap: _onTap,
            ),
            if (_currentAddress != null)
              Positioned(
                top: 250,
                left: 56,
                right: 56,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(_currentAddress!, textAlign: TextAlign.center),
                ),
              ),
            if (_pickedAddress != null)
              Positioned(
                bottom: 70,
                left: 16,
                right: 16,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _pickedAddress!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_pickedAddress != null)
            FloatingActionButton.extended(
              onPressed: _confirmSelection,
              label: const Text('Pilih Alamat', style: TextStyle(color: Colors.black)),
              icon: const Icon(Icons.check, color: Colors.black),
              backgroundColor: const Color.fromARGB(255, 193, 237, 249),
              heroTag: 'confirm',
            ),
          const SizedBox(height: 10),
          if (_pickedAddress != null)
            FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  _pickedMarker = null;
                  _pickedAddress = null;
                });
              },
              label: const Text('Hapus Pilihan', style: TextStyle(color: Colors.black)),
              icon: const Icon(Icons.clear, color: Colors.black,),
              backgroundColor: const Color.fromARGB(255, 245, 176, 171),
              heroTag: 'clear',
            ),
        ],
      ),
    );
  }
}
