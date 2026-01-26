import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/bloc/operator/car_logs/car_logs_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/car_logs/car_logs_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/car_logs/car_logs_state.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/car_log.dart';
import 'package:intl/intl.dart';

class OperatorCarLogsScreen extends StatefulWidget {
  const OperatorCarLogsScreen({super.key});

  @override
  State<OperatorCarLogsScreen> createState() => _OperatorCarLogsScreenState();
}

class _OperatorCarLogsScreenState extends State<OperatorCarLogsScreen> {
  late CarLogsBloc _carLogsBloc;
  final String _outletId = dotenv.env['OUTLET_ID'] ?? '1';

  @override
  void initState() {
    super.initState();
    _carLogsBloc = CarLogsBloc();
    _carLogsBloc.add(FetchCarLogs(
      outletId: _outletId,
      page: 0,
      pageSize: 10,
      search: '',
    ));
  }

  @override
  void dispose() {
    _carLogsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _carLogsBloc,
      child: SafeArea(
        child: BlocBuilder<CarLogsBloc, CarLogsState>(
          builder: (context, state) {
            if (state is CarLogsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is CarLogsLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextComponent(
                      labelText: TextConstants.carLogsTitle,
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 8),
                    TextComponent(
                      labelText: TextConstants.carLogsDescription,
                      color: AppColors.grey,
                    ),
                    const SizedBox(height: 16),
                    TextComponent(
                      labelText: 'Total Logs: ${state.carLogsResponse.total}',
                      color: AppColors.black,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 24),
                    if (state.carLogsResponse.logs.isEmpty)
                      Center(
                        child: TextComponent(
                          labelText: 'No car logs available',
                          color: AppColors.grey,
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.carLogsResponse.logs.length,
                        itemBuilder: (context, index) {
                          final log = state.carLogsResponse.logs[index];
                          return _buildCarLogCard(log);
                        },
                      ),
                  ],
                ),
              );
            } else if (state is CarLogsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextComponent(
                      labelText: 'Error loading car logs',
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 8),
                    TextComponent(
                      labelText: state.message,
                      color: AppColors.grey,
                      fontSize: 12,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _carLogsBloc.add(FetchCarLogs(
                          outletId: _outletId,
                          page: 0,
                          pageSize: 10,
                          search: '',
                        ));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCarLogCard(CarLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextComponent(
                  labelText: 'Tag #${log.tagNumber}',
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextComponent(
                    labelText: log.duration,
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Session ID', log.sessionId),
            const SizedBox(height: 8),
            _buildInfoRow('Parking Location', log.parkingLocation),
            const SizedBox(height: 8),
            _buildInfoRow('Parked At', _formatDateTime(log.parkedAt)),
            const SizedBox(height: 8),
            _buildInfoRow('Handovered At', _formatDateTime(log.handoveredAt)),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextComponent(
                        labelText: 'Parked By',
                        color: AppColors.grey,
                        fontSize: 12,
                      ),
                      const SizedBox(height: 4),
                      TextComponent(
                        labelText: log.parkedBy.name,
                        color: AppColors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      TextComponent(
                        labelText: log.parkedBy.phone,
                        color: AppColors.grey,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextComponent(
                        labelText: 'Handovered By',
                        color: AppColors.grey,
                        fontSize: 12,
                      ),
                      const SizedBox(height: 4),
                      TextComponent(
                        labelText: log.handoveredBy.name,
                        color: AppColors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: TextComponent(
            labelText: '$label:',
            color: AppColors.grey,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: TextComponent(
            labelText: value,
            color: AppColors.black,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }
}
