import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/services/database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatFeed extends StatefulWidget {
  const ChatFeed({Key? key}) : super(key: key);

  @override
  State<ChatFeed> createState() => _ChatFeedState();
}

class _ChatFeedState extends State<ChatFeed> with WidgetsBindingObserver {
  final _messageController = TextEditingController();
  void clearText() {
    _messageController.clear();
  }

  

  @override
  Widget build(BuildContext context) {
    final stream = Database().chatCollectionStream;
    String giphyApiKey = dotenv.env["giphyApiKey"].toString();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('$chatRoom Chat'),
      ),
      body: KeyboardVisibilityBuilder(builder: (context, isVisible) {
        return Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: stream,
                builder: (BuildContext context, snapshot) {
                  final posts = snapshot.data?.docs;
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  return
                      ListView.builder(
                    reverse: true,
                    shrinkWrap: true,
                    itemCount: posts!.length,
                    itemBuilder: (context, index) {
                      final message = posts[index]['messages'];
                      final photoUrl = posts[index]['photoUrl'];
                      final name = posts[index]['name'];
                      var gif = posts[index]['gif'];
                      return gif == null
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(photoUrl!),
                                  ),
                                  title: Text(name),
                                  subtitle: SelectableText(message),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(photoUrl!),
                                  ),
                                  title: Text(name),
                                  subtitle: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                    child: Image.network(gif),
                                  ),
                                ),
                              ),
                            );
                    },
                  );
                },
              ),
            ),
            Container(
              color: Colors.grey.shade800,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      final gif = await GiphyPicker.pickGif(
                        context: context,
                        apiKey: giphyApiKey,
                        fullScreenDialog: false,
                        previewType: GiphyPreviewType.previewWebp,
                        decorator: GiphyDecorator(
                          showAppBar: false,
                          searchElevation: 4,
                          giphyTheme: ThemeData.dark().copyWith(
                            inputDecorationTheme: const InputDecorationTheme(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      );
                      if (gif != null) {
                        var url = gif.images.original!.url!;
                        Database().addGiphy(url);
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.gif),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      padding: const EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          width: 2,
                          color: Colors.purpleAccent,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: TextField(
                          decoration: const InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.purpleAccent),
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.all(2.0),
                          ),
                          style: const TextStyle(
                            height: 1.5,
                          ),
                          controller: _messageController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_messageController) {
                            if (_messageController.isNotEmpty) {
                              Database().addMessage(_messageController);
                              clearText();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_messageController.text != '') {
                        Database().addMessage(_messageController.text);
                        clearText();
                      }
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
