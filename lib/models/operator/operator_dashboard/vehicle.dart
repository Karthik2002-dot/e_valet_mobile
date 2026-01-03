class Vehicle {
  final String photo;

  Vehicle({required this.photo});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      photo: json['photo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photo': photo,
    };
  }
}
