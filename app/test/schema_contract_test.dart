import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Supabase migrations expose every app table and workflow RPC', () {
    final root = Directory.current.parent.path;
    final baseline = File(
      '$root/supabase/migrations/20260520000000_vetcare_baseline.sql',
    ).readAsStringSync();
    final workflows = File(
      '$root/supabase/migrations/20260720000000_complete_workflows.sql',
    ).readAsStringSync();
    final preferences = File(
      '$root/supabase/migrations/20260723000000_user_preferences.sql',
    ).readAsStringSync();

    for (final table in [
      'users',
      'clients',
      'veterinarians',
      'specialties',
      'veterinarian_specialties',
      'veterinarian_availability',
      'species',
      'breeds',
      'pets',
      'consultations',
      'consultation_documents',
      'medication_schedules',
      'treatment_adherence',
      'epidemiological_alerts',
      'morphological_records',
      'legal_documents',
      'reviews',
    ]) {
      expect(baseline, contains('public.$table'), reason: 'missing $table');
    }

    for (final rpc in [
      'book_consultation',
      'start_consultation',
      'complete_consultation',
      'submit_review',
      'available_slots',
    ]) {
      expect(workflows, contains('function public.$rpc'),
          reason: 'missing $rpc');
    }

    expect(preferences, contains('public.user_preferences'));
    expect(preferences, contains('user_preferences_select_own'));
    expect(preferences, contains('user_id = auth.uid()'));
  });

  test('Supabase contract hides internal errors and restricts privileged RPCs',
      () {
    final root = Directory.current.parent.path;
    final workflows = File(
      '$root/supabase/migrations/20260720000000_complete_workflows.sql',
    ).readAsStringSync();
    final hardening = File(
      '$root/supabase/migrations/20260721000000_security_hardening.sql',
    ).readAsStringSync();
    final roleHardening = File(
      '$root/supabase/migrations/20260721100000_auth_role_hardening.sql',
    ).readAsStringSync();
    final extensionFix = File(
      '$root/supabase/migrations/20260721200000_complete_function_extension_fix.sql',
    ).readAsStringSync();
    final storageHardening = File(
      '$root/supabase/migrations/20260721300000_storage_upsert_policies.sql',
    ).readAsStringSync();
    final deleteCascades = File(
      '$root/supabase/migrations/20260721400000_auth_user_delete_cascades.sql',
    ).readAsStringSync();
    final storageDelete = File(
      '$root/supabase/migrations/20260721500000_consultation_storage_delete.sql',
    ).readAsStringSync();
    final medicationDose = File(
      '$root/supabase/migrations/20260721600000_medication_dose_rpc.sql',
    ).readAsStringSync();
    final adherenceHardening = File(
      '$root/supabase/migrations/20260721700000_adherence_write_hardening.sql',
    ).readAsStringSync();

    expect(workflows.toLowerCase(), isNot(contains('sqlerrm')));
    expect(hardening, contains('veterinarian_can_access_pet'));
    expect(hardening, contains('revoke execute on function'));
    expect(hardening, contains('from public, anon'));
    expect(roleHardening, contains('after insert on auth.users'));
    expect(roleHardening, isNot(contains('after insert or update')));
    expect(roleHardening, contains('revoke update on public.users'));
    expect(roleHardening,
        contains('revoke insert, delete on public.consultations'));
    expect(extensionFix, contains('set search_path = public, extensions'));
    expect(storageHardening, contains('baseline_storage_profiles_select_own'));
    expect(storageHardening, contains('baseline_storage_pet_select_own'));
    expect(deleteCascades, contains('treatment_adherence_created_by_fkey'));
    expect(deleteCascades, contains('on delete cascade'));
    expect(storageDelete, contains('for delete'));
    expect(storageDelete, contains('consultation-docs'));
    expect(storageDelete, contains('can_access_consultation'));
    expect(medicationDose, contains('function public.record_medication_dose'));
    expect(medicationDose, contains('for update'));
    expect(medicationDose, contains('uq_adherence_schedule_scheduled_for'));
    expect(medicationDose, contains('public.owns_pet'));
    expect(medicationDose, contains('DOSE_TOO_EARLY'));
    expect(medicationDose, contains('revoke execute on function'));
    expect(
        adherenceHardening,
        contains(
            'revoke insert, update, delete on public.treatment_adherence'));
    expect(adherenceHardening,
        contains('grant select on public.treatment_adherence'));
  });
}
