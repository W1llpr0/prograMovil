import 'package:flutter_test/flutter_test.dart';
import 'package:vetcare_app/models/app_user.dart';
import 'package:vetcare_app/models/consultation.dart';
import 'package:vetcare_app/models/medication.dart';
import 'package:vetcare_app/models/pet.dart';
import 'package:vetcare_app/models/review.dart';

void main() {
  test('AppUser keeps veterinarian joined fields', () {
    final user = AppUser.fromJson({
      'id': 'user-1',
      'email': 'vet@vetcare.pe',
      'first_name': 'Rodrigo',
      'last_name': 'Paz',
      'role': 'veterinarian',
      'veterinarians': [
        {'license_number': '45892', 'years_experience': 15}
      ]
    });

    expect(user.fullName, 'Rodrigo Paz');
    expect(user.licenseNumber, '45892');
    expect(user.yearsExperience, 15);
    expect(user.copyWith(phone: '999').licenseNumber, '45892');
  });

  test('Consultation decodes all joined UI data', () {
    final consultation = Consultation.fromJson({
      'id': 10,
      'pet_id': 3,
      'veterinarian_id': 'vet-1',
      'specialty_id': 1,
      'scheduled_at': '2026-10-18T15:30:00Z',
      'status': 'completed',
      'diagnosis': 'Otitis externa',
      'treatment': 'Gotas cada 8 horas',
      'vitals': {'weight_kg': 25.5},
      'specialties': {'name': 'Medicina General'},
      'veterinarians': {
        'users': {'first_name': 'Rodrigo', 'last_name': 'Paz'}
      },
      'pets': {
        'name': 'Max',
        'sex_code': 'M',
        'weight_kg': 25.5,
        'allergies': null,
        'breeds': {'name': 'Golden Retriever'},
        'users': {'first_name': 'Diego', 'last_name': 'Martínez'}
      }
    });

    expect(consultation.petName, 'Max');
    expect(consultation.petBreed, 'Golden Retriever');
    expect(consultation.ownerName, 'Diego Martínez');
    expect(consultation.vetName, 'Rodrigo Paz');
    expect(consultation.specialtyName, 'Medicina General');
    expect(consultation.petWeightKg, 25.5);
  });

  test('Pet age handles birthdays that have not occurred this year', () {
    final now = DateTime.now();
    final pet = Pet(
      clientId: 'user-1',
      name: 'Luna',
      speciesId: 2,
      birthDate: DateTime(now.year - 2, now.month, now.day)
          .add(const Duration(days: 1)),
    );
    expect(pet.ageYears, 1);
  });

  test('Medication schedule decodes the due time used by the dose UI', () {
    final schedule = MedicationSchedule.fromJson({
      'id': 7,
      'consultation_id': 10,
      'medication_name': 'Amoxicilina',
      'frequency_hours': 8,
      'start_date': '2026-07-20',
      'next_dose_at': '2026-07-21T15:30:00Z',
      'is_active': true,
    });

    expect(schedule.frequencyHours, 8);
    expect(schedule.nextDoseAt, DateTime.utc(2026, 7, 21, 15, 30));
  });

  test('Review keeps the clinical consultation context shown in profile', () {
    final review = Review.fromJson({
      'id': 4,
      'consultation_id': 10,
      'client_id': 'client-1',
      'veterinarian_id': 'vet-1',
      'rating': 5,
      'comment': 'Muy buena atención',
      'created_at': '2026-07-21T16:00:00Z',
      'consultations': {
        'scheduled_at': '2026-07-21T15:00:00Z',
        'diagnosis': 'Otitis externa',
        'pets': {'name': 'Luna'},
        'specialties': {'name': 'Medicina general'},
      },
    });

    expect(review.petName, 'Luna');
    expect(review.specialtyName, 'Medicina general');
    expect(review.diagnosis, 'Otitis externa');
    expect(review.consultationDate, DateTime.utc(2026, 7, 21, 15));
  });
}
