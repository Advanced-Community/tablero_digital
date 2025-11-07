import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tablero_digital/provider/game.provider.dart';
import 'package:tablero_digital/services/tv.socket.dart';

void main() {
  // Force landscape orientation for TV
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(ScoreboardDisplayApp());
}

class AppColors {
  static const Color bgDark = Color(0xFF121212);
  static const Color bgLight = Color(0xFF1E1E1E);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentRed = Color(0xFFE53935);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color neonGreen = Color(0xFF00E676);
}

class FontSizes {
  double fontSizeTeamName;
  double fontSizeScore;
  double fontSizeSets;

  FontSizes({
    this.fontSizeTeamName = 54,
    this.fontSizeScore = 270,
    this.fontSizeSets = 60,
  });
}

class ScoreboardDisplayApp extends StatelessWidget {
  const ScoreboardDisplayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState(),
      child: MaterialApp(
        title: 'Tablero Digital',
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
  const ScoreboardDisplay({super.key});

  @override
  ScoreboardDisplayState createState() => ScoreboardDisplayState();
}

class ScoreboardDisplayState extends State<ScoreboardDisplay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  final TextEditingController _serverController = TextEditingController(
    text: 'panel.acteam.dev',
  );
  String? errorText;
  bool isHttps = true;
  FontSizes fontSizes = FontSizes();
  double separateHeight = 10.0;

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

  void setFontSize({required int value}) {
    setState(() {
      //fontSizes.fontSizeTeamName = (fontSizes.fontSizeTeamName + value).clamp(20, 100) as double;
      fontSizes.fontSizeScore =
          (fontSizes.fontSizeScore + value).clamp(180, 320) as double;
      //fontSizes.fontSizeSets = (fontSizes.fontSizeSets + value).clamp(10, 100) as double;
      //separateHeight = (separateHeight + value).clamp(0.0, 10.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      body: Material(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              //end: Alignment(0.3, 0.4),
              colors: <Color>[Colors.blue, Colors.red],
              stops: [0.53, 0.5],
              tileMode: TileMode.mirror,
            ),
          ),
          child: Consumer<GameState>(
            builder: (context, gameState, child) {
              return Padding(
                padding: EdgeInsets.all(4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Botones de ajuste de fuentes en el header
                    /*Focus(
                  onKeyEvent: (FocusNode node, KeyEvent event) {
                    if (event.logicalKey.debugName == "Go Back" &&
                        node.hasFocus) {
                      node.unfocus();
                      return KeyEventResult.handled;
                    }

                    if (event.logicalKey.debugName == "Go Back" &&
                        !node.hasFocus) {
                      _showDialogExit();
                      return KeyEventResult.handled;
                    }

                    return KeyEventResult.ignored;
                  },
                  child: */
                    Card(
                      elevation: 1,
                      color: const Color.fromARGB(255, 37, 37, 37),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              style:
                                  TextButton.styleFrom(
                                    padding: const EdgeInsets.all(0),
                                    minimumSize: const Size(40, 40),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    alignment: Alignment.center,
                                  ).copyWith(
                                    overlayColor: WidgetStatePropertyAll<Color>(
                                      Colors.white,
                                    ),
                                  ),
                              onPressed: () {
                                _showConnectionDialog();
                              },
                              icon: Icon(
                                TVSocketService.isConnected
                                    ? Icons.compass_calibration_sharp
                                    : Icons.compass_calibration_outlined,
                                color: TVSocketService.isConnected
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'SET ${gameState.currentSet}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontFamily: 'Leds',
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(width: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                  style:
                                      TextButton.styleFrom(
                                        padding: const EdgeInsets.all(0),
                                        minimumSize: const Size(40, 40),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        alignment: Alignment.center,
                                      ).copyWith(
                                        overlayColor:
                                            WidgetStatePropertyAll<Color>(
                                              Colors.white,
                                            ),
                                        iconColor:
                                            WidgetStateProperty.resolveWith<
                                              Color?
                                            >((Set<WidgetState> states) {
                                              if (states.contains(
                                                WidgetState.focused,
                                              )) {
                                                return Colors.red;
                                              }
                                              return Colors
                                                  .white; // Defer to the default
                                            }),
                                      ),
                                  icon: Icon(
                                    Icons.remove_circle_outline,
                                    //color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setFontSize(value: -10);
                                  },
                                ),
                                SizedBox(width: 10),
                                IconButton(
                                  style:
                                      TextButton.styleFrom(
                                        padding: const EdgeInsets.all(0),
                                        minimumSize: const Size(40, 40),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        alignment: Alignment.center,
                                      ).copyWith(
                                        overlayColor:
                                            WidgetStatePropertyAll<Color>(
                                              Colors.white,
                                            ),
                                        iconColor:
                                            WidgetStateProperty.resolveWith<
                                              Color?
                                            >((Set<WidgetState> states) {
                                              if (states.contains(
                                                WidgetState.focused,
                                              )) {
                                                return Color.fromARGB(
                                                  255,
                                                  0,
                                                  149,
                                                  255,
                                                );
                                              }
                                              return Colors
                                                  .white; // Defer to the default
                                            }),
                                      ),
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    //color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setFontSize(value: 10);
                                  },
                                ),
                              ],
                            ),
                          ],
                          //),
                        ),
                      ),
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
        ),
      ),
    );
  }

  Widget _buildMainScoreboard(GameState gameState) {
    return Row(
      children: [
        // Team 1
        Expanded(
          flex: 4,
          child: _buildTeamDisplay(
            gameState.team1Name,
            gameState.team1Score,
            Colors.white,
            isLeft: true,
          ),
        ),

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
                child: gameState.isGameActive
                    ? Image.asset("assets/versus.png")
                    : Image.asset("assets/pause.png"),
                /*Text(
                  gameState.isGameActive ? 'VS' : " l l ",
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 33,
                    fontFamily: 'Leds',
                    letterSpacing: 4,
                  ),
                ),*/
              ),

              SizedBox(height: 20),
            ],
          ),
        ),

        // Team 2
        Expanded(
          flex: 4,
          child: _buildTeamDisplay(
            gameState.team2Name,
            gameState.team2Score,
            Colors.white,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Team name
        Text(
          teamName.toUpperCase(),
          style: TextStyle(
            color: teamColor,
            fontSize: fontSizes.fontSizeTeamName - 8, // Se actualiza aquí
            fontFamily: 'Leds',
            letterSpacing: 3,
          ),
          textAlign: TextAlign.center,
        ),

        //Container(color: Colors.red, width: 100,height: separateHeight),

        // Score display with animation y FittedBox
        Expanded(
          child: Transform.translate(
            // Mover el número hacia arriba en el eje Y (valor negativo)
            offset: Offset(0.0, -45.0),
            // Ajusta este valor (ej: -20.0) para "subir" el número
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Esto es correcto
              children: [
                Text(
                  score.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSizes.fontSizeScore,
                    fontWeight: FontWeight.w100,
                    fontFamily: 'Leds',
                    // Altura de línea ajustada (opcional, prueba con y sin)
                    // height: 0.8, // Puedes probar este ajuste en lugar del Transform
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetsSection(GameState gameState) {
    return Card(
      elevation: 1,
      color: const Color.fromARGB(255, 37, 37, 37),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 40),
            // Team 1 sets
            Text(
              gameState.team1Sets.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSizes.fontSizeSets + 2, // Se actualiza aquí
                fontWeight: FontWeight.w500,
                fontFamily: 'Leds',
              ),
            ),
            Text(
              'SETS GANADOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontFamily: 'Leds',
                letterSpacing: 2,
              ),
            ),
            // Team 2 sets
            Text(
              gameState.team2Sets.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSizes.fontSizeSets + 2, // Se actualiza aquí
                fontFamily: 'Leds',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  void _showDialogExit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, localSetState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Tablero Digital',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              content: Column(
                children: [
                  Text(
                    "¿Está seguro de salir?",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  style:
                      TextButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(40, 40),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.center,
                      ).copyWith(
                        foregroundColor:
                            WidgetStateProperty.resolveWith<Color?>((
                              Set<WidgetState> states,
                            ) {
                              if (states.contains(WidgetState.focused)) {
                                return Colors.red;
                              }
                              return Colors.white; // Defer to the default
                            }),
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>((
                              Set<WidgetState> states,
                            ) {
                              if (states.contains(WidgetState.focused)) {
                                return Colors.white;
                              }
                              return Colors.red; // Defer to the default
                            }),
                      ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('No', style: TextStyle(fontSize: 14)),
                ),
                const SizedBox(width: 20),
                TextButton(
                  style:
                      TextButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(40, 40),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.center,
                      ).copyWith(
                        foregroundColor:
                            WidgetStateProperty.resolveWith<Color?>((
                              Set<WidgetState> states,
                            ) {
                              if (states.contains(WidgetState.focused)) {
                                return Colors.green;
                              }
                              return Colors.white; // Defer to the default
                            }),
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>((
                              Set<WidgetState> states,
                            ) {
                              if (states.contains(WidgetState.focused)) {
                                return Colors.white;
                              }
                              return Colors.green; // Defer to the default
                            }),
                      ),
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: Text('Sí', style: TextStyle(fontSize: 14)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showConnectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Configuración de Servidor",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _serverController,
              style: const TextStyle(
                color: AppColors.neonGreen,
                fontFamily: 'Courier',
                fontSize: 18,
              ),
              decoration: const InputDecoration(
                labelText: 'IP / Host del Servidor',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accentBlue),
                ),
                prefixIcon: Icon(Icons.wifi, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 15),
            // Checkbox para HTTPS
            StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  children: [
                    Checkbox(
                      value: isHttps,
                      activeColor: AppColors.accentBlue,
                      checkColor: Colors.white,
                      onChanged: (val) => setState(() => isHttps = val ?? true),
                    ),
                    const Text(
                      "Usar HTTPS (Seguro)",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.link),
            label: const Text("CONECTAR"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final protocol = isHttps ? 'https' : 'http';
              final url = '$protocol://${_serverController.text.trim()}';

              TVSocketService.dispose();
              final gameState = Provider.of<GameState>(context, listen: false);
              TVSocketService.init(gameState, serverUrl: url);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Conectando a $url..."),
                  backgroundColor: AppColors.bgLight,
                ),
              );
              setState(() {}); // Actualizar icono de estado
            },
          ),
        ],
      ),
    );
  }

  void _connectToServer() async {
    String serverUrl = _serverController.text.trim();
    if (serverUrl.isNotEmpty) {
      TVSocketService.dispose();
      final gameState = Provider.of<GameState>(context, listen: false);
      TVSocketService.init(gameState, serverUrl: 'http://$serverUrl');
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Conectando a $serverUrl"),
          duration: const Duration(seconds: 2),
        ),
      );
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
