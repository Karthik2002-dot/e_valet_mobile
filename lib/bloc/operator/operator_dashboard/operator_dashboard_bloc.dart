import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/operator/operator_dashboard_api_service.dart';
import 'package:niloufer_valet_mobile/api/operator/operator_available_drivers_api_service.dart';
import 'operator_dashboard_event.dart';
import 'operator_dashboard_state.dart';

class OperatorDashboardBloc
    extends Bloc<OperatorDashboardEvent, OperatorDashboardState> {
  OperatorDashboardBloc() : super(const OperatorDashboardInitial()) {
    on<FetchDashboardKpis>(_onFetchDashboardKpis);
  }

  Future<void> _onFetchDashboardKpis(
    FetchDashboardKpis event,
    Emitter<OperatorDashboardState> emit,
  ) async {
    emit(const OperatorDashboardLoading());
    try {
      // Fetch both KPIs and available drivers in parallel
      final results = await Future.wait([
        OperatorDashboardApiService.getDashboardKpis(
          outletId: event.outletId,
        ),
        OperatorAvailableDriversApiService.getAvailableDrivers(
          outletId: event.outletId,
        ),
      ]);

      final kpis = results[0] as dynamic;
      final availableDrivers = results[1] as dynamic;

      emit(OperatorDashboardLoaded(
        kpis: kpis,
        availableDrivers: availableDrivers,
      ));
    } catch (e) {
      emit(OperatorDashboardError(e.toString()));
    }
  }
}
