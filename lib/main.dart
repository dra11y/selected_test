import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  bool _isMaterial3 = true;
  bool _showSemanticsDebugger = false;

  @override
  Widget build(BuildContext context) {
    /// BAD: not localized, and should be a trait
    /// on the tab/item itself instead of a label on the icon.
    const String selectedLabel = 'Selected,';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      showSemanticsDebugger: _showSemanticsDebugger,
      home: Scaffold(
        appBar: AppBar(
          /// This is a heading in TalkBack, as it should be, but
          /// the semantics debugger does not show the role.
          title: const Text('Semantics Selected Issue Demo'),
        ),
        bottomNavigationBar: _isMaterial3
            ? NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    _selectedIndex = value;
                  });
                },
                destinations: [
                  /// With the selected icon label, when selected, the label
                  /// looks like this (but it should be a trait instead of in the label),
                  /// and on iOS, it erroneously appends the word, "text":
                  /// ```
                  /// Selected,
                  /// Home
                  /// Tab 1 of 3, text
                  /// ```
                  /// Unselected, it looks like this (but the tab should also
                  /// be a trait instead of part of the label, a different issue):
                  /// ```
                  /// Home
                  /// Tab 1 of 3
                  /// ```
                  NavigationDestination(
                    label: 'Home',
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(
                      Icons.home,

                      /// FIXME: NO!!! But we must, for now.
                      /// This is already being set at navigation_bar.dart:918
                      /// ```
                      /// Semantics(
                      ///   selected: _isForwardOrCompleted(destinationInfo.selectedAnimation),
                      /// ```
                      /// but it's not being propagated as a trait in the engine.
                      semanticLabel: !Platform.isAndroid ? selectedLabel : null,
                    ),
                  ),
                  NavigationDestination(
                    label: 'Favorites',
                    icon: Icon(Icons.favorite_outline),
                    selectedIcon: Icon(
                      Icons.favorite,

                      /// FIXME: Remove when the engine is fixed.
                      semanticLabel: !Platform.isAndroid ? selectedLabel : null,
                    ),
                  ),

                  /// NOTE: This tab never reads as selected on iOS/macOS/web
                  /// and never shows as selected in the semantics debugger.
                  /// On iOS it appends `text` to the end of the localized label, like this:
                  /// ```
                  /// Downloads
                  /// Tab 3 of 3, text
                  /// ```
                  NavigationDestination(
                    label: 'Downloads',
                    icon: Icon(Icons.download_outlined),
                    selectedIcon: Icon(Icons.download),
                  ),
                ],
              )
            : BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (value) {
                  setState(() {
                    _selectedIndex = value;
                  });
                },
                items: [
                  BottomNavigationBarItem(
                    label: 'Home',
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(
                      Icons.home,

                      /// FIXME: Remove when the engine is fixed.
                      semanticLabel: !Platform.isAndroid ? selectedLabel : null,
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: 'Favorites',
                    icon: Icon(Icons.favorite_outline),
                    activeIcon: Icon(
                      Icons.favorite,

                      /// FIXME: Remove when the engine is fixed.
                      semanticLabel: !Platform.isAndroid ? selectedLabel : null,
                    ),
                  ),

                  /// NOTE: This tab never reads as selected on iOS/macOS/web
                  /// and never shows as selected in the semantics debugger.
                  /// On iOS it appends `text` to the end of the localized label, like this:
                  /// ```
                  /// Downloads
                  /// Tab 3 of 3, text
                  /// ```
                  BottomNavigationBarItem(
                    label: 'Downloads',
                    icon: Icon(Icons.download_outlined),
                    activeIcon: Icon(Icons.download),
                  ),
                ],
              ),
        body: SafeArea(
          child: Column(
            children: [
              /// This is a switch in TalkBack, but semantics debugger says it's a button.
              SwitchListTile(
                title: const Text('Semantics Debugger'),
                value: _showSemanticsDebugger,
                onChanged: (value) {
                  setState(() {
                    _showSemanticsDebugger = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Material 3'),
                value: _isMaterial3,
                onChanged: (value) {
                  setState(() {
                    _isMaterial3 = value;
                  });
                },
              ),
              Expanded(
                child: Center(
                  child: Text(
                    [
                      'Hello World!',
                      'Showing ${_isMaterial3 ? 'NavigationBar' : 'BottomNavigationBar'}.',
                      'Selected tab index is $_selectedIndex.',
                    ].join('\n'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
