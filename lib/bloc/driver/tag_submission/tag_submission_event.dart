import 'package:equatable/equatable.dart';

abstract class TagSubmissionEvent extends Equatable {
  const TagSubmissionEvent();

  @override
  List<Object?> get props => [];
}

class QrCodeSubmitted extends TagSubmissionEvent {
  final String qrCode;

  const QrCodeSubmitted(this.qrCode);

  @override
  List<Object?> get props => [qrCode];
}

class TagNumberSubmitted extends TagSubmissionEvent {
  final String tagNumber;

  const TagNumberSubmitted(this.tagNumber);

  @override
  List<Object?> get props => [tagNumber];
}

class TagSubmissionReset extends TagSubmissionEvent {
  const TagSubmissionReset();
}

