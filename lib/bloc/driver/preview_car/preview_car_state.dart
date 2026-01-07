import 'package:equatable/equatable.dart';

abstract class PreviewCarState extends Equatable {
  const PreviewCarState();

  @override
  List<Object?> get props => [];
}

class PreviewCarInitial extends PreviewCarState {
  const PreviewCarInitial();
}

class PreviewCarSubmitting extends PreviewCarState {
  const PreviewCarSubmitting();
}

class PreviewCarSuccess extends PreviewCarState {
  const PreviewCarSuccess();
}

class PreviewCarError extends PreviewCarState {
  final String message;

  const PreviewCarError({required this.message});

  @override
  List<Object?> get props => [message];
}
