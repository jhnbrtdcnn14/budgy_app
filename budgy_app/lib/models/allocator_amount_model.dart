class AllocatorAmount {
  final String name;
  final double amount;

  AllocatorAmount({
    required String name,
    required this.amount,
  }) : name = _capitalizeWords(name);

  AllocatorAmount copyWith({String? name, double? amount}) {
    return AllocatorAmount(
      name: name ?? this.name,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
      };

  factory AllocatorAmount.fromJson(Map<String, dynamic> json) {
    return AllocatorAmount(
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
    );
  }

  static String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) =>
            word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
