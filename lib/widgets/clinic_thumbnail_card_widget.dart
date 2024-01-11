import "package:flutter/material.dart";
import "package:counter/utils/location_permission.dart";

class ClinicThumbnailCard extends StatelessWidget {
  const ClinicThumbnailCard({
    Key? key,
    required this.clinic,
    required this.onTap,
  }) : super(key: key);
  final Map<String, dynamic> clinic;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    final distance = showDistanceToClinic(
        clinic['location']['latitude'], clinic['location']['longitude']);
    final formatedWaitingTime =
        clinic['avgWaitingTime']?.toStringAsFixed(0) ?? '?';
    // occupancy color < 50% green, < 75% yellow, > 75% red
    // waiting time color < 30 min green, < 60 min yellow, > 60 min red
    final occupancyColor = clinic['totalOccupancy'] / clinic['maxCapacity'] < 0.5
        ? Colors.green
        : clinic['totalOccupancy'] / clinic['maxCapacity'] < 0.75
            ? Colors.yellow
            : Colors.red;
    final waitingTimeColor =
        clinic['avgWaitingTime'] < 30 ? Colors.green : clinic['avgWaitingTime'] < 60 ? Colors.yellow : Colors.red;
    return Card(
      color: Colors.white,
      child: InkWell(
        onTap: () => onTap(clinic),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12.00),
              height: 70,
              child: Row(
                children: [
                  FutureBuilder<String>(
                    future: distance,
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        var splitStrings = snapshot.data!.split(' ');
                        return Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(splitStrings[0],
                                  style: const TextStyle(fontSize: 32)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("${splitStrings[1]} away",
                                      style: const TextStyle(fontSize: 12)),
                                  const Text("distance", style: TextStyle(fontSize: 8, color: Colors.grey)),
                                ],
                              ),
                              const Icon(Icons.location_on_outlined),
                            ],
                          ),
                        );
                      } else {
                        return const Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text("?",
                                  style: TextStyle(fontSize: 32)),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("km away",
                                      style: TextStyle(fontSize: 12)),
                                  Text("distance", style: TextStyle(fontSize: 8, color: Colors.grey)),
                                ],
                              ),
                              Icon(Icons.location_on_outlined),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const Divider(
              height: 0,
              thickness: 1,
              indent: 0,
              endIndent: 0,
            ),
            Container(
              padding: const EdgeInsets.all(12.00),
              child: Expanded(
                child:
                  Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('${clinic['totalOccupancy']}',
                     style: TextStyle(
                      fontSize: 32,
                      color: occupancyColor,
                      )),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('/${clinic['maxCapacity']}'),
                        const Text('occupancy', style: TextStyle(fontSize: 8, color: Colors.grey)),
                      ],
                    ),
                    const Icon(Icons.people_alt_outlined),
                  ],
                ),
              ),
            ),
            const Divider(
              height: 0,
              thickness: 1,
              indent: 0,
              endIndent: 0,
            ),
            Container(
              padding: const EdgeInsets.all(12.00),
              child: Expanded(
                child:
                  Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('~$formatedWaitingTime', style: TextStyle(fontSize: 32, color: waitingTimeColor)),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('minutes'),
                        Text('waiting time', style: TextStyle(fontSize: 8, color: Colors.grey)),
                      ],
                    ),
                    const Icon(Icons.access_time_outlined)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
