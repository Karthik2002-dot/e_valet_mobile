import 'package:equatable/equatable.dart';

abstract class ScannerMenuEvent extends Equatable {
  const ScannerMenuEvent();

  @override
  List<Object?> get props => [];
}

class ScannerLogoutPressed extends ScannerMenuEvent {
  const ScannerLogoutPressed();
}

class ScannerProfilePressed extends ScannerMenuEvent {
  const ScannerProfilePressed();
}

class ScannerMenuReset extends ScannerMenuEvent {
  const ScannerMenuReset();
}
