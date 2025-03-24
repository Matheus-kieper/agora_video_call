import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_video_call/view/call/controller/call_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallPage extends StatefulWidget {
  const CallPage({this.channelName, this.role, super.key});
  final String? channelName;
  final ClientRoleType? role;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final controller = Get.put(CallController());


  @override
  void dispose() {
    super.dispose();
    controller.disposeData();
  }

  @override
  void initState() {
    super.initState();
    controller.initAgora(widget.channelName!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InkWell(
          onTap: () async {
            controller.screenTapped.value = !controller.screenTapped.value;
            Future.delayed(const Duration(seconds: 5), () {
              controller.screenTapped.value = !controller.screenTapped.value;
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
                          controller.localUserJoined.value
                              ? AgoraVideoView(
                                controller: VideoViewController(
                                  rtcEngine: controller.engine,
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
                      !controller.screenTapped.value
                          ? Text('')
                          : Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Obx(() => _muteGuest()),
                                Obx(() => _muteMic()),
                                _endCall(),
                                Obx(() => _enableCameraButton()),
                                _switchCamera(),
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
    if (controller.remoteId != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: controller.engine,
          canvas: VideoCanvas(uid: controller.remoteId),
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
        controller.isCameraEnabled.value = !controller.isCameraEnabled.value;
        if (controller.isCameraEnabled.value) {
          controller.engine.enableVideo();
        } else {
          controller.engine.disableVideo();
        }
      },
      icon: Icon(
        controller.isCameraEnabled.value
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
        controller.disposeData();
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
        controller.isMuted.value = !controller.isMuted.value;
        controller.engine.muteLocalAudioStream(controller.isMuted.value);
      },
      icon: Icon(controller.isMuted.value ? Icons.mic_off : Icons.mic),
    );
  }

  Widget _switchCamera() {
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
        controller.engine.switchCamera();
      },
      icon: Icon(Icons.switch_camera_rounded),
    );
  }

  Widget _muteGuest() {
    return IconButton(
      onPressed: () {
        controller.isGuestMuted.value = !controller.isGuestMuted.value;
        controller.engine.muteAllRemoteAudioStreams(controller.isGuestMuted.value);
      },
      icon: Icon(controller.isGuestMuted.value ? Icons.headset_off : Icons.headphones),
    );
  }
}
