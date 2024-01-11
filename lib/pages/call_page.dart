import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:counter/pages/request_choices_page.dart';
import 'package:counter/pages/waiting_request_page.dart';
import 'package:counter/pages/video_call_page_v2.dart';
import 'package:counter/pages/chat_page.dart';
class CallPage extends StatefulWidget {
  const CallPage({super.key});
  @override
  State<CallPage> createState() => _CallPageState();
}
class _CallPageState extends State<CallPage> {
  int currentPageIndex = 0;
  dynamic clientContext;
  String? method;
  _onIndexChanged(int index, String? method) {
     setState(() {
      currentPageIndex = index;
      this.method = method;
    });
  }
  _fetchMethodContext(methodContext) {
    print("methodContext: $methodContext");
    var pageIndex = methodContext['method'] == "video" ? 2 :
    methodContext['method'] == "chat" ? 3 : 4;
    setState(() {
      currentPageIndex = pageIndex;
      clientContext = methodContext;
    });
  }
  _loungeCallback(eventMsg, Function? callback) {
    setState(() {
      currentPageIndex = 0;
      clientContext = null;
      method = null;
    });
    if (callback != null) callback();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body:
          Container(child: _getPage(currentPageIndex)),
    );
  }
  Widget _getPage(int index) {
    switch (index)  {
      case 0 :
        return RequestChoices(_onIndexChanged);
      case 1 :
        if (method == null) {
          return RequestChoices(_onIndexChanged);
        } else {
          return WaitingRequest(method!, _fetchMethodContext);
        }
      case 2 :
        if (clientContext == null) return RequestChoices(_onIndexChanged);
        return VideoCallScreen(clientContext, _loungeCallback);
      case 3 :
        return ChatScreen(clientContext, _loungeCallback);
      case 4 :
        _makePhoneCall();
        return RequestChoices(_onIndexChanged);
      default:
        return RequestChoices(_onIndexChanged);
    }
  }
  Future<void> _makePhoneCall() async {
    const phoneNumber = '1234567890'; // Replace with actual phone number
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      // Handle the error or notify the user
      print('Could not launch $phoneUri');
    }
  }
}