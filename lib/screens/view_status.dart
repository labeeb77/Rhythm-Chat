import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class ViewStory extends StatefulWidget {
  final String userName;
  final String userPhoto;
  final List<String> statusImages;
  final String statusText;
  final String time;

  const ViewStory({
    Key? key,
    required this.userName,
    required this.statusImages,
    required this.statusText,
    required this.time,
    required this.userPhoto,
  }) : super(key: key);

  @override
  State<ViewStory> createState() => _ViewStoryState();
}

class _ViewStoryState extends State<ViewStory> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: widget.statusImages.length,
              controller: PageController(initialPage: currentIndex),
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.network(
                  widget.statusImages[index],
                  fit: BoxFit.cover,
                );
              },
            ),
            Positioned(
              top: 25,
              left: 15,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(widget.userPhoto),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.time,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: (currentIndex + 1) / widget.statusImages.length,
                color: Colors.white, // Customize the progress bar color
                backgroundColor: Colors.transparent,
              ),
            ),
            Positioned(
              bottom: 16.0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.statusText,
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Handle tap to dismiss
                Navigator.pop(context);
              },
              child: Container(
                color: Colors.transparent,
                constraints: const BoxConstraints.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
