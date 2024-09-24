class RoomTypeClass {
  String id;
  String name;
  RoomTypeClass({
    required this.id,
    required this.name,
  });

  // Factory method to create a RoomTypeClass from a Map
  factory RoomTypeClass.fromJson(String id, Map<dynamic, dynamic> json) {
    return RoomTypeClass(
      id: id,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
