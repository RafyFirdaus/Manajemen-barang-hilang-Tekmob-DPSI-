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
    return Klaim(
      idKlaim: json['id_klaim'],
      idLaporanCocok: json['id_laporan_cocok'],
      idSatpam: json['id_satpam'],
      idPenerima: json['id_penerima'],
      urlFotoKlaim: json['url_foto_klaim'],
      waktuTerima: DateTime.parse(json['waktu_terima']),
      status: json['status'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
    );
  }
}