// pubspec.yaml dependencies needed:
// dependencies:
//   flutter:
//     sdk: flutter
//   socket_io_client: ^2.0.3+1
//   provider: ^6.1.1

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:math' as math;

// Same GameState model as control app
class GameState extends ChangeNotifier {
  String team1Name = "Equipo Azul";
  String team2Name = "Equipo Rojo";
  int team1Score = 0;
  int team2Score = 0;
  int team1Sets = 0;
  int team2Sets = 0;
  int currentSet = 1;
  bool isGameActive = false;

  void updateFromJson(Map<String, dynamic> data) {
    team1Name = data['team1Name'] ?? team1Name;
    team2Name = data['team2Name'] ?? team2Name;
    team1Score = data['team1Score'] ?? team1Score;
    team2Score = data['team2Score'] ?? team2Score;
    team1Sets = data['team1Sets'] ?? team1Sets;
    team2Sets = data['team2Sets'] ?? team2Sets;
    currentSet = data['currentSet'] ?? currentSet;
    isGameActive = data['isGameActive'] ?? isGameActive;
    notifyListeners();
  }
}

// TV Socket Service
class TVSocketService {
  static IO.Socket? _socket;
  static GameState? _gameState;
  static bool isConnected = false;

  static void init(
    GameState gameState, {
    String serverUrl = 'http://localhost:5215',
  }) {
    _gameState = gameState;
    _socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.on('connect', (_) {
      print('TV Display connected to server');
      isConnected = true;
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

    _socket!.on('sound', (data) {
      print('SOUND');
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
}

void main() {
  // Force landscape orientation for TV
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(ScoreboardDisplayApp());
}

class ScoreboardDisplayApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState(),
      child: MaterialApp(
        title: 'Cartelera Digital',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: ScoreboardDisplay(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class ScoreboardDisplay extends StatefulWidget {
  @override
  _ScoreboardDisplayState createState() => _ScoreboardDisplayState();
}

class _ScoreboardDisplayState extends State<ScoreboardDisplay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  final TextEditingController _serverController = TextEditingController(
    text: 'localhost:5215',
  );

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize socket connection
    final gameState = Provider.of<GameState>(context, listen: false);
    TVSocketService.init(gameState);

    // Enter fullscreen mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                // Header with set info
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        _showConnectionDialog();
                      },
                      child: Text(
                        "■",
                        style: TextStyle(
                          color: TVSocketService.isConnected
                              ? Colors.green
                              : Colors.red,
                          fontSize: 20,
                          fontFamily: 'Leds',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0),
                // Main scoreboard
                Expanded(child: _buildMainScoreboard(gameState)),

                SizedBox(height: 20),

                // Sets display
                _buildSetsSection(gameState),

                SizedBox(height: 20),

                // Status indicator
                //_buildStatusIndicator(gameState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(GameState gameState) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      /* decoration: BoxDecoration(
        color: Colors.grey[800]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[600]!, width: 2),
      ), */
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'SET ${gameState.currentSet}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Leds',
              letterSpacing: 2,
            ),
          ),
          Text(
            gameState.isGameActive ? '>' : 'l l',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Leds',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainScoreboard(GameState gameState) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Team 1
        Expanded(
          flex: 4,
          child: _buildTeamDisplay(
            gameState.team1Name,
            gameState.team1Score,
            Colors.blue,
            isLeft: true,
          ),
        ),

        // VS Separator
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Text(
                  gameState.isGameActive ? 'VS' : " l l ",
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 20,
                    fontFamily: 'Leds',
                    letterSpacing: 4,
                  ),
                ),
              ),

              Text(
                'SET ${gameState.currentSet}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Leds',
                  letterSpacing: 2,
                ),
              ),

              /* SizedBox(height: 20), */
              // Animated separator line
              /* AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    height: 4,
                    width: 100 + (_pulseController.value * 50),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.white, Colors.red],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              ), */
            ],
          ),
        ),

        // Team 2
        Expanded(
          flex: 4,
          child: _buildTeamDisplay(
            gameState.team2Name,
            gameState.team2Score,
            Colors.red,
            isLeft: false,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamDisplay(
    String teamName,
    int score,
    Color teamColor, {
    required bool isLeft,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(30),
      /* decoration: BoxDecoration(
        color: teamColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: teamColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: teamColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ), */
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Team name
          Text(
            teamName.toUpperCase(),
            style: TextStyle(
              color: teamColor,
              fontSize: 40,
              fontFamily: 'Leds',
              letterSpacing: 3,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 20),

          // Score display with animation y FittedBox
          Text(
            score.toString(),
            style: TextStyle(
              color: const Color.fromARGB(255, 50, 255, 50),
              fontSize: 100,
              fontWeight: FontWeight.w100,
              fontFamily: 'Leds',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetsSection(GameState gameState) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 40),
      /* decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[600]!, width: 2),
      ), */
      child: Column(
        children: [
          Text(
            'SETS GANADOS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Leds',
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Team 1 sets
              Column(
                children: [
                  Text(
                    gameState.team1Name.toUpperCase(),
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontFamily: 'Leds',
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    gameState.team1Sets.toString(),
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontFamily: 'Leds',
                    ),
                  ),
                ],
              ),

              // Separator
              Text(
                "l",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Leds',
                ),
              ),

              // Team 2 sets
              Column(
                children: [
                  Text(
                    gameState.team2Name.toUpperCase(),
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontFamily: 'Leds',
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    gameState.team2Sets.toString(),
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 50,
                      fontFamily: 'Leds',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(GameState gameState) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: gameState.isGameActive
                ? Colors.green.withOpacity(0.8 + (_pulseController.value * 0.2))
                : Colors.orange.withOpacity(0.8),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                gameState.isGameActive ? Icons.play_circle : Icons.pause_circle,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                gameState.isGameActive ? 'JUEGO EN CURSO' : 'JUEGO PAUSADO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConnectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Configurar Conexión',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          content: SizedBox(
            height: 70,
            width: 70,
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  child: Expanded(
                    child: TextField(
                      controller: _serverController,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      decoration: InputDecoration(
                        labelText: 'IP del servidor (ej: localhost:5215)',
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              child: Text('Cancelar', style: TextStyle(fontSize: 14)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Conectar', style: TextStyle(fontSize: 14)),
              onPressed: () async {
                if (TVSocketService.isConnected) {
                  TVSocketService.disconnect();
                }
                TVSocketService.connect();
                await Future.delayed(const Duration(seconds: 1));
                if (TVSocketService.isConnected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Conectado a ${_serverController.text}"),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    TVSocketService.dispose();
    super.dispose();
  }
}
