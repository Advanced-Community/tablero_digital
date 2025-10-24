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
      body: Consumer<GameState>(
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
                  child: */Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              overlayColor: WidgetStatePropertyAll<Color>(
                                Colors.white,
                              ),
                            ),
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
                                  overlayColor: WidgetStatePropertyAll<Color>(
                                    Colors.white,
                                  ),
                                  iconColor:
                                      WidgetStateProperty.resolveWith<Color?>((
                                        Set<WidgetState> states,
                                      ) {
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
                                  overlayColor: WidgetStatePropertyAll<Color>(
                                    Colors.white,
                                  ),
                                  iconColor:
                                      WidgetStateProperty.resolveWith<Color?>((
                                        Set<WidgetState> states,
                                      ) {
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
              SizedBox(height: 120),
              Container(
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Text(
                  gameState.isGameActive ? 'VS' : " l l ",
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 33,
                    fontFamily: 'Leds',
                    letterSpacing: 4,
                  ),
                ),
              ),

              SizedBox(height: 20),

              Text(
                'SET ${gameState.currentSet}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 33,
                  fontFamily: 'Leds',
                  letterSpacing: 2,
                ),
              ),
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
                    color: const Color.fromARGB(255, 50, 255, 50),
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
                color: Colors.green,
                fontSize: fontSizes.fontSizeSets, // Se actualiza aquí
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
                color: Colors.green,
                fontSize: fontSizes.fontSizeSets, // Se actualiza aquí
                fontFamily: 'Leds',
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
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, localSetState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Configurar Conexión',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              content: SizedBox(
                height: 100,
                width: 420,
                child: Column(
                  children: [
                    Focus(
                      autofocus: true,
                      onKeyEvent: (FocusNode node, KeyEvent event) {
                        print(
                          'Type: ${event.runtimeType}, Logical Key: ${event.logicalKey.debugName}, Character: ${event.character ?? 'N/A'}',
                        );

                        if (event.logicalKey.debugName == "Arrow Down" ||
                            event.logicalKey.debugName == "Arrow Up") {
                          node.nextFocus();
                        }

                        return KeyEventResult.handled; // Consume the event
                      },
                      child: SizedBox(
                        height: 100,
                        child: TextField(
                          inputFormatters: [
                            //Only numbers and dots
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.:0-9]'),
                            ),
                          ],
                          controller: _serverController,
                          style: TextStyle(color: Colors.white, fontSize: 30),
                          expands: true,
                          maxLines: null,
                          minLines: null,
                          keyboardType: TextInputType.url,
                          cursorColor: Colors.white,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            error: errorText != null
                                ? Text(
                                    errorText!,
                                    style: TextStyle(color: Colors.red),
                                  )
                                : null,
                            labelText: 'IP del servidor (ej: 192.168.1.1:5215)',
                            labelStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 30,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          //FocusScope.of(context).unfocus();
                          //onTap open keyboard
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          autofocus: true,
                          onChanged: (value) {
                            if (value.isEmpty ||
                                !RegExp(r'^[0-9.:]+$').hasMatch(value)) {
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
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Con HTTPS:",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        Checkbox(
                          value: isHttps,
                          activeColor: Colors.green,
                          overlayColor: WidgetStatePropertyAll<Color>(
                            Colors.white,
                          ),
                          checkColor: isHttps ? Colors.white : Colors.red,
                          onChanged: (value) {
                            localSetState(() {
                              isHttps = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
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
                                      if (states.contains(
                                        WidgetState.focused,
                                      )) {
                                        return Colors.red;
                                      }
                                      return Colors
                                          .white; // Defer to the default
                                    }),
                                backgroundColor:
                                    WidgetStateProperty.resolveWith<Color?>((
                                      Set<WidgetState> states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.focused,
                                      )) {
                                        return Colors.white;
                                      }
                                      return Colors.red; // Defer to the default
                                    }),
                              ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(fontSize: 14),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
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
                                      if (states.contains(
                                        WidgetState.focused,
                                      )) {
                                        return Colors.green;
                                      }
                                      return Colors
                                          .white; // Defer to the default
                                    }),
                                backgroundColor:
                                    WidgetStateProperty.resolveWith<Color?>((
                                      Set<WidgetState> states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.focused,
                                      )) {
                                        return Colors.white;
                                      }
                                      return Colors
                                          .green; // Defer to the default
                                    }),
                              ),
                          onPressed: _connectToServer,
                          child: Text(
                            'Conectar',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
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
