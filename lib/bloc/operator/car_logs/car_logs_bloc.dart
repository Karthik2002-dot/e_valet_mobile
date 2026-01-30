import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:niloufer_valet_mobile/api/operator/operator_dashboard/operator_car_logs_api_service.dart';
import 'package:niloufer_valet_mobile/api/operator/operator_dashboard/operator_update_session_api_service.dart';
import 'car_logs_event.dart';
import 'car_logs_state.dart';

class CarLogsBloc extends Bloc<CarLogsEvent, CarLogsState> {
  CarLogsBloc() : super(const CarLogsInitial()) {
    on<FetchCarLogs>(_onFetchCarLogs);
    on<UpdateCarLogStatus>(_onUpdateCarLogStatus);
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

  Future<void> _onUpdateCarLogStatus(
    UpdateCarLogStatus event,
    Emitter<CarLogsState> emit,
  ) async {
    try {
      await OperatorUpdateSessionApiService.updateSessionStatus(
        sessionId: event.sessionId,
        newStatus: event.newStatus,
      );

      // After successful update, refresh the car logs
      if (state is CarLogsLoaded) {
        final currentState = state as CarLogsLoaded;
        add(FetchCarLogs(
          outletId: dotenv.env['OUTLET_ID']!,
          page: currentState.carLogsResponse.page,
          pageSize: currentState.carLogsResponse.pageSize,
        ));
      }
    } catch (e) {
      // For now, just print the error. You might want to emit an error state
      print('Error updating car log status: $e');
    }
  }
}
