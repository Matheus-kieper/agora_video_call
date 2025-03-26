import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_video_call/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class CallController extends GetxController {
  RtcEngine engine = createAgoraRtcEngine();
  RxBool isCameraEnabled = true.obs;
  RxBool isMuted = false.obs;
  RxBool isGuestMuted = false.obs;
  RxBool isGuestJoined = false.obs;
  String channelName = '';
  final RxBool screenTapped = false.obs;
  final RxBool localUserJoined = false.obs;
  int? id;
  

  Future<void> initAgora() async {
    //permissões
    await [Permission.microphone, Permission.camera].request();

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

  Widget endCall(BuildContext context) {
    return IconButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          return Colors.red;
        }),
        iconColor: WidgetStateProperty.resolveWith<Color?>((states) {
          return Colors.black;
        }),
      ),
      onPressed: () async {
        await disposeData();
        Navigator.pop(context);
      },
      icon: Icon(Icons.call_end),
    );
  }

  Widget muteGuest() {
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
        isGuestMuted.value = !isGuestMuted.value;
        engine.muteAllRemoteAudioStreams(
          isGuestMuted.value,
        );
      },
      icon: Icon(
        isGuestMuted.value ? Icons.headset_off : Icons.headphones,
      ),
    );
  }

  Widget switchCamera() {
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
        engine.switchCamera();
      },
      icon: Icon(Icons.switch_camera_rounded),
    );
  }

  Widget muteMic() {
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
        engine.muteLocalAudioStream(isMuted.value);
      },
      icon: Icon(isMuted.value ? Icons.mic_off : Icons.mic),
    );
  }

  Widget enableCameraButton() {
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
        if (isCameraEnabled.value) {
          engine.enableVideo();
        } else {
          engine.disableVideo();
        }
      },
      icon: Icon(
        isCameraEnabled.value
            ? Icons.videocam_rounded
            : Icons.videocam_off_rounded,
      ),
    );
  }
}
