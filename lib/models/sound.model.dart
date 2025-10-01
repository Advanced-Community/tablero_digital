class Sound {
  final String name;
  final String type;

  Sound({required this.name, required this.type});

  factory Sound.fromJson(Map<String, dynamic> json) {
    return Sound(
      name: json['name'],
      type: json['type'],
    );
  }
}