// To parse this JSON data, do
//
//     final deviceModel = deviceModelFromJson(jsonString);

import 'dart:convert';

DeviceModel deviceModelFromJson(String str) =>
    DeviceModel.fromJson(json.decode(str));

String deviceModelToJson(DeviceModel data) => json.encode(data.toJson());

class DeviceModel {
  DeviceModel({
    required this.status,
    this.id,
    this.password,
    this.model,
    this.topic,
    this.ip,
    this.camara,
  });

  String status;
  String? id;
  String? password;
  String? model;
  String? topic;
  String? ip;
  String? camara;

  factory DeviceModel.fromJson(Map<String, dynamic> json) => DeviceModel(
        status: json["status"] == null ? null : json["status"],
        id: json["id"] == null ? null : json["id"],
        password: json["password"] == null ? null : json["password"],
        model: json["model"] == null ? null : json["model"],
        topic: json["topic"] == null ? null : json["topic"],
        ip: json["ip"] == null ? null : json["ip"],
        camara: json["camara"] == null ? null : json["camara"],
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "id": id == null ? null : id,
        "password": password == null ? null : password,
        "model": model == null ? null : model,
        "topic": topic == null ? null : topic,
        "ip": ip == null ? null : ip,
      };
}
