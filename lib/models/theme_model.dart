class GameThemeModel {
  final String title;
  final String cardSymbol;
  final List<String> symbols;
  final Map<String, double> cardColor;

  GameThemeModel({
    required this.title,
    required this.cardSymbol,
    required this.symbols,
    required this.cardColor,
  });

  factory GameThemeModel.fromJson(Map<String, dynamic> json) {
    return GameThemeModel(
      title: json['title'] ?? '',
      cardSymbol: json['card_symbol'] ?? '',
      symbols: List<String>.from(json['symbols'] ?? []),
      cardColor: Map<String, double>.from(json['card_color'] ?? {}),
    );
  }

  int get red => ((cardColor['red'] ?? 0) * 255).round();
  int get green => ((cardColor['green'] ?? 0) * 255).round();
  int get blue => ((cardColor['blue'] ?? 0) * 255).round();
}
