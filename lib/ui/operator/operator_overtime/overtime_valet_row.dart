import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:niloufer_valet_mobile/services/translations/app_translations_notifier.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/utils/valet_utils.dart';

/// Single valet row for the overtime screen: name, phone, status, minutes input, and submit.
class OvertimeValetRow extends StatefulWidget {
  final String name;
  final String phone;
  final String status;
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  const OvertimeValetRow({
    super.key,
    required this.name,
    required this.phone,
    required this.status,
    required this.value,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  State<OvertimeValetRow> createState() => _OvertimeValetRowState();
}

class _OvertimeValetRowState extends State<OvertimeValetRow> {
  late TextEditingController _controller;

  void _applyDelta(int delta) {
    final currentRaw = _controller.text.trim();
    final current = int.tryParse(currentRaw) ?? 0;
    final next = (current + delta);
    final clamped = next < 0 ? 0 : next;
    final nextText = clamped.toString();

    _controller.value = _controller.value.copyWith(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
      composing: TextRange.empty,
    );
    widget.onChanged(nextText);
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(OvertimeValetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTranslationsNotifier>();
    final screenWidth = MediaQuery.of(context).size.width;
    final nameFontSize = (screenWidth * 0.04).clamp(16.0, 20.0);
    final phoneFontSize = (screenWidth * 0.032).clamp(14.0, 18.0);
    final statusColor = ValetUtils.getStatusColor(widget.status);
    final statusLabel = ValetUtils.getStatusLabel(widget.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextComponent(
                      labelText: widget.name,
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    TextComponent(
                      labelText: widget.phone,
                      fontSize: phoneFontSize,
                      color: AppColors.grey,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: statusColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: TextComponent(
                  labelText: statusLabel,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              const stepperWidth = 42.0;
              const gapAfterInput = 6.0;
              const gapBeforeButton = 8.0;
              const submitMinWidth = 110.0;

              final availableForInput = constraints.maxWidth -
                  stepperWidth -
                  gapAfterInput -
                  gapBeforeButton -
                  submitMinWidth;

              final inputWidth = availableForInput.clamp(140.0, 260.0);
              return Row(
                children: [
                  SizedBox(
                    width: inputWidth,
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: t.getByKey('overtimeInputHint',
                            TextConstants.overtimeInputHint),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onChanged: widget.onChanged,
                      onSubmitted: (_) => widget.onSubmit(),
                    ),
                  ),
                  const SizedBox(width: gapAfterInput),
                  Container(
                    width: 42,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.grey.withOpacity(0.4)),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: IconButton(
                            icon: const Icon(Icons.keyboard_arrow_up),
                            onPressed: () => _applyDelta(1),
                            splashRadius: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(
                              width: 42,
                              height: 23,
                            ),
                          ),
                        ),
                        Container(
                          height: 1,
                          color: AppColors.grey.withOpacity(0.25),
                        ),
                        Expanded(
                          child: IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down),
                            onPressed: () => _applyDelta(-1),
                            splashRadius: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(
                              width: 42,
                              height: 23,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: submitMinWidth,
                    child: ElevatedButton(
                      onPressed: widget.onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: TextComponent(
                        labelText: t.getByKey(
                            'submitButton', TextConstants.submitButton),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
