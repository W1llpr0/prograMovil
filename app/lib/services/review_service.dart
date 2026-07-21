import 'package:supabase_flutter/supabase_flutter.dart';

import '../configs/generic_response.dart';
import '../models/review.dart';

class ReviewService {
  final SupabaseClient _sb;

  ReviewService({SupabaseClient? client})
      : _sb = client ?? Supabase.instance.client;

  Future<GenericResponse<Review>> submit({
    required int consultationId,
    required int rating,
    String? comment,
  }) async {
    try {
      final payload = await _sb.rpc('submit_review', params: {
        'p_consultation_id': consultationId,
        'p_rating': rating,
        'p_comment': comment,
      });
      return GenericResponse<Review>.fromRpc(payload, decode: Review.fromJson);
    } catch (error) {
      return GenericResponse(
        success: false,
        code: 'REVIEW_ERROR',
        message: 'No se pudo guardar la reseña.',
        error: error.toString(),
      );
    }
  }

  Future<GenericResponse<Review?>> fetchForConsultation(int id) async {
    try {
      final row = await _sb
          .from('reviews')
          .select()
          .eq('consultation_id', id)
          .maybeSingle();
      return GenericResponse(
        success: true,
        data: row == null ? null : Review.fromJson(row),
      );
    } catch (error) {
      return GenericResponse(
        success: false,
        code: 'REVIEW_FETCH_ERROR',
        message: 'No se pudo cargar la reseña.',
        error: error.toString(),
      );
    }
  }

  Future<GenericResponse<List<Review>>> fetchMine() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) {
      return const GenericResponse(
        success: false,
        code: 'UNAUTHENTICATED',
        message: 'Debes iniciar sesión.',
      );
    }
    try {
      final rows = await _sb.from('reviews').select('''
            *,
            consultations!inner(
              scheduled_at,
              diagnosis,
              pets!inner(name),
              specialties(name)
            )
          ''').eq('client_id', uid).order('created_at', ascending: false);
      return GenericResponse(
        success: true,
        data: (rows as List)
            .map(
                (row) => Review.fromJson(Map<String, dynamic>.from(row as Map)))
            .toList(),
      );
    } catch (error) {
      return GenericResponse(
        success: false,
        code: 'REVIEWS_ERROR',
        message: 'No se pudieron cargar las reseñas.',
        error: error.toString(),
      );
    }
  }
}
