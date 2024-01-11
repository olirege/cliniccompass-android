import 'package:flutter/material.dart';
import 'package:counter/widgets/clinic_full_card_widget.dart';
class ClinicDetailPage extends StatelessWidget {
  final Map<String, dynamic> clinic;

  const ClinicDetailPage({Key? key, required this.clinic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.transparent,
       body: ClinicCard(clinic: clinic),
    );
  }
}
