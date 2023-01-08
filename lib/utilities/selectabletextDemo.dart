import 'package:flutter/material.dart';
import 'package:text_selection_controls/text_selection_controls.dart';

class ReadingApp extends StatefulWidget {
  const ReadingApp({Key? key}) : super(key: key);

  @override
  _ReadingAppState createState() => _ReadingAppState();
}

class _ReadingAppState extends State<ReadingApp> {
  bool _showSearchField = false;
  Duration _duration = const Duration(milliseconds: 400);

  void toogleSearchMode() {
    if (mounted)
      setState(() {
        _showSearchField = !_showSearchField;
      });
  }

  /// UNDERLINE HIGHLIGHTED STRING
  void underlineHighlightedString(String highlightedText) {
    print('highlighted text: $highlightedText');
    //TODO UNDERLINE HIGHLIGHTED STRING
  }

  /// SHARE HIGHLIGHTED STRING
  void shareHighlightedString(String highlightedText) {
    print('highlighted text: $highlightedText');
    //TODO SHARE HIGHLIGHTED STRING
  }

  /// DELETE HIGHLIGHTED STRING
  void deleteHighlightedString(String highlightedText) {
    print('highlighted text: $highlightedText');
    //TODO DELETE HIGHLIGHTED STRING
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<String> _paragraphs = const [
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
      'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?',
      'But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure. To take a trivial example, which of us ever undertakes laborious physical _exercise_, except to obtain some advantage from it? But who has any right to find fault with a man who chooses to enjoy a pleasure that has no annoying consequences, or one who avoids a pain that produces no resultant pleasure?'
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0,
            floating: true,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            leading:
                IconButton(onPressed: () {}, icon: Icon(Icons.arrow_back_ios)),
            title: AnimatedSwitcher(
                duration: _duration,
                child: _showSearchField
                    ? TextFormField(
                        autofocus: true,
                        selectionControls: FlutterSelectionControls(
                            toolBarItems: <ToolBarItem>[
                              ToolBarItem(
                                  item: Text(
                                    'Select All',
                                    style: theme.textTheme.bodyText1,
                                  ),
                                  itemControl: ToolBarItemControl.selectAll),
                              ToolBarItem(
                                  item: Text(
                                    'Copy',
                                    style: theme.textTheme.bodyText1,
                                  ),
                                  itemControl: ToolBarItemControl.copy),
                              ToolBarItem(
                                  item: Text(
                                    'Cut',
                                    style: theme.textTheme.bodyText1,
                                  ),
                                  itemControl: ToolBarItemControl.cut),
                              ToolBarItem(
                                  item: Text(
                                    'Paste',
                                    style: theme.textTheme.bodyText1,
                                  ),
                                  itemControl: ToolBarItemControl.paste),
                              ToolBarItem(
                                  item: Text(
                                    'Bold',
                                    style: theme.textTheme.bodyText1,
                                  ),
                                  onItemPressed: (String highlightedText,
                                          int startIndex, int endIndex) =>
                                      {} // TODO:
                                  ),
                              ToolBarItem(
                                  item: Text(
                                    'Italic',
                                    style: theme.textTheme.bodyText1,
                                  ),
                                  onItemPressed: (String highlightedText,
                                          int startIndex, int endIndex) =>
                                      {} // TODO:
                                  ),
                              ToolBarItem(
                                  item: Text(
                                    'Strikethrough',
                                    style: theme.textTheme.bodyText1,
                                  ),
                                  onItemPressed: (String highlightedText,
                                          int startIndex, int endIndex) =>
                                      {} // TODO:
                                  ),
                              ToolBarItem(
                                  item: Text(
                                    'Share',
                                    style: theme.textTheme.bodyText1,
                                  ),
                                  onItemPressed: (String highlightedText,
                                          int startIndex, int endIndex) =>
                                      {} // TODO:
                                  ),
                            ]),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          isDense: true,
                          // border: UnderlineInputBorder(borderSide: BorderSide.none),
                          // focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none)
                        ),
                      )
                    : SizedBox()),
            actions: [
              AnimatedSwitcher(
                  duration: _duration,
                  child: _showSearchField
                      ? IconButton(
                          onPressed: toogleSearchMode, icon: Icon(Icons.clear))
                      : IconButton(
                          onPressed: toogleSearchMode,
                          icon: Icon(Icons.search))),
              if (!_showSearchField)
                IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
            ],
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate(
                  (_, index) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: SelectableText(
                          _paragraphs[index],
                          selectionControls:
                              FlutterSelectionControls(toolBarItems: <
                                  ToolBarItem>[
                            ToolBarItem(
                              item: Stack(
                                children: [
                                  Icon(Icons.circle, color: Colors.greenAccent),
                                  Align(
                                    widthFactor: .6,
                                    child: Icon(Icons.circle,
                                        color: Colors.deepPurple),
                                  ),
                                  Align(
                                    widthFactor: .2,
                                    child:
                                        Icon(Icons.circle, color: Colors.blue),
                                  )
                                ],
                              ),
                              onItemPressed: (String highlightedText,
                                      int startIndex, int endIndex) =>
                                  underlineHighlightedString(highlightedText),
                            ),
                            ToolBarItem(
                              item: Text(
                                'A',
                                style: theme.textTheme.headline6!.copyWith(
                                    fontSize: 20,
                                    decoration: TextDecoration.underline,
                                    decorationColor: theme.primaryColor),
                              ),
                              onItemPressed: (String highlightedText,
                                      int startIndex, int endIndex) =>
                                  underlineHighlightedString(highlightedText),
                            ),
                            ToolBarItem(
                              item: Icon(Icons.copy_outlined,
                                  color:
                                      theme.iconTheme.color!.withOpacity(.5)),
                              itemControl: ToolBarItemControl.copy,
                            ),
                            ToolBarItem(
                              item: Icon(Icons.share_outlined,
                                  color:
                                      theme.iconTheme.color!.withOpacity(.5)),
                              onItemPressed: (String highlightedText,
                                      int startIndex, int endIndex) =>
                                  shareHighlightedString(highlightedText),
                            ),
                            ToolBarItem(
                              item: Icon(Icons.bookmark_outline,
                                  color:
                                      theme.iconTheme.color!.withOpacity(.5)),
                              onItemPressed: (String highlightedText,
                                      int startIndex, int endIndex) =>
                                  deleteHighlightedString(highlightedText),
                            ),
                          ]),
                        ),
                      ),
                  childCount: _paragraphs.length))
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.black54,
          unselectedItemColor: Colors.black54,
          showSelectedLabels: false,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'list'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_outline), label: 'bookmark'),
            BottomNavigationBarItem(
                icon: Icon(Icons.brightness_3_outlined), label: 'theme'),
            BottomNavigationBarItem(
                icon: Text('Aa',
                    style: theme.textTheme.headline6!.copyWith(fontSize: 20)),
                label: 'font size'),
          ]),
    );
  }
}
