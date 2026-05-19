import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/monochrome_button.dart';
import '../../components/vc_widgets.dart';
import 'profile_controller.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ProfileController ctrl = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: cs.onSurface), onPressed: () => Get.back()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info
              Obx(() {
                final user = ctrl.appCtrl.currentUser.value;
                if (user == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar circle
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          border: Border.all(color: cs.onSurface, width: 1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.03, color: cs.onSurface),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.55)),
                      ),
                      const SizedBox(height: 8),
                      MonoBadge(label: user.role),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 32),
              // Settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SETTINGS', style: TextStyle(fontSize: 9, letterSpacing: 0.32, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.45))),
                    const SizedBox(height: 12),
                    // Dark mode toggle
                    Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(border: Border.all(color: cs.onSurface.withValues(alpha: 0.15), width: 1)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('dark_mode'.tr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface)),
                              Switch(value: ctrl.appCtrl.isDark.value, onChanged: (_) => ctrl.toggleTheme()),
                            ],
                          ),
                        )),
                    const SizedBox(height: 8),
                    // Language toggle
                    Obx(() => GestureDetector(
                          onTap: ctrl.toggleLocale,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(border: Border.all(color: cs.onSurface.withValues(alpha: 0.15), width: 1)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('language'.tr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface)),
                                Text(
                                  ctrl.appCtrl.locale.value == 'en' ? 'EN → ES' : 'ES → EN',
                                  style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.1, color: cs.onSurface.withValues(alpha: 0.7)),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: MonochromeButton(label: 'logout'.tr, onPressed: ctrl.logout, filled: false),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
