import 'package:equatable/equatable.dart';

abstract class PreviewCarEvent extends Equatable {
  const PreviewCarEvent();

  @override
  List<Object?> get props => [];
}

class SubmitPhotoRequested extends PreviewCarEvent {
  final String imagePath;
  final String? sessionId;
  final bool isReparking;

  const SubmitPhotoRequested(this.imagePath, {
    this.sessionId,
    this.isReparking = false,
  });

  @override
  List<Object?> get props => [imagePath, sessionId, isReparking];
}

class ResetSubmission extends PreviewCarEvent {
  const ResetSubmission();
}
