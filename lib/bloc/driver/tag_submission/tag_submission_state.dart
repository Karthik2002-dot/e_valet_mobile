import 'package:equatable/equatable.dart';

abstract class TagSubmissionState extends Equatable {
  const TagSubmissionState();

  @override
  List<Object?> get props => [];
}

class TagSubmissionInitial extends TagSubmissionState {
  const TagSubmissionInitial();
}

class TagSubmissionLoading extends TagSubmissionState {
  const TagSubmissionLoading();
}

class TagSubmissionSuccess extends TagSubmissionState {
  final String message;

  const TagSubmissionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TagSubmissionError extends TagSubmissionState {
  final String message;

  const TagSubmissionError(this.message);

  @override
  List<Object?> get props => [message];
}

