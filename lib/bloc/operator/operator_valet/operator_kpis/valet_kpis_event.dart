abstract class ValetKpisEvent {
  const ValetKpisEvent();
}

class FetchValetKpis extends ValetKpisEvent {
  final String outletId;

  const FetchValetKpis({
    this.outletId = '2',
  });
}
