class MessageModel {
  String toId;
  String msg;
  String read;
  Type type;
  String sent;
  String fromId;

  MessageModel({
    required this.toId,
    required this.msg,
    required this.read,
    required this.type,
    required this.sent,
    required this.fromId,
  });

 factory MessageModel.fromJson(Map<String, dynamic> json) {
  final String typeString = (json["type"] as String?)?.toLowerCase() ?? "";
  Type messageType = Type.text;

  if (typeString == "image") {
    messageType = Type.image;
  }

  return MessageModel(
    toId: json["toId"] ?? "",
    msg: json["msg"] ?? "",
    read: json["read"] ?? "",
    type: messageType,
    sent: json["sent"] ?? "",
    fromId: json["fromId"] ?? "",
  );
}


  Map<String, dynamic> toJson() => {
        "toId": toId,
        "msg": msg,
        "read": read,
        "type": type.name,
        "sent": sent,
        "fromId": fromId,
      };
}

 enum Type {
  text,
  image,
}
