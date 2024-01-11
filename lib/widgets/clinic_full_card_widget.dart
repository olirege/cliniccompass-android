import "package:flutter/material.dart";
import "package:counter/utils/location_permission.dart";
import 'package:counter/widgets/department_list_widget.dart';
import 'package:counter/utils/date_formatting.dart';
import 'package:location/location.dart';
import 'package:circular_chart_flutter/circular_chart_flutter.dart';

class ClinicCard extends StatelessWidget {
  final Map<String, dynamic> clinic;
  const ClinicCard({
    Key? key,
    required this.clinic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final distance = showDistanceToClinic(
        clinic['location']['latitude'], clinic['location']['longitude']);
    final formatedWaitingTime =
        clinic['avgWaitingTime']?.toStringAsFixed(0) ?? '?';
    // Calculate the occupancy percentage
    double occupancy = clinic['totalOccupancy'].toDouble();
    double maxCapacity = clinic['maxCapacity'].toDouble();
    double occupancyPercentage = (occupancy / maxCapacity) * 100;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 64.0),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: const Color.fromARGB(75, 33, 33, 33),
                ),
                padding: const EdgeInsets.only(
                    top: 4.0, bottom: 4.0, left: 12.0, right: 12.0),
                child: Text(clinic['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    )),
              ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedCircularChart(
                      size: const Size(150.0, 150.0),
                      initialChartData: <CircularStackEntry>[
                        CircularStackEntry(
                          <CircularSegmentEntry>[
                            CircularSegmentEntry(
                              occupancyPercentage,
                              Colors.blue,
                              rankKey: 'Occupancy',
                            ),
                            CircularSegmentEntry(
                              100 - occupancyPercentage,
                              Colors.white,
                              rankKey: 'Remaining Capacity',
                            ),
                          ],
                          rankKey: 'Occupancy Chart',
                        ),
                      ],
                      chartType: CircularChartType.Radial,
                      percentageValues: true,
                    ),
                    _buildChartLabel(occupancy, maxCapacity),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: const Color.fromARGB(75, 33, 33, 33),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<String>(
                                future: distance,
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  if (snapshot.hasData) {
                                    return Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 15.0,
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        Text('${snapshot.data!} away', style:const TextStyle(color:Colors.white)),
                                      ],
                                    );
                                  } else {
                                    return const Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 15.0,
                                        ),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Text('? km away', style: TextStyle(color:Colors.white)),
                                      ],
                                    );
                                  }
                                },
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    size: 15.0,
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  Text('${clinic['phonenumber']}', style: const TextStyle(color:Colors.white)),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Text(timeAgoFromDateString(
                                      clinic['updatedAt'].toDate().toString()), style: const TextStyle(color:Colors.white)),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  const Icon(
                                    Icons.update,
                                    size: 15.0,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('~$formatedWaitingTime mins', style: const TextStyle(color:Colors.white)),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  const Icon(
                                    Icons.access_time,
                                    size: 15.0,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    const SizedBox(height: 16,),
                    TextButton.icon(
                      icon: const Icon(
                        Icons.directions,
                        size: 20.0,
                        color:Colors.blueAccent,
                      ),
                      onPressed: () async {
                        LocationData? currentLocation = await getCurrentLocation();
                        if (currentLocation != null) {
                          double startLat = currentLocation.latitude!;
                          double startLng = currentLocation.longitude!;
                          double endLat = clinic['location']
                              .latitude; // Assuming clinic['location'] has latitude
                          double endLng = clinic['location']
                              .longitude; // Assuming clinic['location'] has longitude
                          await openMapWithDirections(startLat, startLng, endLat, endLng);
                        }
                      },
                      label: const Text('Get Directions', style:TextStyle(color:Colors.blueAccent,)),
                    ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: DepartmentsList(clinicId: clinic['id']),
          ),
        ],
      ),
    );
  }
  Widget _buildChartLabel(double occupancy, double maxCapacity) {
    final occupancyColor = occupancy / maxCapacity < 0.5
        ? Colors.green
        : occupancy / maxCapacity < 0.75
            ? Colors.yellow
            : Colors.red;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.people, color: Colors.white, size: 24.0),
        Text(
          occupancy.toStringAsFixed(0),
          style: TextStyle(
            color: occupancyColor,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        Text(
          '/${maxCapacity.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        )
      ],
    );
  }
}
