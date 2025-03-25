class BusStopModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;

  BusStopModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory BusStopModel.fromJson(Map<String, dynamic> json) {
    return BusStopModel(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
    );
  }
}
