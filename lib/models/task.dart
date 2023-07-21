// To parse this JSON data, do
//
//     final task = taskFromJson(jsonString);

import 'dart:convert';

Task taskFromJson(String str) => Task.fromJson(json.decode(str));

String taskToJson(Task data) => json.encode(data.toJson());

class Task {
  String? id;
  bool? status;
  String? userCreated;
  DateTime? dateCreated;
  dynamic dateUpdated;
  String? name;
  String? description;
  List<Checklist>? checklist;

  Task({
    this.id,
    this.status,
    this.userCreated,
    this.dateCreated,
    this.dateUpdated,
    this.name,
    this.description,
    this.checklist,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json["id"],
        status: json["status"],
        userCreated: json["user_created"],
        dateCreated: json["date_created"] == null
            ? null
            : DateTime.parse(json["date_created"]),
        dateUpdated: json["date_updated"],
        name: json["name"],
        description: json["description"],
        checklist: json["checklist"] == null
            ? []
            : List<Checklist>.from(
                json["checklist"]!.map((x) => Checklist.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "user_created": userCreated,
        "date_created": dateCreated?.toIso8601String(),
        "date_updated": dateUpdated,
        "name": name,
        "description": description,
        "checklist": checklist == null
            ? []
            : List<dynamic>.from(checklist!.map((x) => x.toJson())),
      };
}

class Checklist {
  String? subtask;
  bool? status;

  Checklist({
    this.subtask,
    this.status,
  });

  factory Checklist.fromJson(Map<String, dynamic> json) => Checklist(
        subtask: json["subtask"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "subtask": subtask,
        "status": status,
      };
}
