import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/line_input.dart';
import '../../components/monochrome_button.dart';
import '../../components/vc_widgets.dart';
import 'book_appointment_controller.dart';

class BookAppointmentPage extends StatelessWidget {
  BookAppointmentPage({super.key});

  final BookAppointmentController ctrl = Get.put(BookAppointmentController());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('book_appointment'.tr),
        leading: IconButton(icon: Icon(Icons.close, color: cs.onSurface), onPressed: () => Get.back()),
      ),
      body: SafeArea(
        child: Obx(() => Column(
              children: [
                // Step indicator
                _StepIndicator(current: ctrl.currentStep.value, cs: cs),
                // Step body
                Expanded(child: _StepBody(ctrl: ctrl, cs: cs)),
                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: _NavButtons(ctrl: ctrl),
                ),
              ],
            )),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final ColorScheme cs;
  const _StepIndicator({required this.current, required this.cs});

  @override
  Widget build(BuildContext context) {
    const steps = ['VET', 'DATE', 'TIME', 'CONFIRM'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: List.generate(steps.length, (i) {
          final active = i <= current;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 2,
                        color: active ? cs.onSurface : cs.onSurface.withValues(alpha: 0.15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        steps[i],
                        style: TextStyle(
                          fontSize: 8,
                          letterSpacing: 0.22,
                          fontWeight: FontWeight.w700,
                          color: active ? cs.onSurface : cs.onSurface.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < steps.length - 1) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  final BookAppointmentController ctrl;
  final ColorScheme cs;
  const _StepBody({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (ctrl.currentStep.value) {
        case 0:
          return _SelectVet(ctrl: ctrl, cs: cs);
        case 1:
          return _SelectDate(ctrl: ctrl, cs: cs);
        case 2:
          return _SelectTime(ctrl: ctrl, cs: cs);
        case 3:
          return _Confirm(ctrl: ctrl, cs: cs);
        default:
          return const SizedBox.shrink();
      }
    });
  }
}

class _SelectVet extends StatelessWidget {
  final BookAppointmentController ctrl;
  final ColorScheme cs;
  const _SelectVet({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('SELECT VETERINARIAN', style: TextStyle(fontSize: 9, letterSpacing: 0.32, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.45))),
            const SizedBox(height: 16),
            ...ctrl.vets.map((vet) {
              final selected = ctrl.selectedVet.value?.id == vet.id;
              return GestureDetector(
                onTap: () => ctrl.selectedVet.value = vet,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected ? cs.onSurface : Colors.transparent,
                    border: Border.all(color: selected ? cs.onSurface : cs.onSurface.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Text(
                    'Dr. ${vet.fullName}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected ? cs.surface : cs.onSurface,
                    ),
                  ),
                ),
              );
            }),
          ],
        ));
  }
}

class _SelectDate extends StatelessWidget {
  final BookAppointmentController ctrl;
  final ColorScheme cs;
  const _SelectDate({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('SELECT DATE', style: TextStyle(fontSize: 9, letterSpacing: 0.32, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.45))),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => ctrl.pickDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(border: Border.all(color: cs.onSurface, width: 1)),
                    child: Text(
                      ctrl.selectedDate.value != null
                          ? '${ctrl.selectedDate.value!.day.toString().padLeft(2, '0')} / ${ctrl.selectedDate.value!.month.toString().padLeft(2, '0')} / ${ctrl.selectedDate.value!.year}'
                          : 'TAP TO SELECT',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: ctrl.selectedDate.value != null ? 24 : 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: ctrl.selectedDate.value != null ? -0.03 : 0.22,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class _SelectTime extends StatelessWidget {
  final BookAppointmentController ctrl;
  final ColorScheme cs;
  const _SelectTime({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('SELECT TIME', style: TextStyle(fontSize: 9, letterSpacing: 0.32, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.45))),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => ctrl.pickTime(context),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(border: Border.all(color: cs.onSurface, width: 1)),
                    child: Text(
                      ctrl.selectedTime.value != null
                          ? ctrl.selectedTime.value!.format(context)
                          : 'TAP TO SELECT',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: ctrl.selectedTime.value != null ? 28 : 13,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class _Confirm extends StatelessWidget {
  final BookAppointmentController ctrl;
  final ColorScheme cs;
  const _Confirm({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CONFIRM APPOINTMENT', style: TextStyle(fontSize: 9, letterSpacing: 0.32, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.45))),
              const SizedBox(height: 16),
              if (ctrl.pet.value != null) VcDataRow(label: 'Pet', value: ctrl.pet.value!.name),
              if (ctrl.selectedVet.value != null) VcDataRow(label: 'Veterinarian', value: 'Dr. ${ctrl.selectedVet.value!.fullName}'),
              if (ctrl.selectedDate.value != null)
                VcDataRow(label: 'Date', value: '${ctrl.selectedDate.value!.day}/${ctrl.selectedDate.value!.month}/${ctrl.selectedDate.value!.year}'),
              if (ctrl.selectedTime.value != null)
                VcDataRow(label: 'Time', value: ctrl.selectedTime.value!.format(context)),
              const SizedBox(height: 20),
              LineInput(controller: ctrl.reasonCtrl, label: 'REASON (optional)', maxLines: 3),
              if (ctrl.message.value.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(ctrl.message.value, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.7))),
              ],
            ],
          ),
        ));
  }
}

class _NavButtons extends StatelessWidget {
  final BookAppointmentController ctrl;
  const _NavButtons({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            if (ctrl.currentStep.value > 0) ...[
              Expanded(
                child: MonochromeButton(
                  label: 'BACK',
                  onPressed: ctrl.prevStep,
                  filled: false,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ctrl.currentStep.value < 3
                  ? MonochromeButton(label: 'NEXT', onPressed: ctrl.nextStep)
                  : MonochromeButton(
                      label: 'confirm'.tr,
                      onPressed: ctrl.book,
                      isLoading: ctrl.isLoading.value,
                    ),
            ),
          ],
        ));
  }
}
