class User {
  final String id; // 사용자 고유 ID
  final String name; // 사용자 이름
  final String email; // 사용자 이메일
  final String? phoneNumber; // 전화번호 (옵션)

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
  });

  // Firestore와 같은 데이터베이스에서 데이터를 가져올 때 사용
  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      id: documentId,
      name: map['name'] as String,
      email: map['email'] as String,
      phoneNumber: map['phoneNumber'] as String?,
    );
  }

  // 데이터를 데이터베이스에 저장할 때 사용
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, phoneNumber: $phoneNumber)';
  }
}
