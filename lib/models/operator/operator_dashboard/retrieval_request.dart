class RetrievalRequest {
  final String sessionId;
  final int cardNumber;
  final String requestType;
  final String waitingTime;
  final String requestedAt;
  final Vehicle vehicle;
  final ParkedBy parkedBy;

  RetrievalRequest({
    required this.sessionId,
    required this.cardNumber,
    required this.requestType,
    required this.waitingTime,
    required this.requestedAt,
    required this.vehicle,
    required this.parkedBy,
  });

  factory RetrievalRequest.fromJson(Map<String, dynamic> json) {
    return RetrievalRequest(
      sessionId: json['sessionId'] ?? '',
      cardNumber: json['cardNumber'] ?? 0,
      requestType: json['requestType'] ?? '',
      waitingTime: json['waitingTime'] ?? '',
      requestedAt: json['requestedAt'] ?? '',
      vehicle: Vehicle.fromJson(json['vehicle'] ?? {}),
      parkedBy: ParkedBy.fromJson(json['parkedBy'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'cardNumber': cardNumber,
      'requestType': requestType,
      'waitingTime': waitingTime,
      'requestedAt': requestedAt,
      'vehicle': vehicle.toJson(),
      'parkedBy': parkedBy.toJson(),
    };
  }
}

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

class ParkedBy {
  final String name;
  final String? phone;

  ParkedBy({
    required this.name,
    this.phone,
  });

  factory ParkedBy.fromJson(Map<String, dynamic> json) {
    return ParkedBy(
      name: json['name'] ?? 'Unknown',
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (phone != null) 'phone': phone,
    };
  }
}
