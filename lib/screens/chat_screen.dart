import 'dart:developer';
import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk_hub/api/apis.dart';
import 'package:talk_hub/model/chat_user_model.dart';
import 'package:talk_hub/model/message_model.dart';
import 'package:talk_hub/widgets/message_card.dart';
import 'package:flutter/foundation.dart' as foundation;

class ChatScreen extends StatefulWidget {
  final ChatUserModel user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageModel> _list = [];
  bool _showImoji = false,_isUploading = false;

  final _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          
          backgroundColor: Colors.black,
          elevation: 10,
          title: InkWell(
            onTap: () {},
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                      width: 40,
                      height: 40,
                      fit: BoxFit.fill,
                      errorWidget: (context, url, error) => const CircleAvatar(
                            child: Icon(CupertinoIcons.person),
                          ),
                      imageUrl: widget.user.image,),
                ),
                const SizedBox(
                  width: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.name,
                      style: const TextStyle(fontSize: 17,color: Colors.white,fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'last seen at 10.00',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: APIs.getAllMessages(widget.user),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const SizedBox();
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      _list = data
                              ?.map((e) => MessageModel.fromJson(e.data()))
                              .toList() ??
                          [];

                      if (_list.isNotEmpty) {
                        return ListView.builder(
                          reverse: true,
                          itemCount: _list.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return MessageCard(
                              message: _list[index],
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text(
                            "Say hi👋",
                            style: TextStyle(fontSize: 20),
                          ),
                        );
                      }
                  }
                },
              ),
            ),
            if(_isUploading)
            const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                child: CircularProgressIndicator(strokeWidth: 2,))),
            _chatInput(),
            if (_showImoji)
              SizedBox(
                height: 300,
                child: EmojiPicker(
                  textEditingController: _textEditingController,
                  config: Config(
                    columns: 7,
                    emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25,horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: GlassContainer(
            borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          FocusScope.of(context).unfocus();
                          _showImoji = !_showImoji;
                        });
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.white60,
                      )),
                  Expanded(
                      child: TextField(
                    controller: _textEditingController,
                    keyboardType: TextInputType.multiline,
                    onTap: () {
                      if (_showImoji) {
                        setState(() {
                          _showImoji = !_showImoji;
                        });
                      }
                    },
                    maxLines: null,
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'Type somthing...',hintStyle: TextStyle(color: Colors.white60)),
                  )),
                  IconButton(
                      onPressed: () async{
                        final ImagePicker picker = ImagePicker();

                        final List<XFile> images = await picker.pickMultiImage(
                             imageQuality: 70);

                        for(var i in images){
                          log('Image Path: ${i.path}');
                          setState(() {
                            _isUploading = true;
                          });
                          await APIs.sendChatImage(
                              widget.user, File(i.path));
                              setState(() {
                            _isUploading = false;
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.image,
                        color: Colors.white60,
                      )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);

                        if (image != null) {
                          log('Image path:${image.path}');
                          setState(() {
                            _isUploading = true;
                          });

                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                              setState(() {
                            _isUploading = false;
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white60,
                      ))
                ],
              ),
            ),
          ),
          SizedBox(width: 5,),
          MaterialButton(
            onPressed: () {
              if (_textEditingController.text.isNotEmpty) {
                APIs.sendMessage(
                    widget.user, _textEditingController.text, Type.text);
                _textEditingController.text = '';
              }
            },
            shape: const CircleBorder(),
            color: Colors.blue,
            minWidth: 0,
            padding:
                const EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 5),
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 30,
            ),
          )
        ],
      ),
    );
  }
}
