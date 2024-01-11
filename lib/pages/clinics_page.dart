import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:counter/providers/clinics_provider.dart';
import 'package:flutter/material.dart';
import 'package:counter/widgets/loading_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:counter/pages/clinic_detail_page.dart';
import 'package:counter/widgets/clinic_thumbnail_card_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:counter/utils/location_permission.dart';
import 'package:counter/utils/date_formatting.dart';

class ClinicsPage extends ConsumerWidget {
  final Function(Map<String, dynamic>) onClinicSelected;
  const ClinicsPage({super.key, required this.onClinicSelected});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinicsAsyncValue = ref.watch(clinicsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ClinicsPageBody(clinicsAsyncValue, onClinicSelected: onClinicSelected),
    );
  }
}

class ClinicsPageBody extends ConsumerStatefulWidget {
  final AsyncValue<List<dynamic>> clinicsAsyncValue;
  final Function(Map<String, dynamic>) onClinicSelected;
  const ClinicsPageBody(this.clinicsAsyncValue, {super.key, required this.onClinicSelected});
  @override
  ClinicsPageBodyState createState() => ClinicsPageBodyState();
}

class ClinicsPageBodyState extends ConsumerState<ClinicsPageBody> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  List<dynamic> previousClinicsData = [];
  List<String> updatedClinicIds = [];
  Timer? _debounceTimer;
  Timestamp? lastUpdateTimestamp;
  CameraPosition? initialCameraPosition;
  Future<CameraPosition> _getInitialCameraPosition() async {
    final position = await getCurrentLocation();
    if (position == null) {
      return const CameraPosition(
        target: LatLng(1.3521, 103.8198),
        zoom: 11.0,
      );
    }
    return CameraPosition(
      target: LatLng(position.latitude!, position.longitude!),
      zoom: 11.0,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _addMarkers(List<dynamic> clinics) {
    markers.clear();
    for (var clinic in clinics) {
      var marker = Marker(
        markerId: MarkerId(clinic['id']),
        position: LatLng(
            clinic['location']['latitude'], clinic['location']['longitude']),
        infoWindow:
            InfoWindow(title: clinic['name'], snippet: clinic['address']),
      );
      markers.add(marker);
    }
    setState(() {});
  }

  void handleClinicUpdate(String clinicId) {
    if (!updatedClinicIds.contains(clinicId)) {
      setState(() {
        updatedClinicIds.add(clinicId);
      });

      Timer(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            updatedClinicIds.remove(clinicId);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void compareAndUpdateClinics(List<dynamic> newClinics) {
    for (var newClinic in newClinics) {
      var oldClinic = previousClinicsData.firstWhere(
        (c) => c['id'] == newClinic['id'],
        orElse: () => <String, dynamic>{
          'id': newClinic['id'],
          'avgWaitingTime': 0,
          'updatedAt': Timestamp.now(),
          'totalOccupancy': 0,
          'maxCapacity': 0,
          'location': <String, dynamic>{'latitude': 0, 'longitude': 0},
          'name': '',
          'address': '',
        },
      );

      if (oldClinic.isNotEmpty &&
          newClinic['updatedAt'] != oldClinic['updatedAt']) {
        handleClinicUpdate(newClinic['id']);
      }
    }

    previousClinicsData = newClinics;
  }

  @override
  Widget build(BuildContext context) {
    return widget.clinicsAsyncValue.when(
      data: (clinics) {
        compareAndUpdateClinics(clinics);
        _addMarkers(clinics);
        return Column(
          children: [
            const SizedBox(height: 80),
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: StreamBuilder<CameraPosition>(
                  stream:
                      Stream.periodic(const Duration(seconds: 1), (_) => null)
                          .asyncMap((_) => _getInitialCameraPosition()),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      initialCameraPosition = snapshot.data;
                    }
                    if (initialCameraPosition == null) {
                      return const LoadingWidget();
                    }
                    return GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: initialCameraPosition!,
                      markers: markers,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              flex: 3,
              child: ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: clinics.length,
                itemBuilder: (context, index) {
                  final clinic = clinics[index];
                  final isUpdated = updatedClinicIds.contains(clinic['id']);
                  return Column(
                    children: [
                      Container(
                          padding:
                              const EdgeInsets.only(left: 12.00, right: 12.00),
                          height: 42,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: const Color.fromARGB(75, 33, 33, 33),
                                ),
                                padding: const EdgeInsets.only(
                                    top: 4.0,
                                    bottom: 4.0,
                                    left: 12.0,
                                    right: 12.0),
                                child: Text(clinic['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    )),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                      timeAgoFromDateString(clinic['updatedAt']
                                          .toDate()
                                          .toString()),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      )),
                                ],
                              ),
                            ],
                          )),
                      ClinicThumbnailCard(
                        key: ValueKey('clinic-${clinic['id']}-$isUpdated'),
                        clinic: clinic,
                        onTap: (clinic) {
                          widget.onClinicSelected(clinic);
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) =>
                          //           ClinicDetailPage(clinic: clinic),
                          //     ));
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 72),
          ],
        );
      },
      loading: () => const LoadingWidget(),
      error: (error, stackTrace) => Text('Error: $error'),
    );
  }
}
