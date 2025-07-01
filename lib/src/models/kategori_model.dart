class Kategori {
  final String idKategori;
  final String namaKategori;
  final DateTime? createdAt;

  Kategori({
    required this.idKategori,
    required this.namaKategori,
    this.createdAt,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      idKategori: json['id_kategori']?.toString() ?? '',
      namaKategori: json['nama_kategori']?.toString() ?? '',
      createdAt: json['created_at'] != null 
          ? _parseDateTime(json['created_at']) 
          : null,
    );
  }

  static DateTime? _parseDateTime(dynamic dateValue) {
    try {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      }
      return null;
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kategori': idKategori,
      'nama_kategori': namaKategori,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}