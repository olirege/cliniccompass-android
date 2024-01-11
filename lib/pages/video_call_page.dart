import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart' as RTC_Engine;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:counter/widgets/loading_widget.dart';
import 'dart:async';
class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: VideoCallScreenBody(),
    );
  }
}

class VideoCallScreenBody extends StatefulWidget {
  const VideoCallScreenBody({super.key});

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}
const logLevel = RTC_Engine.LogLevel.logLevelWarn;
const RTC_Engine.LogConfig logConfig = RTC_Engine.LogConfig(level: logLevel);

class _VideoCallScreenState extends State<VideoCallScreenBody> {
  String? channelName; // channel name for the current session
  String? appId; // appId for the current session
  String? token; // token for the current session
  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  late RTC_Engine.RtcEngine agoraEngine; // Agora engine instance
  int volume = 50; // Current speaker volume
  bool muted = false; // Current microphone state
  bool isCameraToggled = true; // Current camera state
  final Completer<void> _requestApprovalCompleter = Completer<void>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body:
          Column(
        children: [
          Expanded(flex: 5, child: _remoteVideo()),
          Expanded(flex: 2, child: _buildControls()),
        ],
      ),
    );
  }
  Widget _localPreview() {
    if (_isJoined) {
      return RTC_Engine.AgoraVideoView(
        controller: RTC_Engine.VideoViewController(
          rtcEngine: agoraEngine,
          canvas: const RTC_Engine.VideoCanvas(uid: 0),
        ),
      );
    } else {
      return const Text(
        'Join a channel',
        textAlign: TextAlign.center,
      );
    }
  }

  // Display remote user's video
  Widget _remoteVideo() {
  if (_isJoined && _remoteUid != null) {
    return Stack(
      children: <Widget>[
        _fullRemoteVideo(),
        if (isCameraToggled)
          Positioned(
            right: 10,
            top: 10,
            child: SizedBox(
              width: 100,
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _localPreview(),
              ),
            ),
          ),
      ],
    );
  } else {
    // Placeholder when not joined
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Color.fromARGB(65, 0, 0, 0),
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          color: Colors.grey,
          size: 75.0,
        ),
      ),
    );
  }
}

  Widget _fullRemoteVideo() {
    if (_remoteUid != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        child: RTC_Engine.AgoraVideoView(
          controller: RTC_Engine.VideoViewController.remote(
            rtcEngine: agoraEngine,
            canvas: RTC_Engine.VideoCanvas(uid: _remoteUid),
            connection: RTC_Engine.RtcConnection(channelId: channelName),
          ),
        ),
      );
    } else {
      String msg = '';
      if (_isJoined) msg = 'Waiting for a remote user to join';
      return Text(
        msg,
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _buildControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              color: muted ? Colors.redAccent : Colors.white,
              icon: muted ? const Icon(Icons.mic_off) : const Icon(Icons.mic),
              onPressed: () => {onMuteChecked(!muted)},
            ),
            IconButton(
              icon: const Icon(Icons.volume_down, color: Colors.white),
              color: Colors.white,
              onPressed: onVolumeIconPressed,
            ),
            IconButton(
              icon: !isCameraToggled
                  ? const Icon(Icons.videocam_off)
                  : const Icon(Icons.videocam),
              color: Colors.white,
              onPressed: () => {onCameraChecked(!isCameraToggled)},
            )
          ],
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextButton(
                  onPressed: _isJoined ? null : () => {join()},
                  child: const Text("Join"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButton(
                  onPressed: _isJoined ? () => {leave()} : null,
                  child: const Text("Leave"),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 69),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    initVideoCall();
  }
  Future<void> initVideoCall() async {
    await [Permission.microphone, Permission.camera].request();
    String fetchedAppId = await fetchAppId(); // Fetch the appId
    setState(() {
      appId = fetchedAppId; // Set the appId
    });
    await setupVideoSDKEngine(fetchedAppId); // Initialize Agora engine with the fetched appId
  }
  Future<void> setupVideoSDKEngine(String appId) async {
    agoraEngine = RTC_Engine.createAgoraRtcEngine();
    await agoraEngine.initialize(RTC_Engine.RtcEngineContext(appId: appId, logConfig: logConfig));
    await agoraEngine.enableVideo();
    agoraEngine.registerEventHandler(
      RTC_Engine.RtcEngineEventHandler(
        onJoinChannelSuccess: (RTC_Engine.RtcConnection connection, int elapsed) {
          showMessage(
              "Local user uid:${connection.localUid} joined the channel");
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RTC_Engine.RtcConnection connection, int remoteUid, int elapsed) {
          showMessage("Remote user uid:$remoteUid joined the channel");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RTC_Engine.RtcConnection connection, int remoteUid,
           RTC_Engine. UserOfflineReasonType reason) {
          showMessage("Remote user uid:$remoteUid left the channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );
  }
  void join() async {
    try {
      String requestId = await sendJoinRequest();
      print("requestId: $requestId");
      dynamic subscription;
      subscription = listenForRequestApproval(requestId, (token, channelName) {
        onRequestApproved(token, channelName);
        subscription.cancel(); // Cancel the subscription
        if (mounted) {
          print("requestApprovalCompleted closing dialog");
          Navigator.of(context).pop(); // Close the dialog if still mounted
        }
      });
      bool? isDialogDismissed = await showWaitingDialog();
      await _requestApprovalCompleter.future;  
      print("isDialogDismissed: $isDialogDismissed");
      if (isDialogDismissed == null) {
        print("Dialog dismissed");
        await cancelJoinRequest(requestId);
        subscription.cancel();
        _requestApprovalCompleter.complete();
      }
    } catch (e) {
      print(e);
    }
  }
  void onRequestApproved(String token, String channelName) {
    setState(() {
      this.token = token;
      this.channelName = channelName;
    });
    _requestApprovalCompleter.complete();
    _joinChannel(token, channelName);
  }
  Future<String> fetchAppId() async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable("get_agora_app_id");
    final request = await callable.call();
    if(request.data['status'] == 200){
      print("request agoraAppId: ${request.data['agoraAppId'] }");
      return request.data['agoraAppId'];
    } else {
      throw Exception('Failed to send request');
    }
  }
  Future<String> sendJoinRequest() async {
    print("Sending join request");
    var user = FirebaseAuth.instance.currentUser;
    var uid = user?.uid ?? '0';
    print("uid: $uid");
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable("request_to_join");
    final request = await callable.call(<String,dynamic>{
      'type':'video',
      'uid': uid,
    });
    if(request.data['status'] == 200){
      print("request id: ${request.data['id'] }");
      return request.data['id'];
    } else {
      throw Exception('Failed to send request');
    }
  }
  listenForRequestApproval(String requestId, Function callback) {
    return FirebaseFirestore.instance.collection('joinRequests').doc(requestId).snapshots(includeMetadataChanges: true).listen((snapshot) {
      print("snapshot: ${snapshot.data()}");
      if (snapshot.exists && snapshot.data()?['status'] == 'accepted') {
        print("Request approved");
        var token = snapshot.data()?['context']['token'];
        var channelName = snapshot.data()?['context']['channel'];
        callback(token, channelName); // Handle the approval
      }
    });
  }

  void _joinChannel(token, channel) async {
    await agoraEngine.startPreview();

    RTC_Engine.ChannelMediaOptions options = const RTC_Engine.ChannelMediaOptions(
      clientRoleType: RTC_Engine.ClientRoleType.clientRoleAudience,
      channelProfile: RTC_Engine.ChannelProfileType.channelProfileCommunication,
    );

    print("Joining channel");
    await agoraEngine.joinChannel(
      token: token,
      channelId: channel,
      options: options,
      uid: 0,
    );
  }

  void leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }

  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
    await agoraEngine.release();
    super.dispose();
  }
  Future<bool?> showWaitingDialog() {
    if (!mounted) return Future.value(false);
    return showDialog<bool>(
      context: context,
      barrierDismissible: true, // Allow the dialog to be closed manually
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text("Waiting for Approval"),
          content:  Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Please wait while we process your request"),
              SizedBox(height: 20),
              LoadingWidget(),
            ],
          ),
        );
      },
    );
  }
  Future<void> cancelJoinRequest(String requestId) async {
    var user = FirebaseAuth.instance.currentUser;
    var uid = user?.uid ?? '0';
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable("cancel_request_to_join");
    await callable.call(<String,dynamic>{
      'uid': uid,
    });
  }
  showMessage(String message) {
    SnackBar(
      content: Text(message),
    );
  }

  onMuteChecked(bool value) {
    setState(() {
      muted = value;
      agoraEngine.muteAllRemoteAudioStreams(muted);
    });
  }

  onCameraChecked(bool value) {
    setState(() {
      isCameraToggled = value;
      agoraEngine.enableLocalVideo(isCameraToggled);
    });
  }

  onVolumeChanged(double newValue) {
    setState(() {
      volume = newValue.toInt();
      agoraEngine.adjustRecordingSignalVolume(volume);
    });
  }

  void onVolumeIconPressed() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Adjust Volume',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    min: 0,
                    max: 100,
                    value: volume.toDouble(),
                    onChanged: (value) {
                      setModalState(() {
                        volume = value.toInt();
                      });
                      onVolumeChanged(value);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
