import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:counter/widgets/loading_widget.dart';
import 'package:counter/providers/clinics_provider.dart';
import 'package:counter/widgets/department_card.dart';
import 'package:counter/utils/date_formatting.dart';

class DepartmentsList extends ConsumerWidget {
  final String clinicId;

  const DepartmentsList({Key? key, required this.clinicId}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<dynamic>> departments =
        ref.watch(departmentsProvider(clinicId));

    return departments.when(
      data: (departments) {
        // Build a list view or other UI with the department data
        return ListView.builder(
          padding: const EdgeInsets.all(0),
          itemCount: departments.length,
          itemBuilder: (context, index) {
            var department = departments[index];
            return Column(
              children: [
                Container(
                    padding: const EdgeInsets.only(right: 12.00, left: 12.00),
                    height: 56,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: const Color.fromARGB(75, 33, 33, 33),
                          ),
                          padding: const EdgeInsets.only(
                              top: 4.0, bottom: 4.0, left: 12.0, right: 12.0),
                          child: Text(department['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              )),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.white, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                    timeAgoFromDateString(
                                        department['updatedAt']
                                            .toDate()
                                            .toString()),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    )),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(
                                  width: 8.0,
                                ),
                                const Icon(
                                  Icons.phone,
                                  size: 15.0,
                                  color: Colors.white,
                                ),
                                Text(department['phonenumber'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )),
                DepartmentCard(
                  key: ValueKey(department['id']),
                  department: department,
                ),
              ],
            );
          },
        );
      },
      loading: () => const LoadingWidget(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
