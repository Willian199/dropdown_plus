import 'dart:convert';

class Role {
  final String name;
  final String description;
  final int id;

  Role({required this.name, required this.description, required this.id});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      name: json['name'],
      description: json['desc'],
      id: json['role'],
    );
  }

  static List<Role> rolesFromJson() {
    String rolesJson = '''
    [
      {"name": "Super Admin", "desc": "Having full access rights", "role": 1},
      {"name": "Admin", "desc": "Having full access rights of a Organization", "role": 2},
      {"name": "Manager", "desc": "Having Magenent access rights of a Organization", "role": 3},
      {"name": "Technician", "desc": "Having Technician Support access rights", "role": 4},
      {"name": "Customer Support", "desc": "Having Customer Support access rights", "role": 5},
      {"name": "User", "desc": "Having End User access rights", "role": 6}
    ]
  ''';
    final List<dynamic> jsonList = jsonDecode(rolesJson);
    return jsonList.map((json) => Role.fromJson(json)).toList();
  }
}
