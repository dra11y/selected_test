import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  /// FIXME: This is not localized, and should be a trait
  /// on the tab/item itself instead of a label on the icon.
  /// Remove when fixed in the engine.
  static const String _selectedLabel = 'selected,';

  int _selectedTopTabIndex = 0;
  int _selectedBottomTabIndex = 0;
  bool _isMaterial3 = true;
  bool _showSemanticsDebugger = false;
  final _needsSelectedLabel = kIsWeb || Platform.isMacOS;

  List<NavigationDestination> _buildDestinations() => [
        /// With the selected icon label, when selected, the macOS VoiceOver label
        /// is read like this (but it should be a trait instead of in the label),
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
          icon: const Icon(Icons.home_outlined),
          selectedIcon: Icon(
            Icons.home,

            /// FIXME: NO!!! But we must, for now.
            /// This is already being set at navigation_bar.dart:918
            /// ```
            /// Semantics(
            ///   selected: _isForwardOrCompleted(destinationInfo.selectedAnimation),
            /// ```
            /// but it's not being propagated as a trait in the engine.
            semanticLabel: _needsSelectedLabel ? _selectedLabel : null,
          ),
        ),
        NavigationDestination(
          label: 'Favorites',
          icon: const Icon(Icons.favorite_outline),
          selectedIcon: Icon(
            Icons.favorite,

            /// FIXME: Remove when the engine is fixed.
            semanticLabel: _needsSelectedLabel ? _selectedLabel : null,
          ),
        ),

        /// FIXME: This tab never reads as selected on macOS/web
        /// and never shows as selected in the semantics debugger.
        /// ```
        /// Downloads
        /// Tab 3 of 3, text
        /// ```
        const NavigationDestination(
          label: 'Downloads',
          icon: Icon(Icons.download_outlined),
          selectedIcon: Icon(Icons.download),
        ),
      ];

  List<BottomNavigationBarItem> _buildBottomNavigationBarItems() => [
        BottomNavigationBarItem(
          label: 'Home',
          icon: const Icon(Icons.home_outlined),
          activeIcon: Icon(
            Icons.home,

            /// FIXME: Remove when the engine is fixed.
            semanticLabel: _needsSelectedLabel ? _selectedLabel : null,
          ),
        ),
        BottomNavigationBarItem(
          label: 'Favorites',
          icon: const Icon(Icons.favorite_outline),
          activeIcon: Icon(
            Icons.favorite,

            /// FIXME: Remove when the engine is fixed.
            semanticLabel: _needsSelectedLabel ? _selectedLabel : null,
          ),
        ),

        /// FIXME: This tab never reads as selected on macOS/web
        /// and never shows as selected in the semantics debugger.
        /// ```
        /// Downloads
        /// Tab 3 of 3, text
        /// ```
        const BottomNavigationBarItem(
          label: 'Downloads',
          icon: Icon(Icons.download_outlined),
          activeIcon: Icon(Icons.download),
        ),
      ];

  /// On web and macOS, the selected tab is not announced properly upon selection.
  /// Therefore, we hack it to announce manually.
  /// This is not good practice; would be better to be built in
  /// to follow i19n behavior and be consistent.
  void _announceSelectedTabIfNeeded({
    required int index,
    required String label,
  }) {
    if (!_needsSelectedLabel) return;

    Future.delayed(Duration.zero, () {
      SemanticsService.announce(
        'selected, $label, Tab ${index + 1} of 3',
        TextDirection.ltr,
      );
    });
  }

  List<Tab> _buildTabBarTabs() => [
        Tab(
          text: 'Help',
          icon: Icon(
            Icons.help,

            /// FIXME: Remove when the engine is fixed.
            semanticLabel: _selectedTopTabIndex == 0 ? 'selected,' : null,
          ),
        ),
        Tab(
          text: 'Support',
          icon: Icon(
            Icons.support_agent,

            /// FIXME: Remove when the engine is fixed.
            semanticLabel: _selectedTopTabIndex == 1 ? 'selected,' : null,
          ),
        ),

        /// FIXME: For comparison, this tab does not read its selected status
        /// in VoiceOver on web/macOS.
        const Tab(
          text: 'Contact Us',
          icon: Icon(
            Icons.phone,
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final destinations = _buildDestinations();
    final navigationBarItems = _buildBottomNavigationBarItems();
    final tabs = _buildTabBarTabs();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      showSemanticsDebugger: _showSemanticsDebugger,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            /// This is a heading in TalkBack, as it should be, but
            /// the semantics debugger does not show the role.
            title: const Text('Semantics Selected Issue Demo'),
            bottom: TabBar(
              tabs: tabs,
              onTap: (value) {
                setState(() {
                  _selectedTopTabIndex = value;
                  if (value == 2) return;

                  _announceSelectedTabIfNeeded(
                    index: _selectedTopTabIndex,
                    label: tabs[_selectedTopTabIndex].text ?? '',
                  );
                });
              },
            ),
          ),

          /// On web, all of these also read as ", group" in VoiceOver.
          bottomNavigationBar: _isMaterial3
              ? NavigationBar(
                  selectedIndex: _selectedBottomTabIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      _selectedBottomTabIndex = value;
                      if (value == 2) return;

                      _announceSelectedTabIfNeeded(
                        index: _selectedBottomTabIndex,
                        label: destinations[_selectedBottomTabIndex].label,
                      );
                    });
                  },
                  destinations: destinations,
                )
              : BottomNavigationBar(
                  currentIndex: _selectedBottomTabIndex,
                  onTap: (value) {
                    setState(() {
                      _selectedBottomTabIndex = value;
                      if (value == 2) return;

                      _announceSelectedTabIfNeeded(
                        index: _selectedBottomTabIndex,
                        label:
                            navigationBarItems[_selectedBottomTabIndex].label ??
                                '',
                      );
                    });
                  },
                  items: navigationBarItems,
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
                        'Selected tab index is $_selectedBottomTabIndex.',
                      ].join('\n'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
