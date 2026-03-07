import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/operator/operator_dashboard/operator_manual_retrieval_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/scanner/scanner_qr/scanner_qr_event.dart';
import 'package:niloufer_valet_mobile/bloc/scanner/scanner_qr/scanner_qr_state.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/manual_retrieval_request.dart';
import 'package:niloufer_valet_mobile/utils/whatsapp_qr_parser.dart';

class ScannerQrBloc extends Bloc<ScannerQrEvent, ScannerQrState> {
  ScannerQrBloc() : super(const ScannerQrInitial()) {
    on<ScannerQrCodeDetected>(_onCodeDetected);
    on<ScannerQrReset>(_onReset);
  }

  static const String _invalidQrMessage =
      'Could not find card number in QR code. Please scan the WhatsApp QR from the valet card.';
  static const String _genericErrorMessage =
      'Failed to create retrieval request. Please try again.';

  Future<void> _onCodeDetected(
    ScannerQrCodeDetected event,
    Emitter<ScannerQrState> emit,
  ) async {
    if (state is ScannerQrProcessing) return;
    final raw = event.rawValue.trim();
    if (raw.isEmpty) return;

    final cardNumber = tryParseCardNumberFromWhatsAppUrl(raw);
    if (cardNumber == null) {
      emit(const ScannerQrInvalidQr(_invalidQrMessage));
      return;
    }

    emit(const ScannerQrProcessing());

    final outletId = dotenv.env['OUTLET_ID'] ?? '1';
    final apiService = OperatorManualRetrievalApiService();

    try {
      final request = ManualRetrievalRequest(cardNumber: cardNumber);
      final response = await apiService.createManualRetrievalRequest(
        outletId: outletId,
        request: request,
      );
      emit(ScannerQrSuccess(response.message));
    } on ApiException catch (e) {
      emit(ScannerQrError(e.message));
    } catch (_) {
      emit(const ScannerQrError(_genericErrorMessage));
    }
  }

  void _onReset(ScannerQrReset event, Emitter<ScannerQrState> emit) {
    emit(const ScannerQrInitial());
  }
}
