import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:counter/widgets/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class WaitingRequest extends StatefulWidget {
  const WaitingRequest(this.method, this.fetchMethodContext, {super.key});
  final String method;
  final Function fetchMethodContext;
  @override
  _WaitingRequestState createState() => _WaitingRequestState(method, fetchMethodContext);
}

class _WaitingRequestState extends State<WaitingRequest> {
  _WaitingRequestState(this.method, this.fetchMethodContext);
  final String method;
  final Function fetchMethodContext;
  String requestId = '';
  StreamSubscription? requestSubscription;
  @override
  void initState() {
    super.initState();
    requestPipe();
  }

  requestPipe() async {
    print("Sending join request");
    var user = FirebaseAuth.instance.currentUser;
    var uid = user?.uid ?? '0';
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable("request_to_join");
    final request = await callable.call(<String, dynamic>{
      'type': method,
      'uid': uid,
    });
    if (request.data['status'] == 200) {
      requestId = request.data['id'];
      print("request id: ${requestId}");
      requestSubscription =
          listenForRequestApproval(requestId, (clientContext) {
          fetchMethodContext(clientContext);
      });
    } else {
      throw Exception('Failed to send request');
    }
  }

  listenForRequestApproval(String requestId, Function callback) {
    return FirebaseFirestore.instance
        .collection('joinRequests')
        .doc(requestId)
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) {
      print("snapshot: ${snapshot.data()}");
      if (snapshot.exists && snapshot.data()?['status'] == 'accepted') {
        print("Request approved");
        print("snapshot: ${snapshot.data()}");
        callback(
          {
            ...snapshot.data()?['context'],
            "method":method,
            "requestId":requestId,
          },
        ); // Handle the approval
      }
    });
  }
  @override
  void dispose() {
    super.dispose();
    requestSubscription?.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Waiting for response',
                style: TextStyle(fontSize: 20),
              ),
              LoadingWidget(),
            ],
          ),
        ));
  }
}
