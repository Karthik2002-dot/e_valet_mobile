import 'package:equatable/equatable.dart';

class QrState extends Equatable {
  final bool isOnline;
  final bool isOnBreak;
  final bool isLoading;
  final String? message;

  const QrState({
    required this.isOnline,
    required this.isOnBreak,
    this.isLoading = false,
    this.message,
  });

  factory QrState.initial() {
    return const QrState(
      isOnline: true,
      isOnBreak: false,
      isLoading: false,
      message: null,
    );
  }

  QrState copyWith({
    bool? isOnline,
    bool? isOnBreak,
    bool? isLoading,
    String? message,
    bool clearMessage = false,
  }) {
    return QrState(
      isOnline: isOnline ?? this.isOnline,
      isOnBreak: isOnBreak ?? this.isOnBreak,
      isLoading: isLoading ?? this.isLoading,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [isOnline, isOnBreak, isLoading, message];
}
