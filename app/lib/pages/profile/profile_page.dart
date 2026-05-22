import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../configs/app_routes.dart';
import 'profile_controller.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ProfileController ctrl = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final bg = Theme.of(context).colorScheme.surface;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PROFILE', style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: fg)),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.settings),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(border: Border.all(color: fg), borderRadius: BorderRadius.circular(999)),
                      child: Icon(Icons.settings, size: 18, color: fg),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Obx(() {
                  final u = ctrl.appCtrl.currentUser.value;
                  final firstName = u?.firstName ?? 'User';
                  final initials = u != null ? '${u.firstName[0]}${u.lastName[0]}'.toUpperCase() : 'MF';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Avatar + name header ─────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 96, height: 96,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: fg),
                                    borderRadius: BorderRadius.circular(999),
                                    color: fg.withValues(alpha: 0.06),
                                  ),
                                  child: u?.profilePicture != null && u!.profilePicture!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(999),
                                          child: Image.network(u.profilePicture!, fit: BoxFit.cover),
                                        )
                                      : Center(
                                          child: Text(initials,
                                              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 38,
                                                  letterSpacing: -0.04 * 38, color: fg)),
                                        ),
                                ),
                                Positioned(
                                  bottom: 2, right: 2,
                                  child: GestureDetector(
                                    onTap: ctrl.pickPhoto,
                                    child: Container(
                                      width: 26, height: 26,
                                      decoration: BoxDecoration(
                                        color: bg,
                                        border: Border.all(color: fg),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Icon(Icons.add, size: 14, color: fg),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Client',
                                      style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18,
                                          color: fg.withValues(alpha: 0.55))),
                                  const SizedBox(height: 6),
                                  Text('$firstName.',
                                      style: GoogleFonts.spaceGrotesk(fontSize: 30, fontWeight: FontWeight.w700,
                                          letterSpacing: -0.04 * 30, color: fg)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),



                      // ── Contact info ───────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
                        child: Text('CONTACT INFORMATION',
                            style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: fg)),
                      ),
                      _InfoRow(
                        label: 'FULL NAME',
                        fieldName: 'firstName',
                        value: '${u?.firstName ?? ''} ${u?.lastName ?? ''}',
                        onEdit: (val) {
                          if (val.contains(' ')) {
                            final parts = val.split(' ');
                            ctrl.updateUserField('firstName', parts[0]);
                            if (parts.length > 1) {
                              ctrl.updateUserField('lastName', parts.skip(1).join(' '));
                            }
                          } else {
                            ctrl.updateUserField('firstName', val);
                          }
                        },
                      ),
                      _InfoRow(
                        label: 'EMAIL',
                        fieldName: 'email',
                        value: u?.email ?? '',
                        onEdit: (val) => Get.snackbar('Info', 'Email cannot be changed here', snackPosition: SnackPosition.BOTTOM),
                      ),
                      _InfoRow(
                        label: 'PHONE',
                        fieldName: 'phone',
                        value: u?.phone ?? '',
                        onEdit: (val) => ctrl.updateUserField('phone', val),
                      ),
                      _InfoRow(
                        label: 'DOCUMENT',
                        fieldName: 'document',
                        value: u?.document ?? '',
                        onEdit: (val) => ctrl.updateUserField('document', val),
                      ),
                      _InfoRow(
                        label: 'ADDRESS',
                        fieldName: 'address',
                        value: u?.address ?? '',
                        onEdit: (val) => ctrl.updateUserField('address', val),
                        isLast: true,
                      ),

                      // ── Preferences ───────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
                        child: Text('PREFERENCES',
                            style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.18, color: fg)),
                      ),
                      Obx(() => _ToggleRow(title: 'Push notifications', value: ctrl.pushNotifs.value, onTap: () => ctrl.pushNotifs.toggle())),
                      Obx(() => _ToggleRow(title: 'Geofence alerts', value: ctrl.geofenceAlerts.value, onTap: () => ctrl.geofenceAlerts.toggle())),
                      Obx(() => _ToggleRow(title: 'Ledger broadcasts', value: ctrl.ledgerBroadcasts.value, onTap: () => ctrl.ledgerBroadcasts.toggle(), isLast: true)),

                      // ── Sign out ──────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: ctrl.signOut,
                            child: Text('SIGN OUT', style: GoogleFonts.jetBrainsMono(fontSize: 11, letterSpacing: 0.26)),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatefulWidget {
  final String label, fieldName, value;
  final bool isLast;
  final Function(String) onEdit;

  const _InfoRow({
    required this.label,
    required this.fieldName,
    required this.value,
    required this.onEdit,
    this.isLast = false,
  });

  @override
  State<_InfoRow> createState() => _InfoRowState();
}

class _InfoRowState extends State<_InfoRow> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final fg = Theme.of(ctx).colorScheme.onSurface;
        final bg = Theme.of(ctx).colorScheme.surface;
        return AlertDialog(
          backgroundColor: bg,
          title: Text('Edit ${widget.label}', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, color: fg)),
          content: TextField(
            controller: _controller,
            style: TextStyle(color: fg),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide(color: fg)),
              hintText: 'Add ${widget.label.toLowerCase()}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('CANCEL', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: fg)),
            ),
            TextButton(
              onPressed: () {
                widget.onEdit(_controller.text);
                Navigator.pop(ctx);
              },
              child: Text('SAVE', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: fg)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: fg),
          bottom: widget.isLast ? BorderSide(color: fg) : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.label,
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 9, letterSpacing: 0.16, color: fg.withValues(alpha: 0.55))),
                const SizedBox(height: 4),
                Text(widget.value,
                    style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w500, color: fg)),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showEditDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(border: Border.all(color: fg), borderRadius: BorderRadius.circular(999)),
              child: Text('EDIT', style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.16, color: fg)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final bool value;
  final VoidCallback onTap;
  final bool isLast;
  const _ToggleRow({required this.title, required this.value, required this.onTap, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final bg = Theme.of(context).colorScheme.surface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: fg),
            bottom: isLast ? BorderSide(color: fg) : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Expanded(child: Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w500, color: fg))),
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              width: 50, height: 28,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: value ? fg : bg,
                border: Border.all(color: fg),
                borderRadius: BorderRadius.circular(999),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: value ? bg : fg,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
