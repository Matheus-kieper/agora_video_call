import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'dart:developer';
import 'package:permission_handler/permission_handler.dart';
import 'call_page.dart';

//Para fazer a conexão entre usuários é usado um token disponibilizado no Concole do Agora.IO
//porém por ser um token de test, ele expira em 24 horas, é necessário ir no console e gerar outro

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final _chanellController = TextEditingController();
  var _validateError = false;
  final ClientRoleType _role = ClientRoleType.clientRoleBroadcaster;

  @override
  void dispose() {
    _chanellController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video chamada')),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              SizedBox(
                height: 200,
                width: 300,
                child: SvgPicture.asset(
                  'assets/logo_riit_red.svg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _chanellController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
                  errorText:
                      _validateError ? 'Nome do canal é obrigatório' : null,
                  hintText: 'Nome do canal',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: join,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 40),
                ),
                child: Text('Join'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> join() async {
    setState(() {
      _chanellController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    if (_chanellController.text.isNotEmpty) {
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  CallPage(channelName: _chanellController.text, role: _role),
        ),
      );
    }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    log('Permission status: $status');
  }
}
