class Klaim {
  final String idKlaim;
  final String idLaporanCocok;
  final String idSatpam;
  final String idPenerima;
  final String? urlFotoKlaim;
  final DateTime waktuTerima;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  Klaim({
    required this.idKlaim,
    required this.idLaporanCocok,
    required this.idSatpam,
    required this.idPenerima,
    this.urlFotoKlaim,
    required this.waktuTerima,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_klaim': idKlaim,
      'id_laporan_cocok': idLaporanCocok,
      'id_satpam': idSatpam,
      'id_penerima': idPenerima,
      'url_foto_klaim': urlFotoKlaim,
      'waktu_terima': waktuTerima.toIso8601String(),
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  factory Klaim.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to string
    String? safeString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      return value.toString();
    }
    
    // Helper function to safely parse datetime
    DateTime? safeDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          print('Error parsing datetime: $value, error: $e');
          return null;
        }
      }
      return null;
    }
    
    return Klaim(
      idKlaim: safeString(json['id_klaim']) ?? '',
      idLaporanCocok: safeString(json['id_laporan_cocok']) ?? '',
      idSatpam: safeString(json['id_satpam']) ?? '',
      idPenerima: safeString(json['id_penerima']) ?? '',
      urlFotoKlaim: safeString(json['url_foto_klaim']),
      waktuTerima: safeDateTime(json['waktu_terima']) ?? DateTime.now(),
      status: safeString(json['status']) ?? '',
      createdAt: safeDateTime(json['created_at']),
      updatedAt: safeDateTime(json['updated_at']),
      createdBy: safeString(json['created_by']),
      updatedBy: safeString(json['updated_by']),
    );
  }
}