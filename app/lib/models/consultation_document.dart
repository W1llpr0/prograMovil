class ConsultationDocument {
  final int id;
  final int consultationId;
  final String fileName;
  final String storagePath;
  final String? contentType;
  final int? sizeBytes;
  final String docType;
  final DateTime createdAt;

  const ConsultationDocument({
    required this.id,
    required this.consultationId,
    required this.fileName,
    required this.storagePath,
    this.contentType,
    this.sizeBytes,
    required this.docType,
    required this.createdAt,
  });

  factory ConsultationDocument.fromJson(Map<String, dynamic> json) =>
      ConsultationDocument(
        id: (json['id'] as num).toInt(),
        consultationId: (json['consultation_id'] as num).toInt(),
        fileName: json['file_name'] as String? ?? 'Documento',
        storagePath: json['storage_path'] as String? ??
            json['file_url'] as String? ??
            '',
        contentType: json['content_type'] as String?,
        sizeBytes: (json['size_bytes'] as num?)?.toInt(),
        docType: json['doc_type'] as String? ?? 'attachment',
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
            DateTime.now(),
      );
}
