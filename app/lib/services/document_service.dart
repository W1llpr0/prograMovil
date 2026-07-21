import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../configs/generic_response.dart';
import '../configs/supabase_config.dart';
import '../models/consultation_document.dart';

class DocumentService {
  final SupabaseClient _sb;

  DocumentService({SupabaseClient? client})
      : _sb = client ?? Supabase.instance.client;

  Future<GenericResponse<ConsultationDocument>> uploadConsultationDocument({
    required int consultationId,
    required String fileName,
    required Uint8List bytes,
    String? contentType,
  }) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) {
      return const GenericResponse(
        success: false,
        code: 'UNAUTHENTICATED',
        message: 'Debes iniciar sesión.',
      );
    }
    final safeName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final path =
        '$uid/$consultationId/${DateTime.now().millisecondsSinceEpoch}_$safeName';
    try {
      await _sb.storage
          .from(SupabaseConfig.consultationDocsBucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: false),
          );
      final row = await _sb
          .from('consultation_documents')
          .insert({
            'consultation_id': consultationId,
            'uploaded_by': uid,
            'file_name': fileName,
            'storage_path': path,
            'file_url': path,
            'content_type': contentType,
            'size_bytes': bytes.length,
          })
          .select()
          .single();
      return GenericResponse(
        success: true,
        data: ConsultationDocument.fromJson(row),
        code: 'DOCUMENT_UPLOADED',
        message: 'Archivo cargado.',
      );
    } catch (error) {
      try {
        await _sb.storage
            .from(SupabaseConfig.consultationDocsBucket)
            .remove([path]);
      } catch (_) {}
      return GenericResponse(
        success: false,
        code: 'DOCUMENT_UPLOAD_ERROR',
        message: 'No se pudo cargar el archivo.',
        error: error.toString(),
      );
    }
  }

  Future<GenericResponse<List<ConsultationDocument>>> fetchForConsultation(
    int consultationId,
  ) async {
    try {
      final rows = await _sb
          .from('consultation_documents')
          .select()
          .eq('consultation_id', consultationId)
          .order('created_at');
      return GenericResponse(
        success: true,
        data: (rows as List)
            .map((row) => ConsultationDocument.fromJson(
                Map<String, dynamic>.from(row as Map)))
            .toList(),
      );
    } catch (error) {
      return GenericResponse(
        success: false,
        code: 'DOCUMENTS_ERROR',
        message: 'No se pudieron cargar los archivos.',
        error: error.toString(),
      );
    }
  }

  Future<GenericResponse<String>> createSignedUrl(String path) async {
    try {
      final url = await _sb.storage
          .from(SupabaseConfig.consultationDocsBucket)
          .createSignedUrl(path, 300);
      return GenericResponse(success: true, data: url);
    } catch (error) {
      return GenericResponse(
        success: false,
        code: 'DOCUMENT_URL_ERROR',
        message: 'No se pudo abrir el archivo.',
        error: error.toString(),
      );
    }
  }

  Future<GenericResponse<void>> delete(ConsultationDocument document) async {
    try {
      await _sb.storage
          .from(SupabaseConfig.consultationDocsBucket)
          .remove([document.storagePath]);
      await _sb.from('consultation_documents').delete().eq('id', document.id);
      return const GenericResponse(
          success: true, message: 'Archivo eliminado.');
    } catch (error) {
      return GenericResponse(
        success: false,
        code: 'DOCUMENT_DELETE_ERROR',
        message: 'No se pudo eliminar el archivo.',
        error: error.toString(),
      );
    }
  }
}
