import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:counter/widgets/loading_widget.dart';
class VideoCallScreen extends StatelessWidget {
  VideoCallScreen(this.clientContext, this.loungeCallback, {super.key});
  final clientContext;
  final Function loungeCallback;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: VideoCallScreenBody(clientContext, loungeCallback),
    );
  }
}

class VideoCallScreenBody extends StatefulWidget {
  VideoCallScreenBody(this.clientContext, this.loungeCallback, {super.key});
  final clientContext;
  final Function loungeCallback;
  @override
  _VideoCallScreenState createState() => _VideoCallScreenState(clientContext, loungeCallback);
}

class _VideoCallScreenState extends State<VideoCallScreenBody> {
  _VideoCallScreenState(this.clientContext, this.loungeCallback);
  dynamic clientContext;
  final Function loungeCallback; 
  int localUid = 0;
  String appId = "", channelName = "";
  final remoteUids = []; // Uids of remote users in the channel
  bool isRemoteUserViewLoaded = false; // Indicates if remote user is loaded
  bool isJoined = false; // Indicates if the local user has joined the channel
  RtcEngine? agoraEngine; // Agora engine instance
  final logLevel = LogLevel.logLevelFatal;
  int volume = 50; // Current speaker volume
  bool muted = false; // Current microphone state
  bool isCameraToggled = true; // Current camera state
  @override
  void initState() {
    super.initState();
    appId = clientContext['appId'];
    channelName = clientContext['channel'];
    remoteUids.add(clientContext['employee_id']);
    setupAgoraEngine(clientContext).then((_) {
      _joinChannel(clientContext['token'], clientContext['channel']);
    });
  }

  Future<void> setupAgoraEngine(clientContext) async {
    LogConfig logConfig = LogConfig(level: logLevel);
    // Retrieve or request camera and microphone permissions
    await [Permission.microphone, Permission.camera].request();
    // Create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    if (agoraEngine == null) {
      print("Failed to create RtcEngine instance");
      return;
    }
    await agoraEngine!.initialize(
        RtcEngineContext(appId: clientContext['appId'], logConfig: logConfig));
    agoraEngine!.registerEventHandler(getEventHandler());
    await agoraEngine!.enableVideo();
    // Register the event handler
  }

  eventCallback(String eventName, Map<dynamic, dynamic> map) {
    if (eventName == "onUserOffline") {
      loungeCallback("remoteUserLeft");
    }
    if (eventName == "onConnectionStateChanged" && map["reason"] == ConnectionChangedReasonType.connectionChangedLeaveChannel ) {
      loungeCallback("localUserLeft");
    }
  }

  messageCallback(String msg) {
    print("messageCallback $msg");
  }

  RtcEngineEventHandler getEventHandler() {
    return RtcEngineEventHandler(
      // Occurs when the network connection state changes
      onConnectionStateChanged: (RtcConnection connection,
          ConnectionStateType state, ConnectionChangedReasonType reason) {
        if (reason ==
            ConnectionChangedReasonType.connectionChangedLeaveChannel) {
          remoteUids.clear();
          isJoined = false;
        }
        // Notify the UI
        Map<String, dynamic> eventArgs = {};
        eventArgs["connection"] = connection;
        eventArgs["state"] = state;
        eventArgs["reason"] = reason;
        eventCallback("onConnectionStateChanged", eventArgs);
      },
      // Occurs when a local user joins a channel
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        messageCallback(
            "Local user uid:${connection.localUid} joined the channel");
        // Notify the UI
        Map<String, dynamic> eventArgs = {};
        eventArgs["connection"] = connection;
        eventArgs["elapsed"] = elapsed;
        eventCallback("onJoinChannelSuccess", eventArgs);
      },
      // Occurs when a remote user joins the channel
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        remoteUids.add(remoteUid);
        messageCallback("Remote user uid:$remoteUid joined the channel");
        // Notify the UI
        Map<String, dynamic> eventArgs = {};
        eventArgs["connection"] = connection;
        eventArgs["remoteUid"] = remoteUid;
        eventArgs["elapsed"] = elapsed;
        eventCallback("onUserJoined", eventArgs);
      },
      // Occurs when a remote user leaves the channel
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        remoteUids.remove(remoteUid);
        messageCallback("Remote user uid:$remoteUid left the channel");
        // Notify the UI
        Map<String, dynamic> eventArgs = {};
        eventArgs["connection"] = connection;
        eventArgs["remoteUid"] = remoteUid;
        eventArgs["reason"] = reason;
        eventCallback("onUserOffline", eventArgs);
      },
    );
  }

  void _joinChannel(token, channel) async {
    if (agoraEngine == null) return;
    await agoraEngine!.startPreview();
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    await agoraEngine!.joinChannel(
      token: token,
      channelId: channel,
      uid: localUid,
      options: options,
    );
    setState(() {
      isJoined = true;
      // Update the state to reflect that the channel is joined
    });
  }

  remoteVideoView(remoteUid) {
    if (agoraEngine == null) return;
    var remoteView = AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: agoraEngine!,
        canvas: VideoCanvas(uid: remoteUid),
        connection: RtcConnection(channelId: channelName),
      ),
    );
    return remoteView;
  }

  localVideoView() {
    if (agoraEngine == null) return;
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: agoraEngine!,
        canvas: VideoCanvas(uid: localUid), // Use uid = 0 for local view
      ),
    );
  }

  Future<void> leave() async {
    if (!isJoined || agoraEngine == null) return;
    // Clear saved remote Uids
    remoteUids.clear();
    // Leave the channel
    await agoraEngine!.leaveChannel();
    isJoined = false;
    // Destroy the Agora engine instance
    destroyAgoraEngine();
  }

  void destroyAgoraEngine() {
    // Release the RtcEngine instance to free up resources
    if (agoraEngine != null) agoraEngine!.release();
    agoraEngine = null;
  }

  @override
  void dispose() {
    // Clean up the controller and the Agora engine instance
    destroyAgoraEngine();
    super.dispose();
  }

  onMuteChecked(bool value) {
    setState(() {
      muted = value;
      agoraEngine!.muteAllRemoteAudioStreams(muted);
    });
  }

  onCameraChecked(bool value) {
    setState(() {
      isCameraToggled = value;
      agoraEngine!.enableLocalVideo(isCameraToggled);
    });
  }

  onVolumeChanged(double newValue) {
    setState(() {
      volume = newValue.toInt();
      agoraEngine!.adjustRecordingSignalVolume(volume);
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

  Widget _buildControls() {
    return Row(
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
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            leave();
          },
          color: Colors.redAccent,
          icon: const Icon(Icons.call_end),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      isJoined ? remoteVideoView(remoteUids[0]) : const LoadingWidget(),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: SizedBox(
                          width: 100,
                          height: 150,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: isJoined
                                  ? localVideoView()
                                  : const LoadingWidget()),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildControls(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
