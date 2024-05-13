class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String profilePictureUrl;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.profilePictureUrl,
  });

  factory Doctor.fromMap(String id, Map<String, dynamic> map) {
    return Doctor(
      id: id,
      name: map['name'] ?? '',
      specialization: map['specialization'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
    );
  }
}
