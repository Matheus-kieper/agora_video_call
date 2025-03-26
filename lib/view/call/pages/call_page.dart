import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_video_call/view/call/controller/call_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallPage extends StatefulWidget {
  const CallPage({this.channelName, super.key});
  final String? channelName;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final controller = Get.put(CallController());
  RtcEngine engine = createAgoraRtcEngine();
  int? id;

  @override
  void initState() {
    super.initState();
    controller.channelName = widget.channelName!;
    controller.initAgora();
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
              Center(
                child: Obx(
                  () =>
                      controller.isGuestJoined.value
                          ? _remoteVideo()
                          : Text(''),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  width: 200,
                  height: 250,
                  child: Center(
                    child: Obx(
                      () =>
                          controller.localUserJoined.value
                              ? AgoraVideoView(
                                controller: VideoViewController(
                                  rtcEngine: controller.engine,
                                  canvas: const VideoCanvas(uid: 0),
                                ),
                              )
                              : const Text('Carregando camera...'),
                    ),
                  ),
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
                                Obx(() => controller.muteGuest()),
                                Obx(() => controller.muteMic()),
                                controller.endCall(context),
                                Obx(() => controller.enableCameraButton()),
                                controller.switchCamera(),
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
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: controller.engine,
        canvas: VideoCanvas(uid: controller.id),
        connection: RtcConnection(channelId: widget.channelName!),
      ),
    );
  }
}
