import 'dart:convert';

class ChatUserModel {
    String image;
    String name;
    String about;
    String createdAt;
    String lastActive;
    String id;
    bool isOnline;
    dynamic pushToken;
    String email;

    ChatUserModel({
        required this.image,
        required this.name,
        required this.about,
        required this.createdAt,
        required this.lastActive,
        required this.id,
        required this.isOnline,
        required this.pushToken,
        required this.email,
    });

    ChatUserModel copyWith({
        String? image,
        String? name,
        String? about,
        String? createdAt,
        String? lastActive,
        String? id,
        bool? isOnline,
        dynamic pushToken,
        String? email,
    }) => 
        ChatUserModel(
            image: image ?? this.image,
            name: name ?? this.name,
            about: about ?? this.about,
            createdAt: createdAt ?? this.createdAt,
            lastActive: lastActive ?? this.lastActive,
            id: id ?? this.id,
            isOnline: isOnline ?? this.isOnline,
            pushToken: pushToken ?? this.pushToken,
            email: email ?? this.email,
        );

    factory ChatUserModel.fromRawJson(String str) => ChatUserModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ChatUserModel.fromJson(Map<String, dynamic> json) => ChatUserModel(
        image: json["image"],
        name: json["name"],
        about: json["about"],
        createdAt: json["created_at"],
        lastActive: json["last_active"],
        id: json["id"],
        isOnline: json["is_online"],
        pushToken: json["push_token"],
        email: json["email"],
    );

    Map<String, dynamic> toJson() => {
        "image": image,
        "name": name,
        "about": about,
        "created_at": createdAt,
        "last_active": lastActive,
        "id": id,
        "is_online": isOnline,
        "push_token": pushToken,
        "email": email,
    };
}
