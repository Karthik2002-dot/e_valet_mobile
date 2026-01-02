import 'package:equatable/equatable.dart';

abstract class PreviewCarEvent extends Equatable {
  const PreviewCarEvent();

  @override
  List<Object?> get props => [];
}

class SubmitPhotoRequested extends PreviewCarEvent {
  final String imagePath;
  final String? sessionId;

  const SubmitPhotoRequested(this.imagePath, {this.sessionId});

  @override
  List<Object?> get props => [imagePath, sessionId];
}

class ResetSubmission extends PreviewCarEvent {
  const ResetSubmission();
}
