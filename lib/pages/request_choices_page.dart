import "package:flutter/material.dart";
class RequestChoices extends StatefulWidget {
  const RequestChoices(this.onIndexChanged, {super.key});
  final Function onIndexChanged;
  @override
  _RequestChoicesState createState() => _RequestChoicesState(onIndexChanged);
}

class _RequestChoicesState extends State<RequestChoices> {
  _RequestChoicesState(this.onIndexChanged);
  final Function onIndexChanged;
  _onClick(method) {
    return () {
      onIndexChanged(1, method);
    };
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'How would you like to connect?',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 72),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: _onClick('video'),
                label: const Text('Video Call'),
                icon: const Icon(Icons.video_call),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 72),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: _onClick('chat'),
                label: const Text('Chat'),
                icon: const Icon(Icons.chat_bubble),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 72),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: _onClick('phone'),
                label: const Text('Phone Call'),
                icon: const Icon(Icons.phone),
              ),
            ],
          ),
        ));
  }
}
