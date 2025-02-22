class ThemeSettings {
  final String name;
  final String primaryColor;
  final String secondaryColor;
  final String backgroundColor;
  final bool isDark;

  ThemeSettings({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    this.isDark = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'backgroundColor': backgroundColor,
      'isDark': isDark,
    };
  }

  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      name: json['name'] as String,
      primaryColor: json['primaryColor'] as String,
      secondaryColor: json['secondaryColor'] as String,
      backgroundColor: json['backgroundColor'] as String,
      isDark: json['isDark'] as bool,
    );
  }

  ThemeSettings copyWith({
    String? name,
    String? primaryColor,
    String? secondaryColor,
    String? backgroundColor,
    bool? isDark,
  }) {
    return ThemeSettings(
      name: name ?? this.name,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isDark: isDark ?? this.isDark,
    );
  }
}
