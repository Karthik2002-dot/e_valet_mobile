import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/parked_by.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/vehicle.dart';

class RetrievalRequest {
  final String sessionId;
  final int cardNumber;
  final String requestType;
  final bool isManualRequest;
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
    required this.isManualRequest,
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
      isManualRequest: json['isManualRequest'] ?? false,
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
      'isManualRequest': isManualRequest,
    };
  }
}
