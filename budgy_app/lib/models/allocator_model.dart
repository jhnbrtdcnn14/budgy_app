class Allocator {
  final String name;
  final double percentage;

  Allocator({required String name, required this.percentage}) : name = _capitalizeWords(name);

  Allocator copyWith({String? name, double? percentage}) {
    return Allocator(
      name: name ?? this.name,
      percentage: percentage ?? this.percentage,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'percentage': percentage,
      };

  factory Allocator.fromJson(Map<String, dynamic> json) {
    return Allocator(
      name: json['name'],
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  static String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}').join(' ');
  }
}
