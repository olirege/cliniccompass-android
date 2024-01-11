import 'package:flutter/material.dart';
class DepartmentCard extends StatelessWidget {
  final dynamic department;
  const DepartmentCard({required Key key, this.department}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final occupancyColor = department['occupancy'] / department['capacity'] < 0.5
        ? Colors.green
        : department['occupancy'] / department['capacity'] < 0.75
            ? Colors.yellow
            : Colors.red;
    final waitingTimeColor =
        department['waitingTime'] < 30 ? Colors.green : department['waitingTime'] < 60 ? Colors.yellow : Colors.red;
    return Card(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        child:
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Text('~${department['waitingTime']?.toStringAsFixed(0) ?? '?'}', style: TextStyle(fontSize: 32, color: waitingTimeColor),),
                  const Text('min', style: TextStyle(fontSize: 16, color: Colors.grey),),
                  const SizedBox(
                    width: 5.0,
                  ),
                  const Icon(
                    Icons.access_time,
                    size: 15,
                  ),
                ],
              ),
              const Divider(
                height: 10,
                thickness: 1,
                indent: 20,
                endIndent: 20,
                color: Colors.grey,
              ),
              Row(
                children: [
                  Text('~${department['occupancy']}' , style: TextStyle(fontSize: 32, color: occupancyColor),),
                  Text('/${department['capacity']}', style: const TextStyle(fontSize: 16, color: Colors.grey),),
                  const SizedBox(
                    width: 5.0,
                  ),
                  const Icon(
                    Icons.people,
                    size: 15,
                  ),
                ],
              ),
            ],
        ),
      ),
    );
  }
}
