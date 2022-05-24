import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:giphy_picker/giphy_picker.dart';

class GifPage extends StatefulWidget {
  const GifPage({Key? key}) : super(key: key);

  @override
  _GifPageState createState() => _GifPageState();
}

var giphyApiKey = dotenv.env["giphyApiKey"].toString();

class _GifPageState extends State<GifPage> {
  GiphyGif? _gif;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_gif?.title ?? 'Giphy Picker Demo'),
      ),
      body: SafeArea(
        child: Center(
            child: _gif == null
                ? const Text('Pick a gif..')
                : Image.network(
                    _gif!.images.original!.url!,
                  )),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.search),
        onPressed: () async {
          // request your Giphy API key at https://developers.giphy.com/
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
            setState(() => _gif = gif);
          }
        },
      ),
    );
  }
}
