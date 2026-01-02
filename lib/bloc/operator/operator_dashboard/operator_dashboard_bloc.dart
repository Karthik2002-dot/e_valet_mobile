import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/operator/operator_dashboard_api_service.dart';
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
      final kpis = await OperatorDashboardApiService.getDashboardKpis(
        outletId: event.outletId,
      );
      emit(OperatorDashboardLoaded(kpis));
    } catch (e) {
      emit(OperatorDashboardError(e.toString()));
    }
  }
}
