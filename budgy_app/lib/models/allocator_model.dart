class Allocator {
  final String name;
  final double percentage;

  Allocator({required this.name, required this.percentage});

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
}
