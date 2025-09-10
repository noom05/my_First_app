import 'dart:convert';

CustomerRegisterPostResponse customerLoginPostResponseFromJson(String str) =>
    CustomerRegisterPostResponse.fromJson(json.decode(str));

String CustomerRegisterPostResponseToJson(CustomerRegisterPostResponse data) =>
    json.encode(data.toJson());

class CustomerRegisterPostResponse {
  String message;
  int id;

  CustomerRegisterPostResponse({required this.message, required this.id});

  factory CustomerRegisterPostResponse.fromJson(Map<String, dynamic> json) =>
      CustomerRegisterPostResponse(message: json["message"], id: json["id"]);

  Map<String, dynamic> toJson() => {"message": message, "id": id};
}
