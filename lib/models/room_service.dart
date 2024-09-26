class RoomService {
  String id;
  String name;
  int price;

  RoomService({required this.id, required this.name, required this.price});

  // Factory method to create a RoomService from a Map
  factory RoomService.fromJson(String id, Map<dynamic, dynamic> json) {
    return RoomService(
      id: id,
      name: json['name'] as String,
      price: json['price'] as int,
    );
  }

  

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
}
