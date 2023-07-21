class UserModel {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? location;
  String? tags;
  String? avatar;
  String? role;

  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.location,
    this.tags,
    this.avatar,
    this.role,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'].toString().trim();
    lastName = json['last_name'].toString().trim();
    email = json['email'];
    location = json['location'];
    tags = json['tags'];
    avatar = json['avatar'] != null
        ? "https://d4d.agpro.co.in/assets/${json['avatar']}"
        : null;
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['location'] = location;
    data['tags'] = tags;
    data['avatar'] = avatar;
    data['role'] = role;
    return data;
  }
}
