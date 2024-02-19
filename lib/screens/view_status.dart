import 'dart:async';

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
  late Timer timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 15), (Timer t) {
      if (currentIndex < widget.statusImages.length - 1) {
        setState(() {
          currentIndex++;
        });
      } else {
        // All images have been displayed, navigate back or take appropriate action
        t.cancel(); // Stop the timer
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          centerTitle: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.black, Colors.black],
              ),
              color: Colors.black,
            ),
          ),
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.userPhoto),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 203, 202, 202),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    widget.time,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
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
              top: 0,
              child: LinearProgressIndicator(
                value: (currentIndex + 1) / widget.statusImages.length,
                color: Colors.blue, // Customize the progress bar color
                backgroundColor: Colors.grey[700],
              ),
            ),
            Positioned(
              bottom: 16.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.statusText,
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
