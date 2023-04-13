
import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:provider/provider.dart';
import 'package:shakespeare/SelectedBooks.dart';
import 'dart:async';
import 'package:epub_view/epub_view.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/widgets.dart' as wid;
import 'package:shakespeare/SpotifyAPi/music.dart';

class Viewer extends StatefulWidget {
  const Viewer({Key? key, required this.openBookPath}) : super(key: key);
  final File openBookPath;


  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer>{
  late EpubController _epubReaderController;
  late String openedBook;

  @override
  void initState() {
    _epubReaderController = EpubController(
      document:
      EpubDocument.openFile(widget.openBookPath),
      // epubCfi:
      //     'epubcfi(/6/26[id4]!/4/2/2[id4]/22)', // book.epub Chapter 3 paragraph 10
      // epubCfi:
      //     'epubcfi(/6/6[chapter-2]!/4/2/1612)', // book_2.epub Chapter 16 paragraph 3
    );
    super.initState();
  }
  @override
  void dispose() {
    _epubReaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: EpubViewActualChapter(
          controller: _epubReaderController,
          builder: (chapterValue) =>
              Text(
                chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? '',
                textAlign: TextAlign.start,
              ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save_alt),
            color: Colors.white,
            onPressed: () => _showCurrentEpubCfi(context),
          ),
          IconButton(
            icon: const Icon(Icons.music_note),
            color: Colors.white,
            onPressed: () { Navigator.of(context).push(FullScreenModal()); }
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: EpubViewTableOfContents(controller: _epubReaderController),
      ),
      body: EpubView(
        builders: EpubViewBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          chapterDividerBuilder: (_) => const Divider(),
        ),
        controller: _epubReaderController,
      ),
    );
  }

    void _showCurrentEpubCfi(context) {
      final cfi = _epubReaderController.generateEpubCfi();

      if (cfi != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cfi),
            action: SnackBarAction(
              label: 'GO',
              onPressed: () {
                _epubReaderController.gotoEpubCfi(cfi);
              },
            ),
          ),
        );
      }
    }
  }

class FullScreenModal extends ModalRoute {

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);
  @override
  bool get opaque => false;
  @override
  bool get barrierDismissible => false;
  @override
  Color get barrierColor => Colors.black.withOpacity(0.6);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  // TODO: MUSIC PLAYER
  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MusicMetaData(),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MusicControlButton(),
                NextMusicButton()
              ],
            )
          ]
        )
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // add fade animation
    return FadeTransition(
      opacity: animation,
      // add slide animation
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        // add scale animation
        child: ScaleTransition(
          scale: animation,
          child: child,
        ),
      ),
    );
  }
}
