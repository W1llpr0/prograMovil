import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_controller.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final SettingsController ctrl = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final bg = Theme.of(context).colorScheme.surface;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top nav ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(border: Border.all(color: fg), borderRadius: BorderRadius.circular(999)),
                      child: Icon(Icons.chevron_left, size: 18, color: fg),
                    ),
                  ),
                  Text('settings'.tr.toUpperCase(), style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: fg)),
                  const SizedBox(width: 38),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Language section
                    Text('language'.tr, style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18,
                        color: fg.withValues(alpha: 0.55))),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(text: 'Selecciona tu',
                            style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700,
                                letterSpacing: -0.04 * 24, height: 0.92, color: fg)),
                        TextSpan(text: ' idioma.',
                            style: GoogleFonts.instrumentSerif(fontSize: 22, fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400, letterSpacing: -0.02 * 22, height: 1.0, color: fg)),
                      ]),
                    ),

                    const SizedBox(height: 28),

                    // Language options
                    Obx(() => Column(
                      children: [
                        _LanguageOption(
                          label: 'Español',
                          selected: ctrl.appCtrl.locale.value == 'es',
                          onTap: () => ctrl.changeLanguage('es'),
                        ),
                        const SizedBox(height: 12),
                        _LanguageOption(
                          label: 'English',
                          selected: ctrl.appCtrl.locale.value == 'en',
                          onTap: () => ctrl.changeLanguage('en'),
                        ),
                      ],
                    )),

                    const SizedBox(height: 32),

                    // Theme section
                    Text('appearance'.tr, style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18,
                        color: fg.withValues(alpha: 0.55))),
                    const SizedBox(height: 12),
                    
                    Obx(() => GestureDetector(
                      onTap: () => ctrl.appCtrl.toggleTheme(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: fg),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(ctrl.appCtrl.isDark.value ? 'dark_mode'.tr : 'light_mode'.tr,
                                style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500, color: fg)),
                            Container(
                              width: 50, height: 28,
                              decoration: BoxDecoration(
                                color: ctrl.appCtrl.isDark.value ? fg : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Align(
                                alignment: ctrl.appCtrl.isDark.value ? Alignment.centerRight : Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Container(
                                    width: 22, height: 22,
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Builder(builder: (ctx) {
        final fg = Theme.of(ctx).colorScheme.onSurface;
        final bg = Theme.of(ctx).colorScheme.surface;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? fg : bg,
            border: Border.all(color: fg),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500,
                      color: selected ? bg : fg)),
              if (selected)
                Icon(Icons.check, color: bg, size: 20),
            ],
          ),
        );
      }),
    );
  }
}
