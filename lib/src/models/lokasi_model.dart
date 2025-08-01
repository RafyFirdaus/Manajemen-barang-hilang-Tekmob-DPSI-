class Lokasi {
  final String idLokasiKlaim;
  final String lokasiKlaim;
  final DateTime? createdAt;
  final String? createdBy;

  Lokasi({
    required this.idLokasiKlaim,
    required this.lokasiKlaim,
    this.createdAt,
    this.createdBy,
  });

  factory Lokasi.fromJson(Map<String, dynamic> json) {
    return Lokasi(
      idLokasiKlaim: json['id_lokasi_klaim']?.toString() ?? '',
      lokasiKlaim: json['lokasi_klaim']?.toString() ?? '',
      createdAt: json['created_at'] != null 
          ? _parseDateTime(json['created_at']) 
          : null,
      createdBy: json['created_by']?.toString(),
    );
  }

  static DateTime? _parseDateTime(dynamic dateValue) {
    try {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is Map<String, dynamic>) {
        // Handle Firestore timestamp format
        final seconds = dateValue['_seconds'];
        final nanoseconds = dateValue['_nanoseconds'] ?? 0;
        if (seconds != null) {
          return DateTime.fromMillisecondsSinceEpoch(
            (seconds * 1000) + (nanoseconds ~/ 1000000)
          );
        }
      }
      return null;
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id_lokasi_klaim': idLokasiKlaim,
      'lokasi_klaim': lokasiKlaim,
      'created_at': createdAt?.toIso8601String(),
      'created_by': createdBy,
    };
  }
}