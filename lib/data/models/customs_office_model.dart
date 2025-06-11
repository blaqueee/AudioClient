class CustomsOfficeModel  {
  final int id;
  final String name;
  final String type;

  CustomsOfficeModel({
    required this.id,
    required this.name,
    required this.type
  });

  factory CustomsOfficeModel.fromJson(Map<String, dynamic> json) {
    return CustomsOfficeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }
}