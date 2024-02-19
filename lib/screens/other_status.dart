import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talk_hub/api/apis.dart';

class OtherStatus extends StatelessWidget {
  const OtherStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Status'),
      ),
      body: FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
  future: APIs.getOtherStatuses(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          final data = snapshot.data![index].data() as Map<String, dynamic>;
          return ListTile(
            leading: data['imageUrl'] != null ? Image.network(data['imageUrl']) : null,
            title: Text(data['text']),
            subtitle: Text(data['timestamp'].toString()), // Format as desired
          );
        },
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  },
)
    );
  }
}