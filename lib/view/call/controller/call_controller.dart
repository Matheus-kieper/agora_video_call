import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_video_call/constants.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class CallController extends GetxController {
  RxInt? remoteId;
  RtcEngine engine = createAgoraRtcEngine();
  RxBool isCameraEnabled = true.obs;
  RxBool isMuted = false.obs;
  RxBool isGuestMuted = false.obs;
  RxBool isGuestJoined = false.obs;
  String channelName = '';
  int? id;

 /* @override
  void onInit() async {
    super.onInit();
    initAgora();
  }*/


  Future<void> initAgora() async {
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
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          //localUserJoined.value = true;
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          id = remoteUid;
          isGuestJoined.value = true;
        },
        onUserOffline: (
          RtcConnection connection,
          int remoteUid,
          UserOfflineReasonType reason,
        ) {
          
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

  Future<void> disposeData() async {
    await engine.leaveChannel();
    await engine.release();
    localUserJoined.value = false;
  }

  final RxBool screenTapped = false.obs;
  final RxBool localUserJoined = false.obs;
}
