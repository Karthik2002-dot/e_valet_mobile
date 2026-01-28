import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/operator/operator_dashboard/operator_car_logs_api_service.dart';
import 'car_logs_event.dart';
import 'car_logs_state.dart';

class CarLogsBloc extends Bloc<CarLogsEvent, CarLogsState> {
  CarLogsBloc() : super(const CarLogsInitial()) {
    on<FetchCarLogs>(_onFetchCarLogs);
  }

  Future<void> _onFetchCarLogs(
    FetchCarLogs event,
    Emitter<CarLogsState> emit,
  ) async {
    emit(const CarLogsLoading());
    try {
      final carLogs = await OperatorCarLogsApiService.getCarLogs(
        outletId: event.outletId,
        page: event.page,
        pageSize: event.pageSize,
      );
      emit(CarLogsLoaded(carLogsResponse: carLogs));
    } catch (e) {
      emit(CarLogsError(e.toString()));
    }
  }
}
