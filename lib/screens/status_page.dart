import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk_hub/api/apis.dart';
import 'package:talk_hub/screens/profile.dart';
import 'package:talk_hub/screens/view_status.dart';
import 'package:talk_hub/widgets/utils.dart';
import 'package:video_player/video_player.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({
    super.key,
  });

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  @override
  void initState() {
    APIs.getSelfInfo();
    super.initState();
  }

  TextEditingController statusTextController = TextEditingController();
  String? _videoUrl;
  VideoPlayerController? _videoPlayerController;
  String? _downLoadUrl;
  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          // TabBar
          centerTitle: false,
          backgroundColor: Colors.black,

          title: const Text(
            "Stories",
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Text color set to white for visibility
            ),
          ),

          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      user: APIs.me,
                    ),
                  ));
                },
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                )),
          ],
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Story',
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 80,
                child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: APIs.getMyStatus(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Display a loading indicator while waiting for data
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      // Display an error message if there's an error
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (snapshot.hasData && snapshot.data!.exists) {
                      // Display the status data
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final timestamp = data[
                          'timestamp']; // Assuming this is a DateTime object
                      final formattedTime = formatTimestamp(timestamp);
                      final statusText = data['text'];
                      final List<String> imageUrls =
                          List<String>.from(data['imageUrls']);
                       

                      return Column(
                        children: [
                          ListTile(
                           
                            leading: InkWell(
                               onTap: () {
                               
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewStory(
                                      userName: APIs.me.name,
                                      userPhoto: APIs.user.photoURL!,
                                      statusImages: imageUrls,
                                      statusText: statusText,
                                      time: formattedTime,
                                    ),
                                  ));
                            },
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(APIs.user.photoURL!),
                              ),
                            ),
                            title: Text(
                              APIs.me.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              formattedTime, // Replace with actual timestamp
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: IconButton(
                                onPressed: () {
                                  pickImageAndAddStatus(context);
                                },
                                icon: const Icon(
                                  CupertinoIcons.add_circled,
                                  size: 30,
                                )),
                          ),
                        ],
                      );
                    } else {
                      // Display a message when there's no status yet
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(APIs.me.image),
                        ),
                        title: Text(
                          APIs.me.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'Tap to update story', // Replace with actual timestamp
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: IconButton(
                            onPressed: () {
                              pickImageAndAddStatus(context);
                            },
                            icon: const Icon(
                              CupertinoIcons.add_circled,
                              size: 30,
                            )),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'Recent Stories',
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 500,
                child:
                    FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
                  future: APIs.getOtherStatuses(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Future is still loading
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      log('Error: ${snapshot.error}');
                      // Future encountered an error
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      // Future completed successfully, but there's no data
                      return const Center(child: Text('No statuses found.'));
                    } else {
                      // Future completed successfully and has data
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final data = snapshot.data![index].data()
                              as Map<String, dynamic>;
                          DocumentSnapshot document = snapshot.data![index];
                             final List<String> imageUrls =
                          List<String>.from(data['imageUrls']);

                          final timestamp = data[
                              'timestamp']; // Assuming this is a DateTime object
                          final formattedTime = formatTimestamp(timestamp);

                          if (document.id == APIs.user.uid) {
                            // Skip the current user's data
                            return const SizedBox
                                .shrink(); // Alternatively, you can use Container() or return null
                          }

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(data['userPhoto']),
                            ),
                            title: Text(
                              data['userName'],
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              formattedTime, // Replace with actual timestamp
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ViewStory(
                                    userName: data['userName'],
                                    userPhoto: data['userPhoto'],
                                    statusImages: imageUrls,
                                    statusText: data['text'],
                                    time: formattedTime),
                              ));
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      )),
    );
  }

  Future<void> pickImageAndAddStatus(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    List<XFile>? pickedFiles = await _picker.pickMultiImage(
      imageQuality: 70,
      maxWidth: 800,
    );

    if (context.mounted) {
      if (pickedFiles.isNotEmpty) {
        List<File> pickedImages =
            pickedFiles.map((file) => File(file.path)).toList();
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AlertDialog(
                insetPadding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                backgroundColor: Colors.transparent,
                title: const Text(
                  'Add Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Form(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GlassContainer(
                              child: SizedBox(
                                height: 200,
                                width: 300,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: pickedImages.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.file(
                                        pickedImages[index],
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: statusTextController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Add your status...',
                                hintStyle: TextStyle(color: Colors.white70),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            SizedBox(
                              width: 130,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent),
                                onPressed: () async {
                                  await APIs.storeStatus(
                                      userName: APIs.me.name,
                                      userPhoto: APIs.user.photoURL!,
                                      userId: APIs.user.uid,
                                      text: statusTextController.text,
                                      images: pickedFiles);
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: const Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }
    }
  }




}