import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ValetKpisEvent {
  const ValetKpisEvent();
}

class FetchValetKpis extends ValetKpisEvent {
  final String outletId;

  FetchValetKpis({
    String? outletId,
  }) : outletId = outletId ?? (dotenv.env['OUTLET_ID'] ?? '1');
}
