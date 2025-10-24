
import 'package:flutter/material.dart';

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