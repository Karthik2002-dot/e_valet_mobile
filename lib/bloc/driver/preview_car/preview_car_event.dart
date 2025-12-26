import 'package:equatable/equatable.dart';

abstract class PreviewCarEvent extends Equatable {
  const PreviewCarEvent();

  @override
  List<Object?> get props => [];
}

class SubmitPhotoRequested extends PreviewCarEvent {
  final String imagePath;

  const SubmitPhotoRequested(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class ResetSubmission extends PreviewCarEvent {
  const ResetSubmission();
}
