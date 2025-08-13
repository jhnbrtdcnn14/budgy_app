class Allocator {
  final String name;
  final double value;

  Allocator({required String name, required this.value}) : name = _capitalizeWords(name);

  Allocator copyWith({String? name, double? value}) {
    return Allocator(
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
      };

  factory Allocator.fromJson(Map<String, dynamic> json) {
    return Allocator(
      name: json['name'],
      value: (json['value'] as num).toDouble(),
    );
  }

  static String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}').join(' ');
  }
}
