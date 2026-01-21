class Vehicle {
  final String photo;
  final String parkingLocation;

  Vehicle({required this.photo, required this.parkingLocation});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      photo: json['photo'] ?? '',
      parkingLocation: json['parkingLocation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photo': photo,
      'parkingLocation': parkingLocation,
    };
  }
}
