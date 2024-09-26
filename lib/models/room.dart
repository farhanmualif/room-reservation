class Room {
  final String? id;
  final String? name;
  final String? image;
  final String? description;
  final String? roomTypeId;
  final String? serviceId;
  final int? price;
  final bool? isAvailable;

  Room({
    this.id,
    this.name,
    this.image,
    this.description,
    this.roomTypeId,
    this.serviceId,
    this.price,
    this.isAvailable = true,
  });

  factory Room.fromJson(String id, Map<dynamic, dynamic> json) {
    return Room(
      id: id,
      description: json['description'] as String?,
      image: json['image'] as String?,
      isAvailable:
          json['is_available'] == null ? true : json['is_available'] as bool,
      name: json['name'] as String?,
      price: json['price'] as int?,
      roomTypeId: json['room_type_id'] as String?,
      serviceId: json['service_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'image': image,
      'is_available': isAvailable,
      'name': name,
      'price': price,
      'room_type_id': roomTypeId,
      'service_id': serviceId,
    };
  }
}

class RoomResponse {
  final String id;
  final String name;
  final String image;
  final String description;
  final String roomType;
  final String service;
  final int price;
  bool isAvailable;

  RoomResponse({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.roomType,
    required this.service,
    required this.price,
    this.isAvailable = true,
  });

  factory RoomResponse.fromJson(String id, Map<dynamic, dynamic> json) {
    return RoomResponse(
      id: id,
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      isAvailable: json['is_available'] as bool? ?? true,
      name: json['name'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      roomType: json['room_type'] as String? ?? '',
      service: json['service'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'image': image,
      'is_available': isAvailable,
      'name': name,
      'price': price,
      'room_type': roomType,
      'service': service,
    };
  }
}
