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

  static void init(GameState gameState, {String serverUrl = 'http://localhost:5215'}) {
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
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

  runApp(ScoreboardDisplayApp());
}

class ScoreboardDisplayApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState(),
      child: MaterialApp(
        title: 'Cartelera Digital',
        theme: ThemeData(primarySwatch: Colors.blue, visualDensity: VisualDensity.adaptivePlatformDensity),
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

class _ScoreboardDisplayState extends State<ScoreboardDisplay> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  final TextEditingController _serverController = TextEditingController(text: 'localhost:5215');
  String? errorText;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _pulseController = AnimationController(duration: Duration(milliseconds: 1500), vsync: this)..repeat(reverse: true);

    _slideController = AnimationController(duration: Duration(milliseconds: 800), vsync: this);

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
            padding: EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header with set info
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      style:
                          TextButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            minimumSize: const Size(40, 40),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            alignment: Alignment.center,
                          ).copyWith(
                            overlayColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                              if (states.contains(WidgetState.focused)) {
                                return Colors.white;
                              }
                              return null; // Defer to the default
                            }),
                          ),
                      onPressed: () {
                        _showConnectionDialog();
                      },
                      child: Text(
                        "■",
                        style: TextStyle(color: TVSocketService.isConnected ? Colors.green : Colors.red, fontSize: 20, fontFamily: 'Leds'),
                      ),
                    ),
                  ],
                ),
                // Main scoreboard
                Expanded(child: _buildMainScoreboard(gameState)),

                // Sets display
                _buildSetsSection(gameState),

                // Status indicator
                //_buildStatusIndicator(gameState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainScoreboard(GameState gameState) {
    return Row(
      children: [
        // Team 1
        Expanded(flex: 4, child: _buildTeamDisplay(gameState.team1Name, gameState.team1Score, Colors.blue, isLeft: true)),

        // VS Separator
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 120),
              Container(
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Text(
                  gameState.isGameActive ? 'VS' : " l l ",
                  style: TextStyle(color: Colors.yellow, fontSize: 22, fontFamily: 'Leds', letterSpacing: 4),
                ),
              ),

              SizedBox(height: 20),

              Text(
                'SET ${gameState.currentSet}',
                style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Leds', letterSpacing: 2),
              ),
            ],
          ),
        ),

        // Team 2
        Expanded(flex: 4, child: _buildTeamDisplay(gameState.team2Name, gameState.team2Score, Colors.red, isLeft: false)),
      ],
    );
  }

  Widget _buildTeamDisplay(String teamName, int score, Color teamColor, {required bool isLeft}) {
    return Container(
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
            style: TextStyle(color: teamColor, fontSize: 44, fontFamily: 'Leds', letterSpacing: 3),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 10),

          // Score display with animation y FittedBox
          Text(
            score.toString(),
            style: TextStyle(color: const Color.fromARGB(255, 50, 255, 50), fontSize: 170, fontWeight: FontWeight.w100, fontFamily: 'Leds'),
          ),
        ],
      ),
    );
  }

  Widget _buildSetsSection(GameState gameState) {
    return Card(
      elevation: 1,
      color: const Color.fromARGB(255, 37, 37, 37),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'SETS GANADOS',
              style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Leds', letterSpacing: 2),
            ),
            //SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Team 1 sets
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      gameState.team1Name.toUpperCase(),
                      style: TextStyle(color: Colors.blue, fontSize: 20, fontFamily: 'Leds'),
                    ),
                    SizedBox(height: 12),
                    Text(
                      gameState.team1Sets.toString(),
                      style: TextStyle(color: Colors.green, fontSize: 50, fontFamily: 'Leds'),
                    ),
                  ],
                ),

                // Separator
/*                 Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "|",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 30, fontFamily: 'Leds'),
                      ),
                    ],
                  ), */

                // Team 2 sets
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      gameState.team2Name.toUpperCase(),
                      style: TextStyle(color: Colors.red, fontSize: 20, fontFamily: 'Leds'),
                    ),
                    SizedBox(height: 12),
                    Text(
                      gameState.team2Sets.toString(),
                      style: TextStyle(color: Colors.green, fontSize: 50, fontFamily: 'Leds'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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
            child: Text('Configurar Conexión', style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          content: SizedBox(
            height: 100,
            width: 420,
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  child: Expanded(
                    child: TextField(
                      inputFormatters: [
                        //Only numbers and dots
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.:0-9]')),
                      ],
                      controller: _serverController,
                      style: TextStyle(color: Colors.white, fontSize: 30),
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        error: errorText != null ? Text(errorText!, style: TextStyle(color: Colors.red)) : null,
                        labelText: 'IP del servidor (ej: 192.168.1.1:5215)',
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 30),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                      ),
                      //FocusScope.of(context).unfocus();
                      //onTap open keyboard
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      autofocus: true,
                      onChanged: (value) {
                        if (value.isEmpty || !RegExp(r'^[0-9.:]+$').hasMatch(value)) {
                          errorText = "Dirección inválida";
                        } else {
                          errorText = null;
                        }
                        setState(() {});
                      },
                      onSubmitted: (value) {
                        _connectToServer();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              style:
                  TextButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                    minimumSize: const Size(40, 40),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.center,
                  ).copyWith(
                    overlayColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                      if (states.contains(WidgetState.focused)) {
                        return Colors.white;
                      }
                      return Colors.red; // Defer to the default
                    }),
                  ),
              child: Text('Cancelar', style: TextStyle(fontSize: 14)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style:
                  TextButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                    minimumSize: const Size(40, 40),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.center,
                  ).copyWith(
                    overlayColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                      if (states.contains(WidgetState.focused)) {
                        return Colors.white;
                      }
                      return Colors.green; // Defer to the default
                    }),
                  ),
              child: Text('Conectar', style: TextStyle(fontSize: 14)),
              onPressed: _connectToServer,
            ),
          ],
        );
      },
    );
  }

  void _connectToServer() async {
    String serverUrl = _serverController.text.trim();
    if (serverUrl.isNotEmpty) {
      TVSocketService.dispose();
      final gameState = Provider.of<GameState>(context, listen: false);
      TVSocketService.init(gameState, serverUrl: 'http://$serverUrl');
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Conectando a $serverUrl"), duration: const Duration(seconds: 2)));
      setState(() {});
    }

    /* () async {
                if (TVSocketService.isConnected) {
                  TVSocketService.disconnect();
                }
                TVSocketService.connect();
                await Future.delayed(const Duration(seconds: 1));
                if (TVSocketService.isConnected) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Conectado a ${_serverController.text}")));
                }
                Navigator.of(context).pop();
              }, */
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    TVSocketService.dispose();
    super.dispose();
  }
}
