import 'package:equatable/equatable.dart';

class DriverCardInfo extends Equatable {
  final int cardId;
  final int cardNumber;
  final DateTime? assignedAt;

  const DriverCardInfo({
    required this.cardId,
    required this.cardNumber,
    required this.assignedAt,
  });

  factory DriverCardInfo.fromJson(Map<String, dynamic> json) {
    final assignedAtRaw = json['assignedAt']?.toString();
    final assignedAt = assignedAtRaw == null || assignedAtRaw.trim().isEmpty
        ? null
        : DateTime.tryParse(assignedAtRaw);
    return DriverCardInfo(
      cardId: json['cardId'] as int? ?? 0,
      cardNumber: json['cardNumber'] as int? ?? 0,
      assignedAt: assignedAt,
    );
  }

  @override
  List<Object?> get props => [cardId, cardNumber, assignedAt];
}

class MyCardsResponse extends Equatable {
  final int outletId;
  final String outletName;
  final List<DriverCardInfo> cards;

  const MyCardsResponse({
    required this.outletId,
    required this.outletName,
    required this.cards,
  });

  factory MyCardsResponse.fromJson(Map<String, dynamic> json) {
    final rawCards = json['cards'];
    final cards = rawCards is List
        ? rawCards
            .whereType<Map<String, dynamic>>()
            .map(DriverCardInfo.fromJson)
            .toList(growable: false)
        : const <DriverCardInfo>[];
    return MyCardsResponse(
      outletId: json['outletId'] as int? ?? 0,
      outletName: (json['outletName'] ?? '').toString(),
      cards: cards,
    );
  }

  @override
  List<Object?> get props => [outletId, outletName, cards];
}
