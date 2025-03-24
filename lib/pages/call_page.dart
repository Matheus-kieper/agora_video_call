import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_video_call/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class CallPage extends StatefulWidget {
  const CallPage({this.channelName, this.role, super.key});
  final String? channelName;
  final ClientRoleType? role;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  int? _remoteUid;
  late RtcEngine _engine;
  //ClientRoleType? _initialRole;
  RxBool isCameraEnabled = true.obs;
  RxBool isMuted = false.obs;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    //permissões
    await [Permission.microphone, Permission.camera].request();

    //_initialRole = widget.role;

    //criando a engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );
    _localUserJoined.value = true;
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        /*onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined.value = true;
          });
        },*/
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (
          RtcConnection connection,
          int remoteUid,
          UserOfflineReasonType reason,
        ) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
        /*onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
            '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token',
          );
        },*/
      ),
    );

    await _engine.setClientRole(role: widget.role!);
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: token,
      channelId: widget.channelName!,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
    _remoteUid = null;
    _engine.disableAudio();
    _engine.muteLocalVideoStream(true);
  }

  final RxBool _screenTapped = false.obs;
  final RxBool _localUserJoined = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InkWell(
          onTap: () async {
            _screenTapped.value = !_screenTapped.value;
            Future.delayed(const Duration(seconds: 5), () {
              _screenTapped.value = !_screenTapped.value;
            });
          },
          child: Stack(
            children: [
              Center(child: _remoteVideo()),
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  width: 200,
                  height: 250,
                  child: Obx(() {
                    return Center(
                      child:
                          _localUserJoined.value
                              ? AgoraVideoView(
                                controller: VideoViewController(
                                  rtcEngine: _engine,
                                  canvas: const VideoCanvas(uid: 0),
                                ),
                              )
                              : const Text('Carregando camera...'),
                    );
                  }),
                ),
              ),
              Obx(() {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child:
                      !_screenTapped.value
                          ? Text('')
                          : Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Obx(() => _muteMic()),
                                _endCall(),
                                Obx(() => _enableCameraButton()),
                                _switchCamera()
                              ],
                            ),
                          ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName!),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _enableCameraButton() {
    return IconButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          return Colors.grey;
        }),
        iconColor: WidgetStateProperty.resolveWith<Color?>((states) {
          return Colors.black;
        }),
      ),
      onPressed: () {
        isCameraEnabled.value = !isCameraEnabled.value;
        _engine.muteLocalVideoStream(isCameraEnabled.value);
      },
      icon: Icon(
        isCameraEnabled.value
            ? Icons.videocam_rounded
            : Icons.videocam_off_rounded,
      ),
    );
  }

  Widget _endCall() {
    return IconButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          return Colors.red;
        }),
        iconColor: WidgetStateProperty.resolveWith<Color?>((states) {
          return Colors.black;
        }),
      ),
      onPressed: () {
        Navigator.pop(context);
        _dispose();
      },
      icon: Icon(Icons.call_end),
    );
  }

  Widget _muteMic() {
    return IconButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          return Colors.grey;
        }),
        iconColor: WidgetStateProperty.resolveWith<Color?>((states) {
          return Colors.black;
        }),
      ),
      onPressed: () {
        isMuted.value = !isMuted.value;
        _engine.muteLocalAudioStream(isMuted.value);
      },
      icon: Icon(isMuted.value ? Icons.mic_off : Icons.mic),
    );
  }

  Widget _switchCamera(){
    return IconButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          return Colors.grey;
        }),
        iconColor: WidgetStateProperty.resolveWith<Color?>((states) {
          return Colors.black;
        }),
      ),
      onPressed: (){
      _engine.switchCamera();
    }, icon: Icon(Icons.switch_camera_rounded));
  }
}
