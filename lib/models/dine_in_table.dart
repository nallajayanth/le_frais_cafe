class DineInTable {
  final int id;
  final String tableName;
  final String qrToken;
  final String? qrUrl;

  const DineInTable({
    required this.id,
    required this.tableName,
    required this.qrToken,
    this.qrUrl,
  });

  factory DineInTable.fromJson(Map<String, dynamic> json) {
    final rawId = json['table_id'] ?? json['tableId'] ?? json['id'];

    return DineInTable(
      id: rawId is num ? rawId.toInt() : int.tryParse('$rawId') ?? 0,
      tableName: (json['table_name'] ?? json['tableName'] ?? json['name'] ?? '')
          .toString(),
      qrToken: (json['qr_token'] ?? json['qrToken'] ?? json['token'] ?? '')
          .toString(),
      qrUrl: (json['qr_url'] ?? json['qrUrl'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableName': tableName,
      'qrToken': qrToken,
      'qrUrl': qrUrl,
    };
  }
}
