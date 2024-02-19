import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

String formatTimestamp(Timestamp timestamp) {
  final now = DateTime.now();
  final dateTime = timestamp.toDate();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 5) {
    return 'just now';
  } else if (difference.inMinutes < 1) {
    return '${difference.inSeconds} seconds ago';
  } else if (difference.inHours < 1) {
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inDays < 1) {
    return '${difference.inHours} hours ago';
  } else if (difference.inDays == 1) {
    return 'yesterday';
  } else {
    return '${difference.inDays} days ago';
  }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}

pickVideo ()async{
  final picker = ImagePicker();
  XFile? videoFile;
  try{
    videoFile = await picker.pickVideo(source: ImageSource.gallery);
    return videoFile!.path;

  }catch(e){
    log('error fetching data $e');

  }
}