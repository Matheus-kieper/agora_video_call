import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_video_call/constants.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class CallController extends GetxController{
  int? remoteId;
  late RtcEngine engine;
  //ClientRoleType? _initialRole;
  RxBool isCameraEnabled = true.obs;
  RxBool isMuted = false.obs;
  RxBool isGuestMuted = false.obs;


  Future<void> initAgora(String channelName) async {
    //permissões
    await [Permission.microphone, Permission.camera].request();

    //_initialRole = widget.role;

    //criando a engine
    engine = createAgoraRtcEngine();
    await engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );
    localUserJoined.value = true;
    engine.registerEventHandler(
      RtcEngineEventHandler(
        /*onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            localUserJoined.value = true;
          });
        },*/
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            remoteUid = remoteUid;
        },
        onUserOffline: (
          RtcConnection connection,
          int remoteUid,
          UserOfflineReasonType reason,
        ) {
            remoteId = null;
        },
        /*onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
            '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token',
          );
        },*/
      ),
    );

    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine.enableVideo();
    await engine.startPreview();

    await engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    disposeData();
  }

  Future<void> disposeData() async {
    await engine.leaveChannel();
    await engine.release();
    remoteId = null;
    engine.disableAudio();
    engine.muteLocalVideoStream(true);
  }

  final RxBool screenTapped = false.obs;
  final RxBool localUserJoined = false.obs;
}