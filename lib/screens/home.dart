import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:talk_hub/api/apis.dart';
import 'package:talk_hub/model/chat_user_model.dart';
import 'package:talk_hub/screens/profile.dart';
import 'package:talk_hub/widgets/chat_user_card.dart';
import 'package:talk_hub/widgets/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatUserModel> list = [];
  final List<ChatUserModel> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    APIs.getSelfInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(65.0),
            child: AppBar(
              // TabBar
              backgroundColor: Colors.black,

              title: _isSearching
                  ? TextField(
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: 'name, email...'),
                      autofocus: true,
                      onChanged: (value) {
                        _searchList.clear();

                        for (var i in list) {
                          if (i.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(value.toLowerCase())) {
                            _searchList.add(i);
                          }
                          setState(() {
                            _searchList;
                          });
                        }
                      },
                    )
                  : GradientText(
                      'RythmChat',
                      style:  GoogleFonts.courgette(fontSize: 23,fontWeight: FontWeight.bold),
                      gradient: LinearGradient(colors: [
                        Colors.green.shade400,
                        Colors.blue.shade400,
                      ]),
                    ),

              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: Icon(
                      _isSearching
                          ? CupertinoIcons.clear_circled
                          : Icons.search,
                      color: Colors.white,
                    )),
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
              child: StreamBuilder(
            stream: APIs.getAllusers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  list = data
                          ?.map((e) => ChatUserModel.fromJson(e.data()))
                          .toList() ??
                      [];
                  if (list.isNotEmpty) {
                    return ListView.builder(
                      itemCount:
                          _isSearching ? _searchList.length : list.length,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 10),
                      itemBuilder: (context, index) {
                        return ChatUserCard(
                          user: _isSearching ? _searchList[index] : list[index],
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text(
                        "No Connections Found!",
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }
              }
            },
          )),
        ),
      ),
    );
  }
}
