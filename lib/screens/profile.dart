import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk_hub/api/apis.dart';
import 'package:talk_hub/helper/dialogue.dart';
import 'package:talk_hub/model/chat_user_model.dart';
import 'package:talk_hub/screens/auth/login_screen.dart';
import 'package:talk_hub/widgets/chat_user_card.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ProfilePage extends StatefulWidget {
  final ChatUserModel user;

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              Dialogue.showProgressBar(context);
              await APIs.firebaseAuth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  ZegoUIKitPrebuiltCallInvitationService().uninit();
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ));
                });
              });
            },
            icon: const Icon(Icons.logout_rounded),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 40,
                ),
                Stack(
                  children: [
                    _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.file(
                              File(_image!),
                              width: 100,
                              height: 100,
                              fit: BoxFit.fill,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: CachedNetworkImage(
                              width: 100,
                              height: 100,
                              fit: BoxFit.fill,
                              errorWidget: (context, url, error) =>
                                  const CircleAvatar(
                                child: Icon(CupertinoIcons.person),
                              ),
                              imageUrl: widget.user.image,
                            ),
                          ),
                    Positioned(
                      right: -23,
                      bottom: -5,
                      child: MaterialButton(
                        color: const Color.fromARGB(255, 159, 159, 159),
                        shape: const CircleBorder(),
                        elevation: 2,
                        onPressed: () {
                          _showBottomSheet();
                        },
                        child: const Icon(
                          Icons.edit,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(widget.user.email,
                    style: TextStyle(color: Colors.white54)),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  initialValue: widget.user.name,
                  style: TextStyle(color: Colors.white54),
                  onSaved: (newValue) => APIs.me.name = newValue ?? '',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'About is required';
                    }
                    return null;
                  },
                  initialValue: widget.user.about,
                  style: TextStyle(color: Colors.white54),
                  onSaved: (newValue) => APIs.me.about = newValue ?? '',
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.discount_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: 'About',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: GlassContainer(
                    borderRadius: BorderRadius.circular(25),
                    shadowColor: Colors.white24,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          log('Inside the validator');
                          _formKey.currentState!.save();
                          APIs.updateUserInfo().then((value) {
                            Dialogue.showSnackbar(
                                context, 'Profile updated successfully');
                          });
                        }
                      },
                      child: const Text('Update'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return GlassContainer(
          blur: 5,
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.2),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            children: [
              const Text(
                'Pick Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );

                      if (image != null) {
                        log('Image path: ${image.path}');
                        setState(() {
                          _image = image.path;
                        });
                        APIs.updateProfilePicture(File(_image!));
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: const Size(10, 10),
                    ),
                    child: const Icon(Icons.add_a_photo_outlined),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                      );

                      if (image != null) {
                        log('Image path: ${image.path} -- MimeType: ${image.mimeType}');
                        setState(() {
                          _image = image.path;
                        });
                        APIs.updateProfilePicture(File(_image!));
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: const Size(10, 10),
                    ),
                    child: const Icon(Icons.add_box_rounded),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

}
