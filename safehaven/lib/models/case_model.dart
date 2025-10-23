class CaseModel {
  final String id;
  final String title;
  final String location;
  String status; // "active", "in-progress", "resolved"
  bool accepted; // whether a volunteer accepted

  CaseModel({
    required this.id,
    required this.title,
    required this.location,
    this.status = 'active',
    this.accepted = false,
  });

  factory CaseModel.fromJson(Map<String, dynamic> j) => CaseModel(
        id: j['id'].toString(),
        title: j['title'],
        location: j['location'] ?? '',
        status: j['status'] ?? 'active',
        accepted: j['accepted'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'location': location,
        'status': status,
        'accepted': accepted,
      };
}
