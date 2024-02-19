import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:talk_hub/api/apis.dart';
import 'package:talk_hub/helper/date_utils.dart';
import 'package:talk_hub/model/chat_user_model.dart';
import 'package:talk_hub/model/message_model.dart';
import 'package:talk_hub/screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUserModel user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  MessageModel? _message;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 10),
      child: GlassContainer(
        child: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatScreen(user: widget.user),
              ));
            },
            child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => MessageModel.fromJson(e.data())).toList() ??
                        [];
                if (list.isNotEmpty) _message = list[0];
                return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: CachedNetworkImage(
                          width: 50,
                          height: 50,
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                                child: Icon(CupertinoIcons.person),
                              ),
                          imageUrl: widget.user.image),
                    ),
                    title: Text(widget.user.name,style: TextStyle(color: Colors.grey[600]),),
                    subtitle: Text(
                      _message == null
                          ? widget.user.about
                          : _message!.type == Type.text
                              ? _message!.msg
                              : _message!.type == Type.image
                                  ? 'Photo'
                                  : widget.user.about,
                      maxLines: 1,
                    ),
                    trailing: _message == null
                        ? null
                        : _message!.read.isEmpty &&
                                _message!.fromId != APIs.user.uid
                            ? Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(30)),
                              )
                            : Text(
                                DateUtil.getLastMessageTime(
                                    context: context, time: _message!.sent),
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 14),
                              ));
              },
            )),
      ),
    );
  }
}
