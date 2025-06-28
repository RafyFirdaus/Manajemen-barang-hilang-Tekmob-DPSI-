class Report {
  final String id;
  final String jenisLaporan;
  final String namaBarang;
  final String lokasi;
  final DateTime tanggalKejadian;
  final String deskripsi;
  final List<String> fotoPaths;
  final DateTime tanggalDibuat;
  final String status;
  final String userId;
  final String? matchedReportId; // ID laporan yang dicocokan

  Report({
    required this.id,
    required this.jenisLaporan,
    required this.namaBarang,
    required this.lokasi,
    required this.tanggalKejadian,
    required this.deskripsi,
    required this.fotoPaths,
    required this.tanggalDibuat,
    required this.status,
    required this.userId,
    this.matchedReportId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jenisLaporan': jenisLaporan,
      'namaBarang': namaBarang,
      'lokasi': lokasi,
      'tanggalKejadian': tanggalKejadian.toIso8601String(),
      'deskripsi': deskripsi,
      'fotoPaths': fotoPaths,
      'tanggalDibuat': tanggalDibuat.toIso8601String(),
      'status': status,
      'userId': userId,
      'matchedReportId': matchedReportId,
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      jenisLaporan: json['jenisLaporan'],
      namaBarang: json['namaBarang'],
      lokasi: json['lokasi'],
      tanggalKejadian: DateTime.parse(json['tanggalKejadian']),
      deskripsi: json['deskripsi'],
      fotoPaths: List<String>.from(json['fotoPaths']),
      tanggalDibuat: DateTime.parse(json['tanggalDibuat']),
      status: json['status'],
      userId: json['userId'],
      matchedReportId: json['matchedReportId'],
    );
  }
}