// File: extra_service.dart (assuming this is how your ExtraService model looks)
class ExtraService {
  final String id;
  final String name;
  final int price;
  bool isSelected;

  ExtraService({
    required this.id,
    required this.name,
    required this.price,
    this.isSelected = false,
  });

  factory ExtraService.fromJson(Map<dynamic, dynamic> json) {
    return ExtraService(
        id: json['id'], name: json["name"], price: json["price"]);
  }
}
