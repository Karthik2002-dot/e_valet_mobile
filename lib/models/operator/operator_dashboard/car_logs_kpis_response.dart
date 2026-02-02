class CarLogsKpisResponse {
  final int totalCarsParked;
  final int carsInTransit;
  final int carsHandovered;
  final int carsInLot;

  CarLogsKpisResponse({
    required this.totalCarsParked,
    required this.carsInTransit,
    required this.carsHandovered,
    required this.carsInLot,
  });

  factory CarLogsKpisResponse.fromJson(Map<String, dynamic> json) {
    return CarLogsKpisResponse(
      totalCarsParked: (json['totalCarsParked'] as num?)?.toInt() ?? 0,
      carsInTransit: (json['carsInTransit'] as num?)?.toInt() ?? 0,
      carsHandovered: (json['carsHandovered'] as num?)?.toInt() ?? 0,
      carsInLot: (json['carsInLot'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCarsParked': totalCarsParked,
      'carsInTransit': carsInTransit,
      'carsHandovered': carsHandovered,
      'carsInLot': carsInLot,
    };
  }
}
