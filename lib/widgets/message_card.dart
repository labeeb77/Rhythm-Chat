import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:talk_hub/api/apis.dart';
import 'package:talk_hub/helper/date_utils.dart';
import 'package:talk_hub/model/message_model.dart';

class MessageCard extends StatefulWidget {
  final MessageModel message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
  }

  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      log('message read updated');
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 54, 54, 54),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
              child: widget.message.type == Type.text
                  ? Text(
                      widget.message.msg,
                      style: const TextStyle(fontSize: 16, color: Colors.white,fontWeight: FontWeight.w500),
                    )
                  : ClipRRect(
                    
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        imageUrl: widget.message.msg,
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                          child: Icon(
                            Icons.photo,
                            size: 70,
                          ),
                        ),
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    )),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            DateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
        )
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                size: 18,
                color: Colors.blue,
              ),
            const SizedBox(
              width: 5,
            ),
            Text(
              DateUtil.getFormattedTime(
                  context: context, time: widget.message.sent,),
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
        Flexible(
          child: Container(
             constraints: const BoxConstraints(
              maxWidth: 200.0, // Set your desired max width here
            ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: const BoxDecoration(
                  color: Colors.blue,
                
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30))),
              child: widget.message.type == Type.text
                  ? Text(
                      widget.message.msg,
                      style: const TextStyle(fontSize: 16, color: Colors.white,fontWeight: FontWeight.w500),
                    )
                  : GlassContainer(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                          child: Icon(
                            Icons.photo,
                            size: 70,
                          ),
                        ),
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    )),
        ),
      ],
    );
  }
}
