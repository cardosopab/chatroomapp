import 'dart:io';
import 'dart:typed_data';
import 'package:chatapp/pages/signin.dart';
import 'package:chatapp/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as _storage;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

void clearText() {
  nameController.clear();
}

final nameController = TextEditingController();

bool textFieldVisibility = false;
bool textVisibility = true;

class _ProfilePageState extends State<ProfilePage> {
  void showKeyboard() {
    focusNode.requestFocus();
  }

  late FocusNode focusNode;
  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  final currentUID = Database().currentUID;
  late File imageFile;
  Future pickImage(ImageSource source) async {
    if (kIsWeb) {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imagePath = image.path;
      final imagePathName = image.name;
      final destinaton = '$currentUID/$imagePathName';
      setState(() => imageFile = File(imagePath));
      // upload to Storage
      final ref = _storage.FirebaseStorage.instance.ref(destinaton);
      Uint8List image8 = await image.readAsBytes();
      final TaskSnapshot snapshot = await ref.putData(image8);
      final url = await snapshot.ref.getDownloadURL();
      setState(() => photoUrl = url);
      await Database().addPhoto(url);
    } else {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imagePath = image.path;
      final imagePathName = image.name;
      final destinaton = '$currentUID/$imagePathName';
      setState(() => imageFile = File(imagePath));
      // upload to Storage
      final ref = _storage.FirebaseStorage.instance.ref(destinaton);
      final TaskSnapshot snapshot = await ref.putFile(imageFile);
      final url = await snapshot.ref.getDownloadURL();
      setState(() => photoUrl = url);
      await Database().addPhoto(url);
    }
  }

  var photoUrl = Database().photoUrl;
  String name = Database().name!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Source'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                pickImage(ImageSource.gallery);
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('Gallery'),
                          ),
                          TextButton(
                            onPressed: () {
                              pickImage(ImageSource.camera);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Camera'),
                          ),
                        ],
                      );
                    }),
                child: Consumer(builder:
                    (BuildContext context, WidgetRef ref, Widget? child) {
                  return Stack(
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(photoUrl!),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(100)),
                            child: const IconTheme(
                                data: IconThemeData(
                                    size: 20, color: Colors.white),
                                child: Icon(Icons.add_a_photo))),
                      )
                    ],
                  );
                }),
              ),
              const SizedBox(
                height: 30,
              ),
              Visibility(
                visible: textFieldVisibility,
                child: Column(
                  children: [
                    const Text("Set up your Display Name"),
                    Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: TextField(
                        // focusNode: focusNode,
                        textInputAction: TextInputAction.done,
                        controller: nameController,
                        decoration: const InputDecoration(hintText: 'Name'),
                        onSubmitted: (nameController) async {
                          clearText();
                          if (nameController.isNotEmpty) {
                            await Database().addName(nameController);
                            setState(
                              () {
                                textFieldVisibility = !textFieldVisibility;
                                textVisibility = !textVisibility;
                                name = nameController;
                                clearText();
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: textVisibility,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(name),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          textFieldVisibility = !textFieldVisibility;
                          textVisibility = !textVisibility;
                        });
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextButton(
              onPressed: () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title:
                          const Text('Are you sure,\n\nyou\'d like to delete?'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                FirebaseAuth.instance.currentUser!.delete();
                                Navigator.of(context).pop();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SigninPage()));
                              });
                            },
                            child: const Text('Delete Profile'))
                      ],
                    );
                  }),
              child: const Text('Delete Profile'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                if (nameController.text != '') {
                  Database().addName(nameController.text);
                  clearText();
                  textFieldVisibility = !textFieldVisibility;
                  textVisibility = !textVisibility;
                }

                Navigator.of(context).pop();
              },
              child: const Text('Submit Profile'),
            ),
          ),
        ],
      ),
    );
  }
}
