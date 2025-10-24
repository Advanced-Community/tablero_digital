import 'dart:convert';

import 'package:just_audio/just_audio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tablero_digital/models/sound.model.dart';
import 'package:tablero_digital/provider/game.provider.dart';
import 'package:http/http.dart' as http;

// TV Socket Service
class TVSocketService {
  static IO.Socket? _socket;
  static GameState? _gameState;
  static bool isConnected = false;
  static String _serverUrl = 'https://panel.acteam.dev';

  static void init(GameState gameState, {String serverUrl = 'https://panel.acteam.dev'}) {
    _gameState = gameState;
    _serverUrl = serverUrl;
    _socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.on('connect', (_) {
      print('TV Display connected to server');
      isConnected = true;
    });

    // Listen for playSound event
    _socket!.on('playSound', (data) {
      /* 
      String soundFile = data['file'] ?? '';
      if (soundFile.isNotEmpty) {
        // Play sound using just_audio package
        // Note: Ensure you have added just_audio to your pubspec.yaml
        // and imported it at the top of this file.
        final player = AudioPlayer();
        player.setAsset('assets/sounds/$soundFile').then((_) {
          player.play();
        });
      } */

      final res = Sound.fromJson(Map<String, dynamic>.from(data));

      print('Received playSound event: ${res.name}');
      playSound(res.name);
    });

    _socket!.on('scoreUpdate', (data) {
      if (_gameState != null) {
        _gameState!.updateFromJson(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('disconnect', (_) {
      print('TV Display disconnected from server');
      isConnected = false;
    });
  }

  static void dispose() {
    _socket?.dispose();
  }

  static void connect() {
    _socket!.connect();
  }

  static void disconnect() {
    _socket!.disconnect();
  }

  static void playSound(String soundFile) async {
    final audioPlay = AudioPlayer();
    print('$_serverUrl/sound/$soundFile');
    audioPlay.setUrl('$_serverUrl/sound/$soundFile').then((_) {
      audioPlay.play();
    }).catchError((error) {
      print('Error loading sound: $error');
    });
  }
}
